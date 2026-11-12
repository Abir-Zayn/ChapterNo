# playstore-flutter

Agent skill to guide the preparation of a **Flutter** project for Google Play Store release.

## What it covers

- Gradle DSL detection (Groovy vs Kotlin DSL for Flutter 3.29+)
- Upload keystore generation (PKCS12)
- Signing configuration with `key.properties`
- ProGuard/R8 review (only when needed)
- Version management via `pubspec.yaml`
- AAB build with obfuscation options and verification

## Install

```bash
npx skills add Tacuchi/playstore-flutter
```

## Compatibility

Works with any agent that supports the [Agent Skills](https://skills.sh/) standard, including:

- [Warp](https://www.warp.dev/)
- [Claude Code](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code)
- [Cursor](https://www.cursor.com/)
- [Windsurf](https://windsurf.com/)
- [GitHub Copilot](https://github.com/features/copilot)

## License

[MIT](LICENSE)
