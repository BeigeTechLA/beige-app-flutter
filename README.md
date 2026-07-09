# beige

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Scripts

npm-run-style aliases via `make`. Run from repo root.

| Command | What it does |
|---------|--------------|
| `make build-dev` | Clean → pub get → iOS IPA (dev, release) → Android APK (dev, release) |
| `make build-dev-ios` | Clean → pub get → iOS IPA only (dev) |
| `make build-dev-android` | Clean → pub get → Android APK only (dev) |
| `make build-prod` | Clean → pub get → iOS IPA (prod, release) → Android APK (prod, release) |
| `make build-prod-ios` | Clean → pub get → iOS IPA only (prod) |
| `make build-prod-android` | Clean → pub get → Android APK only (prod) |
| `make clean` | `flutter clean` |
| `make pub` | `flutter pub get` |

Raw scripts also runnable directly:

```bash
./scripts/build_dev.sh
./scripts/build_prod.sh
```

Outputs:
- IPA: `build/ios/ipa/*.ipa`
- APK (dev): `build/app/outputs/flutter-apk/app-dev-release.apk`
- APK (prod): `build/app/outputs/flutter-apk/app-prod-release.apk`
