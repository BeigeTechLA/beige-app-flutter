# flutter_local_notifications 22 → 23 Upgrade Plan

**Status:** 🟢 COMPLETE (2026-11-18) — v23.0.2 live; minimal AGP 9.1.1 + Gradle 9.3.1 bump unblocked compileSdk 37. Android APK ✓ 102.7MB · iOS ✓ 105.8MB. Only on-device push QA remains (manual test summary below).
**Branch:** `notifications`
**Date:** 2026-11-18

## Summary

Bump `flutter_local_notifications` `^22.3.0` (resolved 22.3.3) → `^23.0.2`.
Zero Dart source changes required (code already uses the v19+ named-param API).
One Android build-config change required: `compileSdk 36 → 37` (v23 plugin is built against SDK 37; Flutter 3.47 default is 36, which would fail the Gradle "compile against 37+" check).

## Compatibility (verified)

| Requirement (v23) | Project has | OK |
|---|---|---|
| Flutter ≥ 3.44 / Dart ≥ 3.12 | 3.47.0 / 3.13.0 | ✅ |
| `timezone ^0.11.0` | `^0.11.0` | ✅ no bump |
| `platform_interface ^13.0.0` | transitive | ✅ auto |
| Android minSdk ≥ 24 | 24 | ✅ |
| firebase_messaging coupling | none | ✅ |

Sub-plugins (linux 8→9, web 1→2, windows 3→4) resolve transitively — no direct action.

## Phases

### Phase 1 — Dependency + build config

| Task ID | Description | Files | Status |
|---------|-------------|-------|--------|
| 1.1 | Bump `flutter_local_notifications: ^22.3.0` → `^23.0.2` | `pubspec.yaml` (line 43) | 🟢 Completed |
| 1.2 | Override `compileSdk = 37` (currently `flutter.compileSdkVersion` = 36) in `android { }` block | `android/app/build.gradle.kts` (line 22) | 🟢 Completed |
| 1.3 | `flutter pub get` — resolved 23.0.2 + platform_interface 13.0.0 + timezone 0.11.2 | (lockfile gitignored) | 🟢 Completed |

### Phase 2 — Static verification

| Task ID | Description | Files | Status |
|---------|-------------|-------|--------|
| 2.1 | `flutter analyze` — 0 errors (58 info, all pre-existing cosmetic/deprecation, none notification) | — | 🟢 Completed |
| 2.2 | `flutter test` — 395 pass / 6 fail; all 6 pre-existing WIP fails (account_deletion/drawer/meetings), zero notification coupling, not regressions | — | 🟢 Completed |

### Phase 3 — Build verification

| Task ID | Description | Files | Status |
|---------|-------------|-------|--------|
| 3.0a | Bump AGP `9.0.1` → `9.1.1` (first 37-capable) | `android/settings.gradle.kts` | 🟢 Completed |
| 3.0b | Bump Gradle wrapper `9.1.0` → `9.3.1` (AGP 9.1 min) | `android/gradle/wrapper/gradle-wrapper.properties` | 🟢 Completed |
| 3.1 | Android prod APK release build | `flutter build apk --flavor prod -t lib/main_prod.dart --release` | 🟢 Completed — ✓ 102.7MB |
| 3.2 | iOS release build (validates CocoaPods/native side of v23) | `flutter build ios --flavor prod -t lib/main_prod.dart --release` | 🟢 Completed — ✓ 105.8MB |

#### Phase 3 resolution (2026-11-18)

Took the **minimal AGP bump** path. AGP 9.1.1 docs state *"supports Android API
level 37.0 and lower"*, min Gradle 9.3.1, KGP min 2.2.10 (we're on 2.3.20), JDK
17, build-tools 36.0.0. Two config lines only:

- `android/settings.gradle.kts` — AGP `9.0.1` → `9.1.1`
- `android/gradle/wrapper/gradle-wrapper.properties` — Gradle `9.1.0` → `9.3.1`

AGP 9.1.x resolves `compileSdk = 37` to the `android-37.0` minor platform (9.0.1
could not). No further opt-ins needed — the AGP-9.0 ones (`lint.checkReleaseBuilds
= false`, `buildFeatures.resValues = true`) carried over. Both release builds
green on first try. `android-37.0` is a released base SDK (not preview); targetSdk
stays 36, so no runtime-behavior change — pinning compileSdk 37 is compile-time only.

#### Phase 3 blocker (discovered 2026-11-18, RESOLVED)

`flutter_local_notifications 23.0.2` hard-codes `compileSdk = 37` in its own
`android/build.gradle`. Google now ships API 37 only as **minor-versioned**
platforms (`android-37.0`, `android-37.1`, `android-37.2`) — there is no plain
`platforms;android-37` package. Our current **AGP 9.0.1** forms the target hash
`android-37` and cannot resolve the minor platform, so the build dies with:

```
Could not determine the dependencies of task ':app:l8DexDesugarLibProdRelease'.
> Failed to find target with hash string 'android-37' in: .../Android/sdk
```

Resolving this requires a **37-capable AGP** (plugin itself was built with AGP
9.1.1) plus the Gradle version that AGP needs. Confirmed-good combo per Google
docs: **AGP 9.5.x + Gradle 9.6.0** (AGP 9.5 max API = 37, requires Gradle 9.6.0).
Current project state: **AGP 9.0.1 / Gradle 9.1.0**. A lighter intermediate
(AGP 9.1.x/9.2.x) may also work but its exact min-Gradle needs verification.

This is an AGP/Gradle toolchain bump — larger than the original "set compileSdk
= 37" task. **Out of the approved plan's scope; needs explicit approval before
touching Gradle/AGP config.** See existing `docs/AGP_9_GRADLE_9_UPGRADE_PLAN.md`
for prior toolchain-bump precedent.

### Phase 4 — Docs / memory sync

| Task ID | Description | Files | Status |
|---------|-------------|-------|--------|
| 4.1 | Record upgrade + compileSdk-37 gotcha in migration notes | `CLAUDE.md` / `project_flutter_347_upgrade.md` memory | 🔴 Not Started |

## Risks / watch items

- **Android 14+ background activity-launch denial** (new hard behavior in v23). `showBackgroundDataNotification` only *displays* a tray item — no activity launch — so expected safe. Tap-to-open is OS-mediated. Verify on device (see manual test).
- AGP mismatch is harmless: plugin built with AGP 9.1.1, app on 9.0.1 — consuming app AGP need not match the plugin's build AGP.
- `compileSdk 37` is the only thing that can block the Android build; if the Gradle check still complains, confirm Android SDK Platform 37 is installed locally.

## Manual test summary (post-merge, real devices)

1. **Foreground push** — app open, send chat/booking/meeting push → in-app banner shows, tap routes to correct screen.
2. **Background data-only push** (Android 14+ device) — app backgrounded, send data-only FCM (`notification == null`) → local notification appears in tray on correct channel; tap opens correct deep link.
3. **Terminated push** — kill app, send push → notification shows; tap cold-starts app to correct screen.
4. **Android 13+ permission** — fresh install, confirm POST_NOTIFICATIONS runtime prompt still fires.
5. **iOS** — foreground + background push present correctly; APNs token still fetched.
6. **4 channels** — confirm chat / booking / meeting / general channels still created with correct importance.
