# ChapterNo

Flutter app (Android + iOS) for students. Backend: Supabase.
State management: Bloc/Cubit (`flutter_bloc`) — Cubit by default.

Package ID: `ai.chapterno.chapter_no`

---

## 1. Read these first

Before writing any code, read the project documents in this order. They
explain what we are building, the rules we follow, and how the code is laid out.

| File | What it covers |
|---|---|
| [`CHAPTERNO_PROJECT_GUIDE.md`](CHAPTERNO_PROJECT_GUIDE.md) | Business context, product scope, subscriptions and ChapterCoins rules, decisions still open. |
| [`AGENTS.md`](AGENTS.md) | Engineering rules: confirmed stack, folder structure, file headers, file size limits, testing, security. Applies to humans and AI tools. |
| [`DESIGN.md`](DESIGN.md) | Design system: colors, typography, spacing, components, prohibited effects. Read before touching UI. |
| `CLAUDE.md` / `GEMINI.md` | Import `AGENTS.md` for Claude Code and Gemini CLI. Do not edit them; edit `AGENTS.md`. |
| `.agents/skills/` | Project skills used by AI coding tools (also linked into `.claude/skills/`). See section 3 of `AGENTS.md`. |

Also look through `lib/` (especially `lib/shared/` and `lib/core/`) to see
existing reusable components before building new ones.

---

## 2. Prerequisites

Install these tools:

1. **Flutter SDK (stable channel)** with Dart 3 —
   <https://docs.flutter.dev/get-started/install>
2. **Android Studio** (Android SDK, platform tools, build tools) —
   <https://developer.android.com/studio>
3. **Git**
4. **An Android emulator, Genymotion, or a real phone** (see section 4)
5. **Shorebird CLI** if you want to build an APK for your phone (see section 5)
6. **Xcode** (macOS only, needed only for iOS)

Check your setup:

```bash
flutter doctor
```

Fix every item `flutter doctor` reports before continuing. The Android
toolchain must show a green check, and you must accept the Android licenses:

```bash
flutter doctor --android-licenses
```

---

## 3. Project setup

```bash
git clone <repo-url>
cd chapterNo
flutter pub get
```

### Environment file

The app reads its Supabase config at build time from `.env`.

```bash
cp .env.example .env
```

Fill in `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`. Ask the project
lead for the values.

> **Security:** Only the publishable (anon) key goes in `.env`. Never put the
> `service_role` / secret key in it. `.env` is git-ignored — never commit it.

If you skip this step the app stops at startup with
`Missing Supabase config. Run with --dart-define-from-file=.env`.

---

## 4. Running the app on an emulator

You need an Android device to run the app. Pick **one** of the options below.

### Option A: Android Studio emulator (recommended)

1. Open Android Studio → **More Actions** → **Virtual Device Manager**
   (or **Tools → Device Manager** when a project is open).
2. Click **Create Device**, pick a phone (for example *Pixel 7*), then pick a
   recent system image (API 34 or newer is fine). Download it if needed.
3. Finish the wizard and press **▶** to start the emulator.
4. On Windows, make sure hardware acceleration is on
   (Windows Hypervisor Platform, enabled from *Turn Windows features on or off*).
   Without it the emulator is very slow.

You can also start it from the terminal:

```bash
flutter emulators                 # list emulators
flutter emulators --launch <id>   # start one
```

### Option B: Genymotion

Use this if the Android Studio emulator is too slow on your machine.

1. Install **Genymotion Desktop** (free for personal use) —
   <https://www.genymotion.com/product-desktop/download/>.
   Pick the installer that bundles VirtualBox if you do not already have it.
2. Open Genymotion, sign in, add a device (for example a Pixel with Android 13+),
   and start it.
3. Point Genymotion at your Android SDK so Flutter can see the device:
   **Settings → ADB → Use custom Android SDK tools** → select your Android SDK
   folder (usually `%LOCALAPPDATA%\Android\Sdk` on Windows, `~/Library/Android/sdk`
   on macOS).

### Option C: A real phone over USB

1. Enable **Developer options** on the phone (tap *Build number* 7 times in
   *Settings → About phone*).
2. Turn on **USB debugging**.
3. Connect the phone and accept the "Allow USB debugging" prompt.

### Run

Check that Flutter sees your device, then run with the env file:

```bash
flutter devices
flutter run --dart-define-from-file=.env
```

If you have more than one device connected, add `-d <device-id>`.

---

## 5. Testing on your phone with Shorebird

The project uses [Shorebird](https://shorebird.dev) (`shorebird_code_push`
package). Shorebird lets you build a release APK and install it on your own
phone, and later receive code-push patches without reinstalling.

### Install the Shorebird CLI

**Windows (PowerShell):**

```powershell
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
iwr -UseBasicParsing 'https://raw.githubusercontent.com/shorebirdtech/install/main/install.ps1' | iex
```

**macOS / Linux:**

```bash
curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash
```

Shorebird installs to `~/.shorebird/bin` and adds itself to PATH. It also ships
its own private copy of Flutter — **do not** add that copy to your PATH. Keep
using your normal Flutter SDK for daily development.

Then check it and sign in:

```bash
shorebird --version
shorebird doctor
shorebird login
```

Ask the project lead to add your Shorebird account to the ChapterNo app.

### First-time project setup (project lead only, once)

If `shorebird.yaml` does not exist in the project root yet, run:

```bash
shorebird init
```

This creates `shorebird.yaml` with the app ID and adds it to the Flutter
assets in `pubspec.yaml`. Commit both files. Other developers should **not**
run `shorebird init` again.

### Build an APK

```bash
# macOS / Linux / Git Bash
shorebird release android --artifact apk -- --dart-define-from-file=.env
```

```powershell
# PowerShell: the -- separator must be quoted
shorebird release android --artifact apk '--' --dart-define-from-file=.env
```

Everything after `--` is passed to `flutter build`.

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

### Install it on your phone

- **USB:** connect the phone (USB debugging on) and run
  `adb install -r build/app/outputs/flutter-apk/app-release.apk`
- **Manual:** copy the APK to the phone, open it, and allow
  "Install unknown apps" for your file manager when asked.

> `shorebird release` creates a real release record in the Shorebird console.
> Coordinate with the team before creating releases, and do not upload
> builds to Google Play — store publishing is handled by the project lead.

---

## 6. Before you push

Run the required checks (see section 13 of `AGENTS.md`):

```bash
dart format .
flutter analyze
flutter test
```

`flutter analyze` must report zero issues and all tests must pass.

---

## 7. Troubleshooting

| Problem | Fix |
|---|---|
| `No devices found` | Start the emulator/Genymotion first, then run `flutter devices`. For Genymotion, check the custom ADB path (section 4B). |
| `Missing Supabase config` at startup | Create `.env` and run with `--dart-define-from-file=.env`. |
| Android licenses not accepted | `flutter doctor --android-licenses` |
| Emulator very slow on Windows | Enable Windows Hypervisor Platform, or use Genymotion. |
| `shorebird` not found | Restart the terminal so PATH updates, or add `~/.shorebird/bin` to PATH. |
| PowerShell ignores args after `--` | Quote the separator: `'--'`. |
