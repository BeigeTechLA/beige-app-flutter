# Firebase Integration Audit — Beige App

> Audited: 2026-04-19
> Target: Centralized FirebaseService, CrashlyticsService, AnalyticsService, analytics_events.dart constants (FLUTTER_BASE_GUIDELINES.md Part 5)

---

## Compliance Table

| Requirement | Status | Notes |
|---|---|---|
| Firebase SDK in pubspec.yaml | ❌ Not present | Zero Firebase packages declared |
| `google-services.json` (Android) | ❌ Not present | Not found anywhere in project |
| `GoogleService-Info.plist` (iOS) | ❌ Not present | Not found anywhere in project |
| Per-flavor Firebase projects (dev/prod) | ❌ Not present | Flavors exist but no Firebase config |
| `FirebaseService.initialize()` centralized | ❌ Not present | No initialization code anywhere |
| `FlutterError.onError` set for Crashlytics | ❌ Not present | No global Flutter error handler |
| `PlatformDispatcher.instance.onError` set | ❌ Not present | No platform error handler |
| `runZonedGuarded` wrapping `runApp` | ❌ Not present | Unhandled async errors are silent |
| `CrashlyticsService` class | ❌ Not present | — |
| `CrashlyticsKeys` constants file | ❌ Not present | — |
| User context set on login | ❌ Not present | — |
| User context cleared on logout | ❌ Not present | — |
| App flavor set as Crashlytics key | ❌ Not present | — |
| `AnalyticsService` class | ❌ Not present | — |
| `AnalyticsEvents` constants file | ❌ Not present | — |
| `FirebaseAnalytics.instance` calls = 0 | ✅ Zero | Zero only because Firebase doesn't exist |
| `AppAnalyticsObserver` on router | ❌ Not present | — |
| Screen tracking | ❌ Not present | — |
| Event tracking | ❌ Not present | — |
| Native auto-tracking disabled in manifests | ❌ Not configured | No Firebase = no config needed yet |

**Overall Firebase compliance: 0 / 19 requirements met.**

---

## 1. FIREBASE INITIALIZATION

**Firebase is not integrated at all.**

Exhaustive search results:
- `grep "firebase\|Firebase\|crashlytics\|analytics"` across all `.dart` files → **0 matches**
- `google-services.json` → **not found**
- `GoogleService-Info.plist` → **not found**
- `firebase.json` / `.firebaserc` → **not found**
- Firebase Gradle plugin in `build.gradle.kts` → **not found**
- `pubspec.yaml` Firebase packages → **0**

There is no `FirebaseService.initialize()`, no `Firebase.initializeApp()`, and no `WidgetsFlutterBinding.ensureInitialized()` call before Firebase init (though `ensureInitialized` is called for Stripe).

**Current `startApp()` in `main.dart`:**
```dart
Future<void> startApp(Environment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.init(environment);
  Stripe.publishableKey = Env.stripePublishableKey;
  // ← No Firebase.initializeApp()
  // ← No FlutterError.onError
  // ← No runZonedGuarded
  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(MyApp(isLoggedIn: isLoggedIn));
}
```

---

## 2. CRASHLYTICS

**Not integrated. Current error visibility: zero.**

### What happens to errors right now

There are **89 try/catch blocks** across the codebase. Their current error handling:

| Pattern | Count | What Happens to the Error |
|---|---|---|
| `catch (e) { print(e); setState(...) }` | ~40 | Printed to console only — invisible in production |
| `catch (e) { return {"error": true} }` | ~15 | Swallowed — caller checks map key |
| `catch (e) { return null; }` | ~8 | Silently returns null — UI shows empty state |
| `catch (e) { showToast(...) }` | ~12 | User sees generic message, error lost |
| `catch (e) { /* nothing */ }` | ~14 | Completely swallowed — no visibility |

**418 `print()` statements** exist across the codebase — the only current "logging" mechanism. All are invisible in production builds and none are sent anywhere for aggregation.

There is no:
- Crash reporting
- Non-fatal error reporting
- User identification on crash
- Custom key context (screen, action, user role)
- Stack trace aggregation

### Business impact

Every crash, unhandled exception, and API error that occurs in production is **completely invisible**. There is no way to know if users are experiencing crashes, which screens are crashing, or how often.

---

## 3. ANALYTICS

**Not integrated. Current user behavior visibility: zero.**

### What currently exists

Nothing. No analytics library, no event tracking, no screen tracking, no funnel data.

### What this means operationally

| User Action | Currently Tracked? |
|---|---|
| Login | ❌ No |
| Sign up | ❌ No |
| New booking started | ❌ No |
| Booking completed | ❌ No |
| Payment success | ❌ No |
| Payment failure | ❌ No |
| Profile edited | ❌ No |
| Booking cancelled | ❌ No |
| Screen views | ❌ No |
| Onboarding completion | ❌ No |

There is no way to answer: "How many users complete a booking?", "Where do users drop off in the booking flow?", or "How many logins happen per day?"

---

## 4. SCREEN TRACKING

**Not present.**

- No `NavigatorObserver` attached to `MaterialApp`
- `MaterialApp` in `main.dart` has no `navigatorObservers:` parameter
- No `AppAnalyticsObserver` class
- No screen name logging anywhere

---

## 5. ANALYTICS EVENT INVENTORY

**Zero analytics events are logged anywhere in the codebase.**

| Event Name | Where Logged | Uses Constant? | Has Parameters? |
|---|---|---|---|
| — | — | — | — |

---

## 6. WHAT NEEDS TO BE BUILT (TARGET STATE)

The following is the complete Firebase integration required per `FLUTTER_BASE_GUIDELINES.md Part 5`, in implementation order.

### Phase 1 — Setup (P1, prerequisite for everything)

**Step 1: Add packages to `pubspec.yaml`**
```yaml
dependencies:
  firebase_core: ^3.x.x
  firebase_analytics: ^11.x.x
  firebase_crashlytics: ^4.x.x
```

**Step 2: Create Firebase projects**
- One Firebase project for `dev` flavor
- One Firebase project for `prod` flavor
- Download per-flavor config files:
  - Android: `android/app/src/dev/google-services.json` and `android/app/src/prod/google-services.json`
  - iOS: Per-scheme `GoogleService-Info.plist` referenced in xcconfig

**Step 3: Apply Gradle plugins**
```kotlin
// android/app/build.gradle.kts
plugins {
  id("com.google.gms.google-services")
  id("com.google.firebase.crashlytics")
}
```

---

### Phase 2 — Core Services (P1)

**`lib/core/firebase/firebase_service.dart`**
```dart
class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
```

**`lib/core/firebase/crashlytics_service.dart`**
```dart
class CrashlyticsService {
  static Future<void> initialize() async {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  }

  static Future<void> setUserContext({required int userId, required String email}) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(userId.toString());
    await FirebaseCrashlytics.instance.setCustomKey(CrashlyticsKeys.userEmail, email);
  }

  static Future<void> clearUserContext() async {
    await FirebaseCrashlytics.instance.setUserIdentifier('');
  }

  static Future<void> recordError(Object error, StackTrace stack, {bool fatal = false}) async {
    await FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal);
  }
}
```

**`lib/core/firebase/crashlytics_keys.dart`**
```dart
class CrashlyticsKeys {
  static const String flavor       = 'flavor';
  static const String userEmail    = 'user_email';
  static const String userRole     = 'user_role';
  static const String lastScreen   = 'last_screen';
  static const String lastAction   = 'last_action';
}
```

**`lib/core/firebase/analytics_service.dart`**
```dart
class AnalyticsService {
  static final _analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  static Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    if (kDebugMode) return;  // No analytics noise in dev
    await _analytics.logEvent(name: name, parameters: params);
  }

  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}
```

**`lib/core/firebase/analytics_events.dart`**
```dart
// All event names: lowercase_snake_case, max 40 chars
class AnalyticsEvents {
  // Auth
  static const String login            = 'login';
  static const String signUp           = 'sign_up';
  static const String logout           = 'logout';
  static const String forgotPassword   = 'forgot_password';
  static const String passwordReset    = 'password_reset';

  // Booking flow
  static const String bookingStarted   = 'booking_started';
  static const String bookingStepContent   = 'booking_step_content_type';
  static const String bookingStepDateTime  = 'booking_step_date_time';
  static const String bookingStepDetails   = 'booking_step_details';
  static const String bookingStepCrew      = 'booking_step_crew';
  static const String bookingStepReview    = 'booking_step_review';
  static const String bookingCompleted     = 'booking_completed';
  static const String bookingCancelled     = 'booking_cancelled';

  // Payment
  static const String paymentInitiated = 'payment_initiated';
  static const String paymentSuccess   = 'payment_success';
  static const String paymentFailed    = 'payment_failed';

  // Profile
  static const String profileViewed    = 'profile_viewed';
  static const String profileUpdated   = 'profile_updated';
  static const String creativeViewed   = 'creative_viewed';
  static const String favouriteAdded   = 'favourite_added';
  static const String favouriteRemoved = 'favourite_removed';

  // Account
  static const String accountDeleted   = 'account_deleted';
}
```

**Updated `startApp()` in `main.dart`**
```dart
Future<void> startApp(Environment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.init(environment);
  Stripe.publishableKey = Env.stripePublishableKey;

  await FirebaseService.initialize();
  await CrashlyticsService.initialize();
  await FirebaseCrashlytics.instance.setCustomKey(
    CrashlyticsKeys.flavor,
    environment.name,  // 'dev' or 'prod'
  );

  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runZonedGuarded(
    () => runApp(MyApp(isLoggedIn: isLoggedIn)),
    (error, stack) => CrashlyticsService.recordError(error, stack, fatal: true),
  );
}
```

---

### Phase 3 — Wiring (P2)

**Attach observer to `MaterialApp`:**
```dart
MaterialApp(
  navigatorObservers: [AnalyticsService.observer],
  ...
)
```

**Set user context on login (`new_login_screen.dart`):**
```dart
// After successful login:
await AnalyticsService.setUserId(userId.toString());
await CrashlyticsService.setUserContext(userId: userId, email: email);
await AnalyticsService.logEvent(AnalyticsEvents.login);
```

**Clear context on logout (`my_profile.dart`):**
```dart
await AnalyticsService.logEvent(AnalyticsEvents.logout);
await CrashlyticsService.clearUserContext();
await AnalyticsService.setUserId('');
```

**Log booking funnel events (each step in NewBookingFlow):**
```dart
// ContentTypeScreen — step entry
await AnalyticsService.logEvent(AnalyticsEvents.bookingStepContent);

// PaymentSuccessScreen — funnel completion
await AnalyticsService.logEvent(AnalyticsEvents.bookingCompleted, params: {
  'booking_id': bookingId,
  'payment_method': paymentMethod,
});
```

**Replace all 89 `catch (e) { print(e) }` blocks:**
```dart
// Before (current):
} catch (e) {
  print(e);
}

// After (target):
} catch (e, stack) {
  CrashlyticsService.recordError(e, stack);
}
```

---

### Phase 4 — AndroidManifest & Info.plist (P2)

Disable native auto-collection to avoid duplicate screen events from Firebase's automatic tracking (controlled manually via `AnalyticsService.logScreenView`):

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<meta-data
  android:name="google_analytics_automatic_screen_reporting_enabled"
  android:value="false" />
```

```xml
<!-- ios/Runner/Info.plist -->
<key>FIREBASE_ANALYTICS_COLLECTION_ENABLED</key>
<false/>
```

---

## 7. PRIORITY ORDER

| Priority | Task | Blocking? |
|---|---|---|
| **P1** | Create Firebase projects (dev + prod), download config files | Yes — nothing else works without this |
| **P1** | Add `firebase_core`, `firebase_crashlytics`, `firebase_analytics` to pubspec | Yes |
| **P1** | Apply Gradle plugin + update iOS setup | Yes |
| **P1** | Create `FirebaseService`, `CrashlyticsService`, update `startApp()` with `runZonedGuarded` | Yes — crash visibility is a release blocker |
| **P1** | Set `FlutterError.onError` + `PlatformDispatcher.instance.onError` | Yes |
| **P1** | Replace all `catch (e) { print(e) }` with `CrashlyticsService.recordError` | Yes |
| **P2** | Create `AnalyticsService` + `AnalyticsEvents` constants | No |
| **P2** | Attach `AnalyticsService.observer` to `MaterialApp` | No |
| **P2** | Log user context on login/logout | No |
| **P2** | Log booking funnel events (6 steps) | No |
| **P2** | Log payment success/failure | No |
| **P2** | Disable native auto-tracking in manifests | No |
| **P3** | Log all remaining events (favourites, profile, creative viewed) | No |
| **P3** | Set `CrashlyticsKeys.lastScreen` from `AnalyticsObserver` | No |
