# Group 5: Book a Shoot — Migration Plan

> Created: 2026-04-24
> Branch: `improvments-phase1`
> Estimated Screens: 10 | Total Lines: ~13,085
> Dependencies: Groups 1-4 (complete), Group 6 (complete)

---

## Overview

Migrate the entire "Book a Shoot" multi-step flow from `ApiService`/`setState` to `DioClient`/`Riverpod`. This is the largest migration group — 10 screens, 23 API calls, 2 new repositories.

### Booking Flow (User Journey)
```
ContentType → ShootType → ShootDateTime → ShootDetails
    → CrewSizeMatching → CrewSelection → ShootReview
    → PaymentMethod → PaymentSuccess
```
`ShootTypeSelectionScreen` is the edit/reschedule variant of `ShootDateTimeScreen`.

---

## Status Tracker

| Task | Description | Status | Files Changed | Commit |
|------|-------------|--------|---------------|--------|
| T1 | BookingRepository infrastructure | COMPLETE | 4 new | — |
| T2 | PaymentRepository infrastructure | COMPLETE | 4 new | — |
| T3 | ContentTypeScreen (#24) | COMPLETE | 1 new + 1 mod | — |
| T4 | ShootTypeScreen (#25) | COMPLETE | 1 new + 1 mod | — |
| T5 | ShootDateTimeScreen (#26) | COMPLETE | 1 new + 1 mod | — |
| T6 | ShootDetailsScreen (#27) | COMPLETE | 1 new + 1 mod | — |
| T7 | CrewSizeMatchingScreen (#28) | COMPLETE | 1 new + 1 mod | — |
| T8 | CrewSelectionScreen (#29) | COMPLETE | 1 new + 1 mod | — |
| T9 | ShootReviewScreen (#30) | COMPLETE | 1 new + 1 mod | — |
| T10 | PaymentMethodScreen (#31) + PaymentSuccessScreen (#32) | COMPLETE | 1 new + 2 mod | — |
| T11 | ShootTypeSelectionScreen (#33) | COMPLETE | 1 new + 1 mod | — |

---

## T1: BookingRepository Infrastructure

**Goal:** Create the repository layer for all booking operations (excludes payment).

**New files (4):**
```
lib/features/booking/domain/repositories/booking_repository.dart      # Abstract interface
lib/features/booking/data/datasources/booking_remote_datasource.dart  # Raw Dio calls
lib/features/booking/data/repositories/booking_repository_impl.dart   # ExceptionHandler.guardAsync
lib/features/booking/presentation/providers/booking_providers.dart    # Provider wiring
```

**Interface — 10 methods:**

```dart
abstract class BookingRepository {
  // Shoot type & configuration
  Future<Either<AppException, Map<String, dynamic>>> updateBooking({
    required int bookingId,
    required Map<String, dynamic> data,
  });

  Future<Either<AppException, List<dynamic>>> getEditTypes({
    required int shootTypeId,
  });

  // Date & time
  Future<Either<AppException, Map<String, dynamic>>> updateBookingTime({
    required int bookingId,
    required Map<String, dynamic> data,
  });

  Future<Either<AppException, Map<String, dynamic>>> getBookingTime({
    required int bookingId,
  });

  // Shoot details (location, crew requirements)
  Future<Either<AppException, Map<String, dynamic>>> updateBookingDetails({
    required int bookingId,
    required Map<String, dynamic> data,
  });

  // Crew matching
  Future<Either<AppException, Map<String, dynamic>>> getCrewRecommendation({
    required int bookingId,
  });

  Future<Either<AppException, Map<String, dynamic>>> getCrewMatches({
    required int bookingId,
    required String sort,
    int page = 1,
    int limit = 400,
  });

  Future<Either<AppException, Map<String, dynamic>>> getHolds({
    required int bookingId,
  });

  Future<Either<AppException, Map<String, dynamic>>> addHold({
    required int bookingId,
    required int crewMemberId,
    required int roleId,
  });

  Future<Either<AppException, Map<String, dynamic>>> removeHold({
    required int bookingId,
    required int crewMemberId,
  });
}
```

**Reused repositories (NO duplication):**
- `HomeRepository.createBooking()` — already handles POST `bookings`
- `HomeRepository.getShootTypes()` — already handles GET `bookings/shoot-types/{id}`
- `ShootRepository.getBookingSummary()` — already handles GET `bookings/{id}/summary-details`
- `ProfileRepository.addFavourite/removeFavourite` — crew favourites

**Acceptance criteria:**
- [ ] `flutter analyze` — 0 errors
- [ ] Provider chain compiles: `bookingRepositoryProvider` → `BookingRepositoryImpl` → `BookingRemoteDataSource` → `DioClient`

---

## T2: PaymentRepository Infrastructure

**Goal:** Create the repository layer for Stripe payment operations.

**New files (4):**
```
lib/features/payment/domain/repositories/payment_repository.dart
lib/features/payment/data/datasources/payment_remote_datasource.dart
lib/features/payment/data/repositories/payment_repository_impl.dart
lib/features/payment/presentation/providers/payment_providers.dart
```

**Interface — 4 methods:**

```dart
abstract class PaymentRepository {
  Future<Either<AppException, Map<String, dynamic>>> getSavedPaymentMethods();

  Future<Either<AppException, Map<String, dynamic>>> createPaymentSheet({
    required int bookingId,
  });

  Future<Either<AppException, Map<String, dynamic>>> updatePaymentInfo({
    required int bookingId,
    required Map<String, dynamic> data,
  });

  Future<Either<AppException, Map<String, dynamic>>> confirmStripePayment({
    required int bookingId,
    required String paymentIntentId,
  });
}
```

**Acceptance criteria:**
- [ ] `flutter analyze` — 0 errors
- [ ] `paymentRepositoryProvider` compiles and wires correctly

---

## T3: ContentTypeScreen (#24) — 566 lines

**File:** `lib/Home/book_shoot/content_type_screen.dart`

**Current API calls:**
1. `fetchData` → `bookings/shoot-types/{contentTypeId}` — load shoot types
2. `postData` → `bookings` — create/continue booking

**Migration approach:**
- Create `ContentTypeNotifier` (AutoDisposeNotifier)
- State: `{status, shootTypeIds, bookingId, errorMessage}`
- Methods: `loadShootTypes(contentTypeId)` via HomeRepository, `createBooking(data)` via HomeRepository
- Screen: `StatefulWidget` → `ConsumerStatefulWidget`
- Replace `ApiService().fetchData()` → `ref.read(contentTypeNotifierProvider.notifier).loadShootTypes()`
- Replace `ApiService().postData()` → `ref.read(contentTypeNotifierProvider.notifier).createBooking()`
- Use `ref.listen()` for navigation on booking creation success

**New file:** `lib/features/booking/presentation/providers/content_type_notifier.dart`

**Acceptance criteria:**
- [ ] `flutter analyze` — 0 errors
- [ ] Screen loads, content types display
- [ ] Creating booking navigates to ShootTypeScreen with bookingId

---

## T4: ShootTypeScreen (#25) — 546 lines

**File:** `lib/Home/book_shoot/shoot_type_screen.dart`

**Current API calls:**
1. `fetchData` → `bookings/shoot-types/{contentTypeId}` — load available shoot types
2. `postData` → `bookings/{bookingId}` — update booking with shoot type

**Migration approach:**
- Create `ShootTypeNotifier` (AutoDisposeFamilyNotifier<State, int> keyed by bookingId)
- State: `{status, shootTypes list, errorMessage, isSaving}`
- Methods: `loadShootTypes(contentTypeId)` via HomeRepository, `selectShootType(data)` via BookingRepository
- Screen: `StatefulWidget` → `ConsumerStatefulWidget`
- `ref.watch()` for loading state, `ref.listen()` for navigation on success

**New file:** `lib/features/booking/presentation/providers/shoot_type_notifier.dart`

**Acceptance criteria:**
- [ ] Shoot types load with images and tags
- [ ] Selecting shoot type updates booking and navigates to ShootDateTimeScreen

---

## T5: ShootDateTimeScreen (#26) — 3,139 lines (GOD WIDGET)

**File:** `lib/Home/book_shoot/shoot_date_time_screen.dart`

**Current API calls:**
1. `fetchData` → `bookings/shoot-types/{shootTypeId}/edit-types` — load photo/video edit options
2. `putData` → `bookings/{bookingId}/time` — save date/time/edit selections

**Migration approach:**
- Create `ShootDateTimeNotifier` (AutoDisposeFamilyNotifier<State, int> keyed by bookingId)
- State: `{status, photoEditTypes, videoEditTypes, isSaving, errorMessage}`
- Complex date/time/multi-day UI logic STAYS in screen (not worth extracting yet)
- Only API interaction moves to notifier
- Screen: `StatefulWidget` → `ConsumerStatefulWidget`

**New file:** `lib/features/booking/presentation/providers/shoot_date_time_notifier.dart`

**Risk:** Largest screen. High complexity in date picker, multi-day logic. Migration touches only API layer, not UI logic.

**Acceptance criteria:**
- [ ] Edit types load for both photo and video
- [ ] Single-day and multi-day booking saves correctly
- [ ] Navigates to ShootDetailsScreen on success

---

## T6: ShootDetailsScreen (#27) — 1,269 lines

**File:** `lib/Home/book_shoot/shoot_details_screen.dart`

**Current API calls:**
1. `putData` → `bookings/{bookingId}/details` — save location, crew requirements, additional details

**Migration approach:**
- Create `ShootDetailsNotifier` (AutoDisposeFamilyNotifier<State, int>)
- State: `{status, isSaving, errorMessage}`
- Method: `saveDetails(bookingId, data)` via BookingRepository.updateBookingDetails
- **Fixes audit bug #5:** putData has no try/catch — now handled by ExceptionHandler.guardAsync
- Screen: `StatefulWidget` → `ConsumerStatefulWidget`
- Google Maps / geolocation logic stays in screen

**New file:** `lib/features/booking/presentation/providers/shoot_details_notifier.dart`

**Acceptance criteria:**
- [ ] Location picker works
- [ ] Saving details navigates to CrewSizeMatchingScreen
- [ ] Network errors show error state (not crash — fixes bug #5)

---

## T7: CrewSizeMatchingScreen (#28) — 790 lines

**File:** `lib/Home/book_shoot/crew_size_matching_screen.dart`

**Current API calls:**
1. `fetchData` → `bookings/{bookingId}/crew-recommendation` — AI crew recommendation

**Migration approach:**
- Create `CrewRecommendationNotifier` (AutoDisposeFamilyNotifier<State, int>)
- State: `{status, shootType, recommendedCrew, defaultOutput, reasoning, errorMessage}`
- Method: `fetchRecommendation(bookingId)` via BookingRepository
- Screen: `StatefulWidget` → `ConsumerStatefulWidget`

**New file:** `lib/features/booking/presentation/providers/crew_recommendation_notifier.dart`

**Acceptance criteria:**
- [ ] Crew recommendation loads with min/max, roles, reasoning
- [ ] Continue button navigates to CrewSelectionScreen

---

## T8: CrewSelectionScreen (#29) — 2,314 lines (GOD WIDGET)

**File:** `lib/Home/book_shoot/crew_selection_screen.dart`

**Current API calls (7 total — most complex screen):**
1. `fetchData` → `bookings/{id}/matches?sort=nearest&page=1&limit=400` — load crew matches
2. `fetchData` → `bookings/{id}/holds` — load current holds
3. `fetchData` → `bookings/{id}/matches?sort={sort}` — filter crew
4. `postData` → `bookings/{id}/hold` — add hold (crewMemberId, roleId)
5. `postData` → `bookings/{id}/hold/remove` — remove hold
6. `postData` → `creatives/favourites/{userId}` — add favourite (reuse ProfileRepository)
7. `deleteData` → `creatives/favourites/{userId}` — remove favourite (reuse ProfileRepository)

**Migration approach:**
- Create `CrewSelectionNotifier` (AutoDisposeFamilyNotifier<State, int>)
- State: `{status, nearbyCreators, otherCreators, crewRequirements, heldCreatives, addedCrewUserIds, errorMessage}`
- Methods: `fetchMatches()`, `fetchHolds()`, `filterCrew(sort)`, `addHold(crewMemberId, roleId)`, `removeHold(crewMemberId)`
- Favourite operations use existing `ProfileRepository` via separate ref.read
- Screen: `StatefulWidget` → `ConsumerStatefulWidget`

**New file:** `lib/features/booking/presentation/providers/crew_selection_notifier.dart`

**Risk:** Most API calls of any screen. Hold add/remove need optimistic UI or loading indicators.

**Acceptance criteria:**
- [ ] Crew matches load, split into nearby/other
- [ ] Sort filter works (Top Rated, Nearest, Newest)
- [ ] Add/remove holds works with snackbar feedback
- [ ] Favourite toggle works

---

## T9: ShootReviewScreen (#30) — 1,538 lines

**File:** `lib/Home/book_shoot/shoot_review_screen.dart`

**Current API calls (4 total):**
1. `fetchData` → `bookings/{id}/summary-details` — full booking summary (reuse ShootRepository)
2. `postData` → `bookings/{id}/paymentsheet` — create Stripe payment sheet
3. `putData` → `bookings/{id}/payment` — save contact info & payment method
4. `postData` → `payment/{id}/stripe/confirm` — confirm payment

**Migration approach:**
- Create `BookingReviewNotifier` (AutoDisposeFamilyNotifier<State, int>)
- State: `{status, booking, pricing, heldCreatives, crewSummary, savedCards, paymentClientSecret, isSaving, errorMessage}`
- Methods: `fetchSummary()` via ShootRepository, `createPaymentSheet()`, `savePaymentInfo()`, `confirmPayment()` via PaymentRepository
- Stripe payment sheet integration stays in screen (Flutter SDK requires BuildContext)
- Screen: `StatefulWidget` → `ConsumerStatefulWidget`

**New file:** `lib/features/booking/presentation/providers/booking_review_notifier.dart`

**Risk:** Stripe integration complexity. Payment flow is 6-step process.

**Acceptance criteria:**
- [ ] Summary loads with pricing, crew, booking details
- [ ] Contact form validates
- [ ] Stripe payment sheet presents and processes
- [ ] Payment confirmation navigates to PaymentSuccessScreen

---

## T10: PaymentMethodScreen (#31) + PaymentSuccessScreen (#32) — 578 lines combined

**Files:**
- `lib/Home/book_shoot/payment_method_screen.dart` (477 lines)
- `lib/Home/book_shoot/payment_success_screen.dart` (101 lines)

**Current API calls (PaymentMethodScreen — 3):**
1. `fetchData` → `payment` — load saved payment methods
2. `postData` → `bookings/{id}/paymentsheet` — create payment sheet
3. `postData` → `payment/{id}/stripe/confirm` — confirm payment

**PaymentSuccessScreen:** Zero API calls. `StatelessWidget` → `ConsumerWidget` (pure swap).

**Migration approach:**
- Create `PaymentMethodNotifier` (AutoDisposeFamilyNotifier<State, int>)
- State: `{status, savedCards, recommended, paymentClientSecret, isProcessing, errorMessage}`
- Methods: `fetchPaymentMethods()`, `createPaymentSheet()`, `confirmPayment()` via PaymentRepository
- PaymentSuccessScreen: just swap to ConsumerWidget, no notifier needed

**New file:** `lib/features/payment/presentation/providers/payment_method_notifier.dart`

**Acceptance criteria:**
- [ ] Saved cards load
- [ ] Stripe payment sheet works
- [ ] PaymentSuccessScreen displays booking confirmation

---

## T11: ShootTypeSelectionScreen (#33) — 2,345 lines

**File:** `lib/my_shoot/shoot_type_selection_screen.dart`

**Current API calls (1 — edit/reschedule mode):**
1. `fetchData` → `bookings/{bookingId}/time` — load existing booking time data for editing

**Migration approach:**
- Create `ShootTypeSelectionNotifier` (AutoDisposeFamilyNotifier<State, int>)
- State: `{status, bookingTimeData, errorMessage}`
- Method: `fetchBookingTime(bookingId)` via BookingRepository.getBookingTime
- Complex date/time restore logic stays in screen
- Screen: `StatefulWidget` → `ConsumerStatefulWidget`

**New file:** `lib/features/booking/presentation/providers/shoot_type_selection_notifier.dart`

**Acceptance criteria:**
- [ ] Existing booking time data loads and populates form
- [ ] Single-day and multi-day restore correctly

---

## Architecture Summary

### New Feature Structure
```
lib/features/booking/
├── data/
│   ├── datasources/
│   │   └── booking_remote_datasource.dart       # 10 Dio methods
│   └── repositories/
│       └── booking_repository_impl.dart         # ExceptionHandler.guardAsync
├── domain/
│   └── repositories/
│       └── booking_repository.dart              # Abstract interface
└── presentation/
    └── providers/
        ├── booking_providers.dart                # Provider wiring
        ├── content_type_notifier.dart            # T3
        ├── shoot_type_notifier.dart              # T4
        ├── shoot_date_time_notifier.dart         # T5
        ├── shoot_details_notifier.dart           # T6
        ├── crew_recommendation_notifier.dart     # T7
        ├── crew_selection_notifier.dart          # T8
        ├── booking_review_notifier.dart          # T9
        └── shoot_type_selection_notifier.dart    # T11

lib/features/payment/
├── data/
│   ├── datasources/
│   │   └── payment_remote_datasource.dart       # 4 Dio methods
│   └── repositories/
│       └── payment_repository_impl.dart
├── domain/
│   └── repositories/
│       └── payment_repository.dart
└── presentation/
    └── providers/
        ├── payment_providers.dart
        └── payment_method_notifier.dart          # T10
```

### Screens (stay in-place, modified only)
```
lib/Home/book_shoot/
├── content_type_screen.dart       # T3 — ConsumerStatefulWidget
├── shoot_type_screen.dart         # T4 — ConsumerStatefulWidget
├── shoot_date_time_screen.dart    # T5 — ConsumerStatefulWidget
├── shoot_details_screen.dart      # T6 — ConsumerStatefulWidget
├── crew_size_matching_screen.dart # T7 — ConsumerStatefulWidget
├── crew_selection_screen.dart     # T8 — ConsumerStatefulWidget
├── shoot_review_screen.dart       # T9 — ConsumerStatefulWidget
├── payment_method_screen.dart     # T10 — ConsumerStatefulWidget
└── payment_success_screen.dart    # T10 — ConsumerWidget

lib/my_shoot/
└── shoot_type_selection_screen.dart # T11 — ConsumerStatefulWidget
```

### File Count
| Category | New Files | Modified Files | Total |
|----------|-----------|---------------|-------|
| BookingRepository infra (T1) | 4 | 0 | 4 |
| PaymentRepository infra (T2) | 4 | 0 | 4 |
| Notifiers (T3-T11) | 9 | 0 | 9 |
| Screen migrations (T3-T11) | 0 | 10 | 10 |
| **Total** | **17** | **10** | **27** |

---

## Key Rules (from MIGRATION_RULES.md)

- NO `state = state.copyWith(status: loading)` in fetch methods called from `build()`
- `ref.watch()` in `build()`, `ref.read()` for actions
- `ref.listen()` for side effects (navigation, snackbar)
- `ExceptionHandler.guardAsync()` wraps all repository calls
- `_assertNoError()` pattern for `{error: true}` API responses
- Remove all `print()` → use `debugPrint()` only where needed
- Add `mounted` check after every `await` in screen code
- Max 5-8 files per commit

## Verification (after each task)

```bash
flutter analyze          # 0 errors required
# Manual: run app on device/emulator, verify screen works
```
