# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run in development
flutter run --flavor dev -t lib/main_dev.dart

# Run in production
flutter run --flavor prod -t lib/main_prod.dart

# Build APK (release)
flutter build apk --flavor prod -t lib/main_prod.dart --release

# Build iOS (release)
flutter build ios --flavor prod -t lib/main_prod.dart --release

# Analyze / lint
flutter analyze

# Run tests
flutter test

# Regenerate launcher icons
flutter pub run flutter_launcher_icons:main
```

## What This App Is

**Beige** is a Flutter app for booking photography/videography services. Users are either **Clients** (who book shoots) or **Creatives** (who offer services). The app has 27 screens, ~34,200 lines of Dart across 59 files.

## Current Architecture (Pre-Migration)

The codebase is mid-migration from a legacy architecture to a clean architecture target. Read this section to understand what exists TODAY.

### State Management
- **No state management library.** 100% `StatefulWidget` + `setState()` across all 37 screen files.
- `SharedPreferences` handles persistence (auth token, login state, user ID).
- No DI — `ApiService()` is instantiated fresh inside each widget's methods.
- 11 god widgets exceed 1,000 lines. Largest: `new_home_screen.dart` (3,838 lines).

### Navigation
- Navigator 1.0 imperative only — 135 total calls (62 push, 11 pushReplacement, 8 pushAndRemoveUntil, 54 pop).
- Zero named routes. Zero GoRouter usage.
- `MainScreen` manages a 4-tab bottom nav using `switch(_selectedIndex)` — NOT `IndexedStack`, so every tab switch destroys and rebuilds the tab widget.
- Auth guard: boot-time `SharedPreferences` check only — no runtime redirect on token expiry.

### Networking
- **Primary HTTP client is the `http` package, NOT Dio.** Dio is declared in pubspec but only used in one `postMultipart()` method with a fresh `Dio()` instance per call (no interceptors, no base config).
- `ApiService` (`lib/service/api_service.dart`) has 7 methods using `http`, all with inconsistent error handling.
- `putData()` and `deleteData()` have NO try/catch — network errors crash the widget tree.
- No interceptors, no retry logic, no typed exceptions, no repository layer.
- Endpoints centralized in `lib/service/api_endpoints.dart` (good).

### Styling
- No design token files exist. `lib/app/` directory does not exist.
- ~2,981 hardcoded style values across the codebase (311 inline Color(), 732 Colors.xxx, 568 TextStyle(), 458 EdgeInsets, 350 BorderRadius).
- `Theme.of(context)` used exactly 2 times total (both `SliderTheme`).
- `ColorCode.dart` exists with 50+ colors but uses non-semantic names (`k282828`, `bcakgroundcolor`).

### Firebase
- Completely absent. Zero Firebase packages, zero config files, zero crash reporting, zero analytics.
- 89 try/catch blocks silently swallow errors via `print()`.
- 119 `print()` statements including auth token logging in production.

### Environment / Config
- `lib/config/env.dart` — `Env.init(environment)` sets API URLs and Stripe key per environment.
- `lib/main_dev.dart` → dev, `lib/main_prod.dart` → prod.
- Both flavors currently point to the same API URL: `https://mobile.beige.app/api/`.
- Prod Stripe key is placeholder: `'PLACE_HOLDER_LIVE_STRIPE_KEY'`.

### Key Directories (Current)
| Path | Purpose |
|------|---------|
| `auth/` | Login, signup, forgot password, OTP (6 files) |
| `Home/` | Home screen + all booking flow screens (15 files) |
| `Home/NewBookingFlow/` | Multi-step booking: shoot type → crew size → review/payment |
| `Booking/` | Manage existing bookings, cancellation (7 files) |
| `MyProfile/` | Profile view/edit, account deletion (10 files) |
| `service/` | ApiService, endpoints, SharedService (5 files) |
| `utility/` | ColorCode.dart, images.dart |
| `widgets/` | Shared UI components |
| `config/` | Env.dart |

### Assets
- Fonts: **Unbounded**, **Outfit**, **HelveticaNeue** (registered in pubspec). **InstrumentSans** referenced in code but NOT in pubspec (silent runtime bug).
- SVGs, Lottie animations, and images under `assets/`.

### Payment
- Stripe via `flutter_stripe` — payment screens in `Home/NewBookingFlow/Book_Confirm/`.

### Maps / Location
- Google Maps (`google_maps_flutter`), geolocation (`geolocator`), place search (`google_places_flutter`).

## Target Architecture

The migration target is defined in three guide documents under `docs/guides/`:
- `FLUTTER_BASE_GUIDELINES.md` — Architecture, Network, Firebase, Navigation
- `FLUTTER_DESIGN_SYSTEM.md` — Typography, Colors, Spacing, Radii, Shadows, Themes
- `FLUTTER_TESTING_GUIDELINES.md` — Unit, Widget, Integration, Golden tests

Migration rules and patterns are in `MIGRATION_RULES.md` at the project root.

### Target Stack
| Layer | Current | Target |
|-------|---------|--------|
| State management | `setState` | `flutter_riverpod` (manual Notifier/AsyncNotifier) |
| Navigation | `Navigator.push/pop` | `go_router` with `StatefulShellRoute.indexedStack` |
| HTTP client | `http` package | `Dio` with interceptor chain |
| Error handling | `Exception('string')` | Sealed `AppException` hierarchy |
| Models | `Map<String, dynamic>` | `freezed` + `json_serializable` |
| Firebase | absent | `firebase_core` + `firebase_crashlytics` + `firebase_analytics` |
| Testing | 1 smoke test | `mocktail`, AAA pattern, 70%+ coverage |
| Design tokens | 2,981 inline values | `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadii`, `AppShadows`, `AppDurations`, `AppTheme` |

### Target Folder Structure
```
lib/
├── main.dart / main_dev.dart / main_prod.dart    # Entry points (DO NOT modify flavor files)
├── app/                                           # Design tokens, router, theme
│   ├── colors.dart, text_styles.dart, spacing.dart, radii.dart, shadows.dart, durations.dart
│   ├── theme.dart, router.dart, route_names.dart, assets.dart, app.dart
│   └── flavor_config.dart
├── core/
│   ├── network/          # DioClient, interceptors, exceptions, ExceptionHandler
│   ├── firebase/         # FirebaseService, CrashlyticsService, AnalyticsService
│   ├── providers/        # core_providers.dart (app-wide Riverpod providers)
│   ├── utils/            # Validators, formatters
│   └── extensions/       # Context, String, DateTime extensions
├── features/
│   └── [feature_name]/
│       ├── data/         # Models (freezed), datasources, repository impls
│       ├── domain/       # Entities, repository interfaces, usecases
│       └── presentation/ # Screens (ConsumerWidget), widgets, providers
└── shared/
    ├── widgets/          # Reusable components (2+ features)
    └── layouts/          # Shell layouts, scaffolds
```

## Known Bugs (from audits)

These are confirmed bugs that should be fixed before or during migration:

1. **Broken internet detection** — `internet_service.dart:9,15` compares `List<ConnectivityResult>` to `ConnectivityResult` (always false). Offline state is never detected.
2. **Auth token logged in production** — `api_service.dart:30`: `print('🔐 Sending token: $token')` runs on every API call in release builds.
3. **Wrong S3 bucket** — `shared_service.dart` has `imageURL` pointing to `nextgengurukul` S3 bucket (different project). `ApiService.imageURL` has the correct URL.
4. **Trailing space in endpoint** — `api_endpoints.dart:33`: `"auth/profile-photo "` has a trailing space causing 404.
5. **No try/catch on putData/deleteData** — Network errors during profile update or booking cancellation crash the app.
6. **57 async context violations** — `BuildContext` used after `await` without `mounted` check across 15+ files.
7. **InstrumentSans font missing** — Referenced in 2 files but not registered in `pubspec.yaml`. Text silently falls back to system font.

## Migration Status

**Current phase: Phase 1 (Audit) — COMPLETE.**

Phase 2 (Critical Bug Fixes) and Phase 3 (Foundations) have not started. See `MIGRATION_PLAN.md` for the full timeline and feature migration order.

### Audit Reports
All audit reports are in `docs/auditreports/`:
- `PROJECT_AUDIT.md` — Baseline: Flutter 3.38.9, 59 files, 27 screens
- `STATE_MANAGEMENT_AUDIT.md` — 100% setState, 11 god widgets, zero DI
- `NAVIGATION_AUDIT.md` — 135 Navigator calls, full route graph
- `STYLING_AUDIT.md` — ~2,981 hardcoded values, zero design tokens
- `NETWORKING_AUDIT.md` — http primary, no interceptors, no typed exceptions
- `FIREBASE_AUDIT.md` — 0/19 requirements met
- `CODE_QUALITY_AND_TESTING_AUDIT.md` — 613 lint issues, 1 test, 0% coverage

### Key Planning Documents
| File | Purpose |
|------|---------|
| `MIGRATION_PLAN.md` | Timeline, feature order, risk register, blockers |
| `MIGRATION_RULES.md` | Patterns, code templates, non-negotiable rules for migration |
| `docs/guides/FLUTTER_BASE_GUIDELINES.md` | Target architecture reference |
| `docs/guides/FLUTTER_DESIGN_SYSTEM.md` | Design token definitions |
| `docs/guides/FLUTTER_TESTING_GUIDELINES.md` | Testing patterns and coverage targets |

## Rules

### General
- All planning and design `.md` files must be stored in the `docs/` folder at the project root.
- Audit reports go in `docs/auditreports/`.
- Architecture guides go in `docs/guides/`.

### Migration Rules (Critical — read MIGRATION_RULES.md for full detail)
- **Never rewrite, always migrate.** One feature at a time. Old and new code coexist.
- **Never modify flavor configuration** (`main_dev.dart`, `main_prod.dart`, flavor configs) unless explicitly approved.
- **The Shippable Rule:** After every migration step, `flutter analyze` (zero errors), `flutter build apk`, and `flutter run` must all pass.
- **Max 5–8 files per commit.** If touching more, break into smaller steps.
- **Phase order is strict:** Foundations (Phase 3) must be complete before any feature migration (Phase 4) begins.

### Coding Standards
- Files and directories: `lowercase_snake_case`. Classes: `PascalCase`.
- One widget per file.
- Never use `print()` — use `debugPrint()` or logging through CrashlyticsService.
- Never commit commented-out code.
- UI layer never imports from `data/` — only from `domain/`.
- All colors via `AppColors` or `Theme.of(context).colorScheme` — no inline `Color(0xFF...)`.
- All text styles via `AppTextStyles` or `Theme.of(context).textTheme` — no inline `TextStyle()`.
- All spacing via `AppSpacing` — no magic number padding/margin.
- All endpoints in `ApiEndpoints` — no hardcoded URL strings.
- Import order: dart → flutter → packages (alphabetical) → project (alphabetical).

### Riverpod Rules
- Screens extend `ConsumerWidget` or `ConsumerStatefulWidget`.
- Never use `ref.read()` inside `build()` — always `ref.watch()`.
- Side effects (navigation, snackbar) via `ref.listen()`, never in `build()` logic.
- Never put UI code (showDialog, Navigator) inside Notifiers — emit state, let UI react.
- Use `.autoDispose` on screen-level providers. Never on global providers (DioClient, repositories).
- Use `CancelToken` with `ref.onDispose()` for cancelable API calls.
- Co-locate providers with their feature: `features/[name]/presentation/providers/`.

### Navigation Rules
- Every route must have a `name` property (used for analytics screen tracking).
- Never use `Navigator.push()` in migrated code — always `context.goNamed()` or `context.pushNamed()`.
- Route names are `lowercase_snake_case` and defined in `RouteNames` constants.

### Network Rules
- All API calls through `DioClient` (never raw `http` or `Dio()`).
- Repositories use `ExceptionHandler.guardAsync()` — no raw try/catch.
- Never return `dynamic` or `Map<String, dynamic>` from repositories — always typed models.
- Never pre-check connectivity before API calls — let request fail and catch exception.
- Interceptor order: Auth → Retry → Error → Logging (dev only).

### Testing Rules
- Every new feature must include unit tests for business logic and at least one widget test per screen.
- Use `mocktail` for mocking — no mockito.
- Test file naming: `<source_file>_test.dart`.
- Minimum 3 test cases per function: happy path, edge case, error case.
- Never make real API calls in unit or widget tests.

### Commit Format
```
type(scope): description

refactor(theme): extract hardcoded colors to AppColors
refactor(auth): migrate login screen to Riverpod
fix(network): add try/catch to putData and deleteData
test(auth): add unit tests for login notifier
chore(deps): add flutter_riverpod and go_router
```
