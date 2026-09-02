›# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Workflow Rules

- **Always ask questions before writing a plan.** Before proposing or executing any plan, ask clarifying questions to understand scope, constraints, and preferences. Do not assume — confirm first, then plan.
- **Never write code without approval.** Do not start implementation until the user explicitly approves the plan.
- **Plan phase-wise in small chunks, in a table.** Break every plan into phases, each containing small, discrete tasks. Present phases as a table with scrum-style task IDs (Phase 1 → Task 1.1, Task 1.2; Phase 2 → Task 2.1, ...). End the full plan with a single manual test summary describing what the user should verify. Table columns: Task ID, Description, Files, Status.
- **Track status in the plan.** Every task carries a status with a color indicator: 🔴 Not Started, 🟡 In Progress, 🟢 Completed.
- **Reference impacted files in the plan.** For large-level changes or new functionality, list the files that will be changed or added in the plan file.
- **Prompt for CLAUDE.md update after new features.** After completing a new feature, ask the user whether CLAUDE.md should be updated.

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

# Run integration tests (navigation)
flutter test integration_test/navigation_test.dart

# Regenerate launcher icons
flutter pub run flutter_launcher_icons:main
```

## What This App Is

**Beige** is a Flutter app for booking photography/videography services. Users are either **Clients** (who book shoots) or **Creatives** (who offer services). The app has 39 screens, ~34,264 lines of Dart across 144 files.

## Current Architecture (Post-Migration)

Migration from legacy to clean architecture is **complete** (Phases 1-4 done, Phase 5 cleanup in progress). All 39 screens are migrated.

### Stack (Current)
| Layer | Technology |
|-------|-----------|
| State management | `flutter_riverpod` — Notifier/AsyncNotifier with autoDispose |
| Navigation | `go_router` with `StatefulShellRoute.indexedStack`, auth redirect |
| HTTP client | `Dio` with interceptor chain (Auth → Retry → Error → Logging) |
| Error handling | Sealed `AppException` hierarchy + `ExceptionHandler.guardAsync()` |
| Firebase | `firebase_core` + `firebase_crashlytics` + `firebase_analytics` |
| Design tokens | `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadii`, `AppShadows`, `AppDurations`, `AppTheme` |
| Payment | Stripe via `flutter_stripe` |
| Maps | `google_maps_flutter`, `geolocator`, `google_places_flutter` |

### Entry Points & Flavors
- `lib/main.dart` — shared `startApp(Environment)` function (Firebase init, Crashlytics, Stripe, ProviderScope)
- `lib/main_dev.dart` → `startApp(Environment.dev)`
- `lib/main_prod.dart` → `startApp(Environment.prod)`
- `lib/config/env.dart` — `Env.init()` sets API URL, image URL, Stripe key per environment
- Both flavors currently point to same API: `https://mobile.beige.app/api/`
- Prod Stripe key is placeholder: `'PLACE_HOLDER_LIVE_STRIPE_KEY'`

### Folder Structure
```
lib/
├── main.dart / main_dev.dart / main_prod.dart
├── app/                          # Design tokens, router, theme
│   ├── colors.dart, text_styles.dart, spacing.dart, radii.dart
│   ├── shadows.dart, durations.dart, assets.dart
│   ├── theme.dart, router.dart, route_names.dart, app.dart
├── config/
│   └── env.dart                  # Environment config (dev/prod)
├── core/
│   ├── network/                  # DioClient, api_endpoints, api_response
│   │   ├── exceptions/           # AppException, ClientException, ServerException, NetworkException, ExceptionHandler
│   │   └── interceptors/         # auth, retry, error, logging
│   ├── firebase/                 # FirebaseService, CrashlyticsService, AnalyticsService, events, observer
│   ├── providers/                # sharedPreferencesProvider, dioClientProvider, authStateProvider
│   └── utils/                    # date_time_utils, google_config, internet_helper, shared_service
├── features/
│   ├── auth/                     # 6 screens — login, signup, forgot password, OTP, reset
│   ├── booking/                  # 9 screens — shoot type, crew, date/time, details, review, payment
│   ├── creative/                 # creative profile data/domain (no screens — used by home)
│   ├── home/                     # 5 screens — home, find creative, creative profile, change location
│   ├── onboarding/               # 1 screen
│   ├── payment/                  # payment data/domain layer (screens in booking/)
│   ├── profile/                  # 11 screens — profile, edit, favorites, history, delete, password, preferences
│   ├── shoot/                    # 7 screens — my shoots, manage, cancel, edit review, summary, type selection
│   └── splash/                   # 1 screen
└── shared/
    ├── layouts/                  # AppScaffold
    └── widgets/                  # custom_input_field, loading, top_message
```

### Feature Architecture Pattern
Each feature follows clean architecture:
```
features/[name]/
├── data/
│   ├── datasources/    # Remote datasource — raw API calls via DioClient
│   ├── models/         # Data models (where needed)
│   └── repositories/   # Repository impl — wraps datasource with ExceptionHandler
├── domain/
│   ├── entities/       # Domain entities (where needed)
│   └── repositories/   # Repository interface (abstract class)
└── presentation/
    ├── providers/      # Notifier + State classes, provider declarations
    └── screens/        # ConsumerStatefulWidget / ConsumerWidget screens
```

### Navigation
- `lib/app/router.dart` — GoRouter with `routerProvider` (Riverpod)
- `lib/app/route_names.dart` — `RouteNames` constants (lowercase_snake_case)
- `StatefulShellRoute.indexedStack` for 4-tab bottom nav (Home, Book, My Shoots, Profile)
- Auth guard via `redirect` — checks `authStateProvider`, redirects unauthenticated to login
- `lib/core/providers/auth_state_provider.dart` — bool-based auth state

### Repositories
| Repository | Feature | Methods |
|-----------|---------|---------|
| AuthRepository | auth | login, signup, forgotPassword, verifyOtp, resetPassword, socialLogin |
| ProfileRepository | profile | getProfile, updateProfile, uploadPhoto, changePassword, deleteAccount, verifyDeleteOtp, getFavorites, removeFavorite, getBookingHistory |
| HomeRepository | home | getHomeData, getRecommendedCreatives |
| CreativeRepository | creative | getCreativeProfile |
| BookingRepository | booking | 11 methods — shoot types, content types, crew matching, booking CRUD |
| PaymentRepository | payment | createPaymentIntent, confirmPayment, getPaymentMethods, addPaymentMethod |
| ShootRepository | shoot | getMyShoots, getShootSummary, cancelShoot, updateShoot |

## Rules

### General
- All planning and design `.md` files must be stored in the `docs/` folder at the project root.
- Audit reports go in `docs/auditreports/`.
- Architecture guides go in `docs/guides/`.

### Coding Standards
- Files and directories: `lowercase_snake_case`. Classes: `PascalCase`.
- One widget per file.
- Never use `print()` — use `debugPrint()` or `CrashlyticsService.recordError()`.
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
- Never use `Navigator.push()` — always `context.goNamed()` or `context.pushNamed()`.
- Route names are `lowercase_snake_case` and defined in `RouteNames` constants.

### Network Rules
- All API calls through `DioClient` (never raw `http` or `Dio()`).
- Repositories use `ExceptionHandler.guardAsync()` — no raw try/catch.
- Never return `dynamic` or `Map<String, dynamic>` from repositories — always typed models.
- Never pre-check connectivity before API calls — let request fail and catch exception.
- Interceptor order: Auth → Retry → Error → Logging (dev only).
- DataSource returns raw Map, Repository wraps in ExceptionHandler and maps to entity.
- `_assertNoError()` helper in repository checks Beige API `{error: true, message: "..."}` pattern.

### Testing Rules
- Every new feature must include unit tests for business logic and at least one widget test per screen.
- Use `mocktail` for mocking — no mockito.
- Test file naming: `<source_file>_test.dart`.
- Minimum 3 test cases per function: happy path, edge case, error case.
- Never make real API calls in unit or widget tests.

## Navigation Testing Tool

Integration test suite lives in `integration_test/` folder.

### Structure
- `navigation_test.dart` — main runner
- `helpers/navigation_helper.dart` — pumpAppWithAuth, verifyScreenLoaded, verifyAuthGuard, verifyDeepLink, verifyBackNav
- `helpers/auth_helper.dart` — Riverpod overrides for auth bypass
- `helpers/report_builder.dart` — writes navigation_report.md
- `cases/route_load_test.dart` — route load tests
- `cases/guard_test.dart` — auth guard redirect tests
- `cases/deep_link_test.dart` — URI resolution tests
- `cases/back_nav_test.dart` — back stack tests

### Pending wiring (not done yet)
1. `navigation_helper.dart` → replace `Placeholder` with actual App widget
2. `auth_helper.dart` → uncomment authStateProvider overrides
3. Routes with `state.extra` params need fake data added in `route_load_test.dart`

### Run command
```bash
flutter test integration_test/navigation_test.dart
```

### Commit Format
```
type(scope): description

refactor(theme): extract hardcoded colors to AppColors
refactor(auth): migrate login screen to Riverpod
fix(network): add try/catch to putData and deleteData
test(auth): add unit tests for login notifier
chore(deps): add flutter_riverpod and go_router
```

## Slash Commands

Custom slash commands for repetitive feature development patterns. Located in `.claude/commands/`.

| Command | Purpose |
|---------|---------|
| `/new-feature` | Scaffold complete feature module (datasource, repo interface, repo impl, providers) |
| `/new-screen` | Add screen + notifier + state to existing feature, wire route |
| `/new-endpoint` | Add API method across all 4 layers (endpoint, datasource, repo interface, repo impl) |
| `/add-route` | Quick-add GoRoute + RouteNames constant |

### Typical Workflow for New Feature

```
1. /new-feature          → scaffold module (data + domain + presentation dirs)
2. /new-endpoint         → add API methods (repeat per endpoint)
3. /new-screen           → add screens with notifiers (repeat per screen)
4. /add-route            → add extra routes if needed beyond what /new-screen wires
```

### Usage Examples

**Adding a "Notifications" feature from scratch:**
```
/new-feature             → input: notifications
/new-endpoint            → input: notifications, getNotifications, GET, notifications/list, none, List<NotificationModel>
/new-endpoint            → input: notifications, markAsRead, PUT, notifications/read, id:String, String
/new-screen              → input: notifications, notification_list (data-fetch screen)
/new-screen              → input: notifications, notification_detail (action-triggered screen)
```

**Adding a new screen to existing feature:**
```
/new-screen              → input: profile, change_email
/new-endpoint            → input: profile, changeEmail, POST, auth/change-email, email:String, String
```

**Just adding a route for an existing screen:**
```
/add-route               → input: change_email, ChangeEmailScreen, ../features/profile/..., yes (auth), no (no extra params)
```

## Remaining Work

### Phase 5 — Cleanup (IN PROGRESS)
- [ ] Replace 111 `.withOpacity()` calls with `.withValues()` (deprecated API)
- [ ] Replace 1 remaining `print()` with `debugPrint()` (`shoot_date_time_screen.dart`)
- [ ] Fix 22 warnings from `flutter analyze` (unused vars, dead code, unused imports)
- [ ] Fix 191 info-level lint issues
- [ ] Clean up `docs/` planning files (many are now obsolete post-migration)

### Phase 6 — Testing (NOT STARTED)
- [ ] Wire up navigation integration tests (see pending wiring above)
- [ ] Add unit tests for all Notifiers
- [ ] Add widget tests for screens
- [ ] Target: 70%+ coverage
- [ ] Testing patterns in `docs/guides/FLUTTER_TESTING_GUIDELINES.md`