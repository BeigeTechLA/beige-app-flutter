# Plan: Environment Flavors + Entry Points + Release Signing

## Context
Current setup uses `--dart-define=ENV=dev` with a switch statement in `config.dart`. Stripe key is hardcoded separately. No release signing configured. This plan adds full Flutter flavor support (Android `productFlavors` + iOS Xcode schemes) with separate Dart entry points.

---

## Execution Plan

### Part A: Dart-Side Changes

| # | Task | File | Status |
|---|------|------|--------|
| 1 | Create consolidated env config | `lib/config/env.dart` | DONE |
| 2 | Create dev entry point | `lib/main_dev.dart` | DONE |
| 3 | Create prod entry point | `lib/main_prod.dart` | DONE |
| 4 | Refactor main.dart (extract startApp, update imports) | `lib/main.dart` | DONE |
| 5 | Update api_service (swap AppConfig -> Env, remove dead code) | `lib/service/api_service.dart` | DONE |
| 6 | Clean up commented-out upload block | `lib/MyProfile/edit_profile.dart` | DONE |
| 7 | Delete old config files | `lib/service/config.dart`, `lib/service/stripe_config.dart` | DONE |

### Part B: Android Flavor + Signing Setup

| # | Task | File | Status |
|---|------|------|--------|
| 8 | Add productFlavors (dev/prod) + release signing | `android/app/build.gradle.kts` | DONE |
| 9 | Use flavor app_name in manifest | `android/app/src/main/AndroidManifest.xml` | DONE |
| 10 | Create signing template | `android/key.properties` | DONE |

### Part C: iOS Flavor Setup

| # | Task | File | Status |
|---|------|------|--------|
| 11 | Create dev Xcode scheme | `ios/Runner.xcodeproj/xcshareddata/xcschemes/dev.xcscheme` | DONE |
| 12 | Create prod Xcode scheme | `ios/Runner.xcodeproj/xcshareddata/xcschemes/prod.xcscheme` | DONE |

### Part D: Cleanup & Config

| # | Task | File | Status |
|---|------|------|--------|
| 13 | Add key.properties and keystore to gitignore | `.gitignore` | DONE |
| 14 | Update build/run commands | `CLAUDE.md` | DONE |
| 15 | Run flutter analyze | — | DONE (0 new errors) |

---

## Build Commands

```bash
# Dev
flutter run --flavor dev -t lib/main_dev.dart

# Prod
flutter run --flavor prod -t lib/main_prod.dart

# Build APK (release)
flutter build apk --flavor prod -t lib/main_prod.dart --release

# Build iOS (release)
flutter build ios --flavor prod -t lib/main_prod.dart --release
```

---

## Android Release Signing (one-time manual step)

```bash
mkdir -p android/keystore
keytool -genkey -v -keystore android/keystore/beige-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias beige
```
Then fill in `android/key.properties` with the passwords.
