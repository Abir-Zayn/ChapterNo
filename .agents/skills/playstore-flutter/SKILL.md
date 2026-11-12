---
name: playstore-flutter
description: >
  Guide and review the preparation of a Flutter project for Google Play Store release.
  Covers keystore generation, signing configuration, ProGuard/R8, and AAB build.
  Use when the user wants to publish, release, deploy, sign, or prepare a Flutter app
  for Play Store, or when they mention "flutter build appbundle", "release signing",
  "play store flutter", "generate keystore", "configure signing", or "R8 errors".
---

# Play Store Release — Flutter

Build a signed Android App Bundle (AAB) from a Flutter project, ready for Google Play Store.

## Before You Start — Assess the Project

Ask these questions BEFORE touching any files:

1. **Gradle DSL?** Check `android/app/build.gradle` vs `build.gradle.kts`
   - `.kts` → Kotlin DSL (Flutter 3.29+ default)
   - `.gradle` → Groovy (legacy — do NOT convert during release prep)

2. **Existing signing config?** Search for `signingConfigs` in the build file
   - Already exists → Verify it reads from `key.properties`, don't duplicate
   - Missing → Add from scratch

3. **Flavor setup?** Search for `productFlavors` in the build file
   - Has flavors → Each flavor needs its own signing config or a shared one referenced by all
   - No flavors → Single release config

4. **ProGuard needed?** Run `flutter build appbundle --release` FIRST
   - Builds successfully → No ProGuard rules needed, skip Step 4
   - R8 error with missing classes → Check `missing_rules.txt`, add rules

5. **Existing keystore?** Ask the user before generating a new one
   - Already has `.jks` → Reuse it, skip Step 1
   - First release → Generate new keystore

---

## Workflow

| Step | Action | Key file |
|------|--------|----------|
| 1 | Generate upload keystore | `upload-keystore.jks` |
| 2 | Create credentials file | `android/key.properties` |
| 3 | Configure signing in Gradle | `android/app/build.gradle.kts` |
| 4 | Review ProGuard / R8 (if needed) | `android/app/proguard-rules.pro` |
| 5 | Build release AAB | CLI |
| 6 | Verify output | CLI + checklist |

---

## Step 1 — Generate Upload Keystore

```bash
keytool -genkeypair \
  -alias upload \
  -keyalg RSA -keysize 2048 \
  -validity 10000 \
  -storetype PKCS12 \
  -keystore upload-keystore.jks
```

Critical details:
- `-validity 10000` = ~27 years. Google requires validity beyond Oct 22 2033.
- `-storetype PKCS12` — avoids JKS migration warnings. But with PKCS12, **store password and key password must be identical**. `keytool` silently uses the store password for the key. If you enter different passwords, signing fails later with misleading "Cannot recover key" error.
- Store the `.jks` outside the project. Recommended: `~/.android/keystores/` or a secrets manager.

---

## Step 2 — Create Credentials File

Create `android/key.properties` (must NOT be committed):

```properties
storePassword=<password>
keyPassword=<same-password-as-store>
keyAlias=upload
storeFile=<absolute-or-relative-path-to-upload-keystore.jks>
```

Add to `android/.gitignore`:

```gitignore
key.properties
*.jks
*.keystore
```

---

## Step 3 — Configure Signing in Gradle

Claude knows how to write a Gradle signing config. Focus on these Flutter-specific traps:

- **File root**: Use `rootProject.file("key.properties")` — NOT `project.file()`. In Flutter, `rootProject` = `android/`, `project` = `android/app/`. Wrong root = file not found silently, null properties at build time.
- **KTS casting**: `keystoreProperties["keyAlias"] as String` — Properties returns `Any?`. Missing cast = compile error. Missing property key = NPE at build time with no useful message.
- **Flutter injects debug signing automatically** — Do NOT add a `debug` signingConfig. Flutter's Gradle plugin handles it. Adding one creates conflicts.
- **signingConfigs before buildTypes** — Gradle evaluates blocks in order. If `buildTypes` references a signingConfig that hasn't been declared yet, build fails.

### Kotlin DSL (`android/app/build.gradle.kts`) — Flutter 3.29+

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) load(FileInputStream(file))
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

For Groovy DSL (legacy projects): same structure but use `def keystoreProperties = new Properties()`, untyped property access `keystoreProperties['keyAlias']`, and `signingConfig signingConfigs.release` without `=`.

### Version Management

Version lives in `pubspec.yaml` as `version: X.Y.Z+N` where `X.Y.Z` = `versionName` and `N` = `versionCode`. Flutter's Gradle plugin reads this automatically. NEVER set `versionCode`/`versionName` in `build.gradle` — the values are ignored but cause confusion. Override via CLI: `--build-name=1.2.0 --build-number=42`.

---

## Step 4 — ProGuard / R8 (Only If Needed)

R8 is enabled by default in Flutter release builds. You typically do NOT need custom rules. Only act if:

- R8 reports missing classes → it generates `build/app/outputs/mapping/release/missing_rules.txt`. Copy those rules verbatim to `android/app/proguard-rules.pro`.
- A plugin's README explicitly says "add ProGuard rules".

When adding rules, reference the file in Gradle:

```kotlin
buildTypes {
    release {
        isMinifyEnabled = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

Common rules needed by Flutter plugins:

```proguard
# Google Play Core (in-app updates / reviews)
-keep class com.google.android.play.core.** { *; }
# Firebase
-keep class com.google.firebase.** { *; }
# Gson (if used by a plugin)
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
```

---

## Step 5 — Build Release AAB

```bash
flutter build appbundle --release
```

Useful flags:
- `--obfuscate --split-debug-info=build/debug-info` — obfuscate Dart code + save symbols for crash reporting. Upload symbols to Firebase Crashlytics or Play Console.
- `--build-name=1.2.0 --build-number=42` — override version without editing `pubspec.yaml`.
- `--dart-define=ENV=production` — inject compile-time constants.

Output: `build/app/outputs/bundle/release/app-release.aab`

---

## Step 6 — Verify Before Upload

```bash
# Verify signing — confirm alias is "upload", NOT "androiddebugkey"
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab

# Verify version (requires bundletool)
bundletool dump manifest --bundle=build/app/outputs/bundle/release/app-release.aab \
  | grep -E "versionCode|versionName"
```

Checklist:
- [ ] AAB signed with **upload** key (not debug) — debug key = #1 rejection reason
- [ ] `versionCode` higher than the previous upload
- [ ] `key.properties` and `*.jks` in `.gitignore`
- [ ] Obfuscation symbols saved (if `--obfuscate` used)

---

## NEVER Do

1. **NEVER set different store/key passwords with PKCS12** — `keytool` silently uses store password for key. Different passwords → signing fails with "Cannot recover key" (misleading — it's a password mismatch, not a corrupt key).

2. **NEVER skip `flutter clean` after Gradle changes** — Flutter caches resolved Gradle configs in `.dart_tool/`. Stale cache → old signing config used → AAB signed with debug key → Play Store rejects upload.

3. **NEVER upload without checking the signer alias** — `jarsigner -verify` says "verified" even with debug key. You must run `keytool -printcert -jarfile` and confirm alias is `upload`, not `androiddebugkey`.

4. **NEVER convert Groovy to KTS during release prep** — DSL migration can break the build in subtle ways. If project uses `.gradle`, configure signing in Groovy. Migrate DSL in a separate PR with its own testing cycle.

5. **NEVER hardcode version in build.gradle** — Flutter reads version from `pubspec.yaml`. Gradle values are silently ignored, creating "I bumped the version but Play Store says it's the same" confusion.

6. **NEVER add a debug signingConfig** — Flutter's Gradle plugin injects debug signing automatically. Adding one creates "signingConfig already exists" errors or silently overrides Flutter's behavior.

---

## Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Missing class: ...` during R8 | R8 strips classes used via reflection | Copy rules from `missing_rules.txt` to `proguard-rules.pro` |
| `minifyReleaseWithR8` failed | Conflicting or malformed ProGuard rules | Check `proguard-rules.pro` for duplicate/syntax errors |
| Play Store: "debug certificate" | AAB signed with debug key | Verify `signingConfig` points to release; run `flutter clean` |
| `versionCode N already used` | Same versionCode as previous upload | Increment `+N` in `pubspec.yaml` |
| `Cannot recover key` | PKCS12 store/key password mismatch | Regenerate keystore with identical passwords |
| Build succeeds but wrong version | Version hardcoded in `build.gradle` overrides `pubspec.yaml` | Remove version from `build.gradle`, use only `pubspec.yaml` |

---

## Gotchas

1. **App Signing by Google Play** — Google re-signs your app with their app signing key. The keystore you generate is the **upload key** only. If you lose it, request a reset through Play Console (takes days, requires identity verification).

2. **`missing_rules.txt` location changes** — After a `flutter clean`, the path resets. The file only appears after a failed R8 build. Don't expect it to persist between clean builds.

3. **Plugins silently need ProGuard rules** — Pure Dart doesn't need rules, but plugins with native Android code (Firebase, Google Maps, Play Core, Stripe) may. Always check plugin READMEs and changelogs for "add ProGuard rule" notes.

4. **`--obfuscate` without `--split-debug-info` is an error** — Flutter requires both flags together. If you forget `--split-debug-info`, the build fails with a clear message, but it's easy to miss in CI scripts.
