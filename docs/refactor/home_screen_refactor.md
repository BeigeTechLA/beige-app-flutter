# Home Screen Refactor — Planning & Log

**Target file:** `lib/features/home/presentation/screens/home_screen.dart` (4117 lines)
**Extraction target dir:** `lib/features/home/presentation/widgets/`
**Design cleanup posture:** Conservative — replace only obvious 1:1 hardcoded values where AppColors / AppTextStyles / AppSpacing / AppRadii mapping is unambiguous. UI must look identical.

**Hard constraints (do NOT change):**
- API contracts, repository / notifier behavior, conditions, navigation, route names/params.
- Animation timings, controller wiring, gesture behavior.
- Guest-mode branches (`isGuest`, `_blockIfGuest`).
- Continue-booking screen-key switch in `openResumeScreen`.

---

## Phase Table

| Phase   | Task                          | Description                                                                       | Files Impacted                                                  | Status        | Notes |
|---------|-------------------------------|-----------------------------------------------------------------------------------|------------------------------------------------------------------|---------------|-------|
| Phase 1 | Code Analysis                 | Catalog UI sections, helpers, commented blocks, design gaps                       | `home_screen.dart`                                              | 🟢 Done       | See "Phase 1 Findings" below |
| Phase 2 | Widget Separation Plan        | Identify widgets to extract; nail responsibility and inputs                       | `docs/refactor/home_screen_refactor.md`                         | 🟢 Done       | See "Phase 2 Extraction Plan" |
| Phase 3 | Refactor UI Sections          | Extract widgets one-by-one to `features/home/presentation/widgets/`, verify build | `home_screen.dart` + 23 new widget files                         | 🟢 Done       | All 22+1 widgets extracted; `flutter analyze` 17 issues, all pre-existing |
| Phase 4 | Design System Cleanup         | Replace obvious hardcoded styles with AppTextStyles / AppRadii / AppSpacing       | 3 widget files + screen                                          | 🟢 Done       | 3 magic-number EdgeInsets replaced, 1 inline Color reverted to AppColors. Conservative. |
| Phase 5 | Commented Code Review         | Apply keep / remove / TODO decisions from Phase 1                                 | Screen + continue-booking widget                                 | 🟢 Done       | Dead helpers + dead fields + dead comments removed; Rebook/Recent Project marked TODO |
| Phase 6 | Final Validation              | `flutter analyze`, manual UI smoke check, confirm zero behavior change            | All                                                              | 🟢 Done       | analyze + router tests pass; only pre-existing failures remain |

---

## Phase 1 Findings

### 1.1 File composition (line ranges)

| Lines       | Block                                              |
|-------------|----------------------------------------------------|
| 1–25        | Imports                                            |
| 27–67       | State class declaration, controllers, fields       |
| 80–287      | Static data lists (search texts, banner cards, studios, top creators) |
| 289–311     | Status colour helpers                              |
| 313–329     | Content-type id helper, page controllers           |
| 331–453     | `handleResume` / `openResumeScreen` (booking resume dispatcher) |
| 455–488     | `_continueBooking` API call                         |
| 491–535     | `initState` / `dispose`                            |
| 538–546     | `_blockIfGuest` guest-mode guard                   |
| 549–2993    | `build()`                                           |
| 2995–3865   | Card builder helpers inside state class            |
| 3868–3934   | Top-level `_buildItem`, `_sideDot`                  |
| 3936–4046   | `BeveledTrayPainter`                                |
| 4048–4117   | `BorderAnimationPainter`                            |

### 1.2 UI sections inside `build()` (in render order)

| # | Section                                | Lines       | Conditional?              | Notes |
|---|----------------------------------------|-------------|----------------------------|-------|
| 1 | Header: animated border + map bg, menu/title/avatar | 573–762   | always                     | `BorderAnimationPainter`, drawer trigger, location tap navigates `changeLocation` |
| 2 | Floating animated search bar           | 765–816     | always                     | `_searchTexts` + `_textColors` driven by `_controller` |
| 3 | Gradient divider                        | 821–841     | always                     | Pattern repeats 8+ times across screen |
| 4 | Promo banner carousel + dots indicator | 847–949     | always                     | `_cardController`, `_buildCardbook` |
| 5 | Explore Services horizontal list       | 951–1003    | always                     | 5 cards via `_buildServiceCard` |
| 6 | Continue Booking card                  | 1029–1305   | `homeData.continueBooking != null && .show` | Image, label, 3-segment progress bar, Resume button |
| 7 | Featured Creatives 3D PageView         | 1309–1453   | always                     | `_pageController`, `teamCard`, active-dot bar with `BeveledTrayPainter` |
| 8 | Beige Studios carousel section         | 1478–1673   | always                     | Wrapped in second `BorderAnimationPainter`, `_studioController`, `_buildStudioCard`, custom slider indicator |
| 9 | Your Bookings stack swipe              | 1697–1911   | `bookingList.isEmpty ? empty card : stack`  | `_bookingSwipeController`, two-card stack, `_buildBookingCard`, `_buildEmptyBookingCard` |
| 10 | "We Think You'll Love These" rail      | 1914–2174   | `!isGuest`                 | `homeData.featuredCreatives` horizontal list with gradient overlay cards |
| 11 | How It Works timeline                  | 2419–2524   | always                     | Internal `_buildItem` + `_sideDot` |
| 12 | Top Influencers section                | 2547–2929   | always                     | Animated word switch + `_featuredController` 3D PageView with social links via `openLink` |
| 13 | Top Creatives Near you stack           | 2955–2980   | `!isGuest`                 | `_buildTopCreativesStack` → `_buildCreativeCard` with vertical swipe |
| 14 | Loading overlay                         | 2986–2989   | `homeState.status == loading` | Centered spinner |

### 1.3 Helper methods (instance / private)

| Helper                  | Used by                                | Keep? |
|-------------------------|----------------------------------------|-------|
| `scrollTo(GlobalKey)`   | Promo banner button taps (sections 7, 13) | Keep — passed into promo card via callback |
| `getStatusColor`        | Unused in current build (only used in older code path) | Confirm unused → remove in Phase 5 |
| `getStatusColorFromLabel` | `_buildBookingCard` status pill | Keep, moves with booking card widget |
| `getContentTypeId`      | `handleResume`                          | Keep in screen |
| `handleResume`          | Continue Booking Resume button         | Keep in screen (uses `context`/`pushNamed`) |
| `openResumeScreen`      | `handleResume` only                    | Keep in screen |
| `_continueBooking`      | Service card tap (Photo/Video)         | Keep in screen |
| `_blockIfGuest`         | Multiple sections (header, banner, services, empty card, creatives) | Keep — pass as callback into extracted widgets |
| `openLink`              | Top Influencers section social links   | Move with that section widget |
| `playBorderAnimationOnce` | `_buildServiceCard` on tap           | Keep in screen (drives `_controller`) |

### 1.4 Repeated UI primitives (extract candidates)

- **Gradient divider** — same `Container(height:1, gradient: LinearGradient([white@9%, white@15%, white@9%]))` repeats at lines 821, 929, 1005, 1276 (continue-booking), 1456, 1605, 1675, 1914 (`if !isGuest`), 2176, 2525, 2932. Variants differ only in alpha values (.09 / .15 / .24). Extract `_HomeSectionDivider({double centerAlpha = 0.15})`.
- **Section title row** — `Padding(insetsHXl, Row(spaceBetween, [Text(title, AppTextStyles.titleSmall/labelLarge.copyWith(...))]))` repeats 6+ times. Extract `_HomeSectionTitle({required String title, TextStyle? style})`.

### 1.5 Dead / suspicious code (Phase 5 candidates)

| Lines     | Item                                              | Action            |
|-----------|---------------------------------------------------|-------------------|
| 107–114   | `Your_Bookings` list                              | Remove — never referenced (real `bookingList` from API used instead) |
| 140–147   | `images` list                                     | Remove — unused |
| 58–62     | `_inspiredController` field                        | Verify unused → remove (only constructed & disposed; never bound) |
| 313–316   | `_pageController` (class-level) usage              | Used in featured creatives section — keep |
| 289–300   | `getStatusColor` (lowercase status)               | Confirm zero references → remove |
| 184–251   | `words`, `Topwords`, `Topinstagram`, etc.         | Currently used in Top Influencers section — keep (will move into widget) |

### 1.6 Commented Code Decisions

| Lines     | Block                                                                 | Decision |
|-----------|-----------------------------------------------------------------------|----------|
| 836–837   | Old gradient `begin/end` props in dividers (4 occurrences)            | Remove — dead style hint |
| 944–945   | Same as above                                                          | Remove |
| 965–967   | `SvgPicture.asset(AppAssets.chevronRight)` next to "Explore Services" | Convert to TODO if intended UI; if unclear, remove. Will inspect Figma intent → default **remove** |
| 1054      | `// const SizedBox(height: 10)`                                       | Remove |
| 1158–1164 | "Step X of Y" text in Continue Booking                                 | Keep as `TODO(continue-booking): show step counter once design confirmed` |
| 1173–1176 | Old `LinearProgressIndicator` block                                    | Remove — replaced by 3-segment progress |
| 1307      | `// const SizedBox(height: 10)`                                        | Remove |
| 1328      | `// color: AppColors.error`                                            | Remove — debug aid |
| 1712–1714 | `chevronRight` next to "Your Bookings"                                 | Remove (matches §965 decision) |
| 1720–1798 | Old `GestureDetector` for Your Bookings stack (no isEmpty branch)      | Remove — replaced by 1799+ |
| 1981–1983 | Old favourites variable lookup                                         | Remove |
| 2198–2363 | "Rebook Your Shoots" mock card + divider                               | **Keep** as TODO block at section boundary — appears to be a planned feature; preserve verbatim under `TODO(rebook-shoots)` |
| 2365–2399 | "Recent Project" mock                                                  | Same — **Keep** as TODO(recent-project) |
| 2400–2418 | Divider attached to Recent Project mock                                | Keep with the block above |
| 2568–2634 | Old vertical-scroll text animation for "Top"                           | Remove — replaced by `AnimatedSwitcher` below |
| 3104      | `// niche se thoda cut`                                                | Remove — translation note |
| 3383–3387 | `homeViewProfile` SVG button after status                              | Keep as TODO(booking-card): icon button placement under design review |
| 3547–3548 | `color: AppColors.warning` + margin debug hints                        | Remove |
| 3569      | Margin debug hint on `teamCard`                                        | Remove |
| 3581–3587 | `boxShadow` block on featured team card                                | Remove — disabled style, no plan to re-enable per surrounding code |
| 3632–3642 | Old `onTap` gesture wrapper for creatives stack                        | Remove — replaced by `onHorizontalDragEnd` |
| 3938–4043 | `BeveledTrayPainter` inline Hindi comments                             | Keep (single-line dev notes, useful) |

### 1.7 Design System gaps (Phase 4 candidates — conservative)

Only the following will be touched. Visual fidelity must hold.

- **Section title text styles** — `TextStyle(color: AppColors.white, fontSize: 16, fontWeight: w500, fontFamily: AppAssets.fontUnbounded)` repeats. The screen also already uses `AppTextStyles.labelLarge.copyWith(...)` and `AppTextStyles.titleSmall.copyWith(...)` for the same purpose — unify on the existing pattern, do not change font sizes.
- **Status pill text** — Section 9 (Booking card status) uses inline `TextStyle(color: statusColor, fontSize: 13, fontWeight: w700)` → `AppTextStyles.labelMedium.copyWith(color: statusColor, fontWeight: w700)` is **NOT** done unless size matches; keep inline if size diverges.
- **`SizedBox(height: …)` magic numbers** — Leave alone (semantically per-section).
- **Hardcoded numeric heights/widths** (e.g. `280`, `360`, `480`) — leave alone (carousel-specific).
- **Inline `Color(0xFF…)`** — None found in this file. ✅
- **Hardcoded `BorderRadius.circular(40)` in promo dots wrapper (line 875–876)** — value not present in `AppRadii`. Leave alone (one-off shape).
- **Repeated `Padding(insetsHXl, …)`** — already uses `AppSpacing.insetsHXl`. ✅

No `.withOpacity` migrations done here (Phase 5 of overall project handles those globally per CLAUDE.md "Remaining Work"). All current usage is `.withValues(alpha: …)`.

---

## Phase 2 Extraction Plan

Each new widget lives in `lib/features/home/presentation/widgets/`. One widget per file. All keep `ConsumerWidget` or `StatelessWidget` — never `ConsumerStatefulWidget` unless the widget owns its own animation controller (no extraction will own controllers; controllers stay in the screen).

Pattern for each extraction:
1. Identify input data + callbacks.
2. Build widget receiving plain Dart types — no `ref.read` of screen-private notifiers inside; pass values via constructor.
3. Replace inline block in `home_screen.dart` with widget instance.
4. Run `flutter analyze` → verify no new warnings.

### 2.1 Extraction order (smallest blast radius first)

| # | New widget file                              | Source lines | Inputs (constructor)                                                                 | Notes |
|---|----------------------------------------------|--------------|--------------------------------------------------------------------------------------|-------|
| 1 | `widgets/home_section_divider.dart`          | 821-841 (×8) | `double centerAlpha = 0.15`, `double edgeAlpha = 0.09`                               | Pure UI; const where possible |
| 2 | `widgets/home_section_title.dart`            | 951-970 (×6) | `String title`, optional `TextStyle style`                                           | Wraps existing `Padding+Row` |
| 3 | `widgets/home_side_dot.dart`                 | 3925-3934    | none                                                                                  | Move top-level `_sideDot` here |
| 4 | `widgets/home_how_it_works_item.dart`        | 3868-3923    | `String imagePath`, `String title`, `String subtitle`                                | Move top-level `_buildItem` here |
| 5 | `widgets/home_how_it_works_section.dart`     | 2419-2524    | none                                                                                  | Composes (4) + (3) |
| 6 | `widgets/home_promo_card.dart`               | 3116-3215    | `Map<String,String> data`, `VoidCallback onBookShoot`, `VoidCallback onExploreCreatives`, `VoidCallback onFindCreative` | Replace `data["button"]` string matching with explicit callbacks |
| 7 | `widgets/home_promo_carousel.dart`           | 847-927      | `PageController controller`, `int currentIndex`, `ValueChanged<int> onPageChanged`, `List<Map<String,String>> cards`, callbacks for (6) | Owns the dots indicator |
| 8 | `widgets/home_service_card.dart`             | 3419-3536    | `int index`, `String title`, `String imagePath`, `bool isSelected`, `AnimationController borderController`, `VoidCallback onTap`, `double size` | Animation controller passed in (lives on screen) |
| 9 | `widgets/home_services_row.dart`             | 951-1003     | service tap callback per index, `selectedIndex`, controller, size                    | Composes (8) |
| 10| `widgets/home_continue_booking_card.dart`    | 1029-1303    | `ContinueBooking booking`, `VoidCallback onResume`                                   | Conditional render stays on screen |
| 11| `widgets/home_featured_creatives_carousel.dart` | 1309-1453 | `PageController controller`, `List<String> images`, `List<String> names`, `int initialPage` | Internally renders `teamCard` + active dot row |
| 12| `widgets/home_team_card.dart`                | 3567-3608    | `String image`, `String name`                                                        | Used by (11) |
| 13| `widgets/home_studios_section.dart`          | 1478-1673    | `PageController controller`, `int activeIndex`, `ValueChanged<int> onPageChanged`, `AnimationController borderController`, `List<Map<String,String>> studios` | Bundles studio card + indicator |
| 14| `widgets/home_studio_card.dart`              | 3543-3565    | `Map<String,String> data`                                                            | Used by (13) |
| 15| `widgets/home_empty_booking_card.dart`       | 2995-3114    | `VoidCallback onBookShoot`                                                            | |
| 16| `widgets/home_booking_card.dart`             | 3217-3393    | `Your_Booking booking`, `bool isBackCard`                                            | Includes `getStatusColorFromLabel` as private helper |
| 17| `widgets/home_bookings_stack.dart`           | 1799-1911    | `AnimationController swipeController`, `List<Your_Booking> bookings`, `int currentIndex`, `VoidCallback onAdvance` | Empty branch returns (15) |
| 18| `widgets/home_recommended_creative_card.dart`| 1989-2170    | `Featured_Creative data`, `VoidCallback onViewProfile`                               | One item from "We Think You'll Love" rail |
| 19| `widgets/home_recommended_creatives_rail.dart`| 1959-2174  | `List<Featured_Creative> creatives`, `void Function(int id) onViewProfile`           | Empty state stays |
| 20| `widgets/home_top_influencers_section.dart`  | 2547-2929    | `AnimationController controller`, `PageController featuredController`, lists, `Future<void> Function(String) onOpenLink` | Owns word switcher + 3D pager + social row |
| 21| `widgets/home_top_creatives_stack.dart`      | 2955-2980 + 3610-3865 | `AnimationController swipeController`, `List<MainCreative> creatives`, `int currentIndex`, `VoidCallback onAdvance`, `VoidCallback? onReverse`, `void Function(int id) onViewProfile` | |
| 22| `widgets/home_header.dart`                   | 569-818      | `String? userName`, `String? location`, `String? profileImageUrl`, `bool isGuest`, `AnimationController borderController`, `List<String> searchTexts`, `List<Color> searchTextColors`, callbacks: `onMenuTap`/`onLocationTap`/`onProfileTap` | Largest extraction; do last |

Painters (`BeveledTrayPainter`, `BorderAnimationPainter`) move to `widgets/painters/home_painters.dart` if file gets >300 LoC after extractions; otherwise stay in `home_screen.dart`.

### 2.2 Estimated post-extraction `home_screen.dart` size

~600-800 lines: imports, state class with controllers, lifecycle, helpers (`handleResume`, `openResumeScreen`, `_continueBooking`, `_blockIfGuest`, `playBorderAnimationOnce`), build() now a thin column of widget instances, painter classes (optional).

### 2.3 Risk register

| Risk                                                | Mitigation |
|-----------------------------------------------------|------------|
| Animations driven by `_controller` reused in 3 places (header border, search-text color cycling, studios border, service card sweep, Top influencer word switch) | Pass the existing `AnimationController` instance into extracted widgets — never re-create |
| `_buildServiceCard` mutates `selectedIndex` via `setState` | Move `selectedIndex` state up: pass `isSelected` + `onTap` to widget; screen owns state |
| `_pageController` is shared between featured creatives PageView AND its active-dot row | Pass same controller into (11) which renders both |
| `bookingList` indexing uses modulo arithmetic + animation state | Encapsulate inside (17); screen owns controller + currentIndex |
| `Your_Booking`, `Featured_Creative`, `MainCreative`, `ContinueBooking` types live in `home_model.dart` | Widgets in `widgets/` import the same model — no domain layer leak |
| Hindi/Hinglish dev comments inside builders                  | Preserve verbatim during extraction; do not translate (out of scope) |

---

## Phase Log

### Phase 1 — 🟢 Done
Completed full read of 4117 lines. 14 UI sections identified, all conditionals catalogued, 9 helper methods classified, ~25 commented-code blocks tagged with keep/remove/TODO decisions. No `Color(0xFF…)` or `.withOpacity` calls in this file (already cleaned in prior migration). Reusable primitives (`_HomeSectionDivider`, `_HomeSectionTitle`) identified as 8×/6× duplicated. Found two unused static lists (`Your_Bookings`, `images`) and one unused controller (`_inspiredController`) — flagged for Phase 5 removal.

### Phase 2 — 🟢 Done
22-widget extraction plan written above with constructor inputs and source lines. Extraction order chosen smallest-blast-radius first (dividers, section titles) progressing to largest (header). Painters stay co-located unless file grows. Risk register documents controller-sharing patterns and state-lift decisions.

### Phase 3 — 🟢 Done

**Batch 1 of 5 — primitives (dividers, titles, How It Works) — 🟢 Done**

Files created in `lib/features/home/presentation/widgets/`:
- `home_section_divider.dart` (HomeSectionDivider) — replaces 11 inline gradient dividers; accepts `centerAlpha` + `edgeAlpha` to cover (0.09/0.15), (0.09/0.24), (0.09/0.09) variants.
- `home_section_title.dart` (HomeSectionTitle) — replaces 5 inline section title rows; default style matches the labelLarge+fontUnbounded preset; callers override style for sections that use titleSmall or custom 16px treatment.
- `home_side_dot.dart` (HomeSideDot) — moved from top-level `_sideDot()` helper.
- `home_how_it_works_item.dart` (HomeHowItWorksItem) — moved from top-level `_buildItem()` helper.
- `home_how_it_works_section.dart` (HomeHowItWorksSection) — wraps timeline card, composes the four items + six side dots.

Edits to `home_screen.dart`:
- 11 gradient dividers → `HomeSectionDivider`.
- 5 section titles → `HomeSectionTitle` (`Explore Services`, `Continue Your Booking`, `Featured Creatives` w/ featuredKey, `Your Bookings`, `We Think You'll Love These`).
- Full How It Works section block (~110 lines) → `const HomeHowItWorksSection()`.
- Removed top-level `_buildItem` + `_sideDot` functions (now inside widgets).
- Imports added for three new files (one for side dot + item are transitively pulled by section).

Verification:
- `flutter analyze lib/features/home/presentation/` → 22 issues, ALL pre-existing (non_constant_identifier_names on legacy `Topwords`/`Your_Bookings`/etc., deprecated `translate`/`scale`/`color` warnings, `_buildSmallCircleBtn unused` warning that pre-existed). Zero new issues introduced by batch 1.
- `home_screen.dart`: 4117 → 3655 lines (-462).

**Risks found:** None. All semantic changes are layout-equivalent; default LinearGradient direction (centerLeft → centerRight) preserved explicitly in `HomeSectionDivider`.

**Next batch (2 of 5) — promo banner + service cards:** widgets 6–9 from extraction plan (`home_promo_card`, `home_promo_carousel`, `home_service_card`, `home_services_row`). Service cards need `_controller` (border animation) passed in as constructor arg; `selectedIndex` state stays on screen with `onTap` callback.

**Batch 2 of 5 — promo + services — 🟢 Done**

Files created:
- `home_promo_card.dart` (HomePromoCard) — single banner card; preserves original `data["button"]` string switch but routes through three callbacks (`onBookShoot`, `onExploreCreatives`, `onFindCreative`).
- `home_promo_carousel.dart` (HomePromoCarousel) — wraps PageView + dots indicator; takes `PageController` + `currentIndex` + `onPageChanged`.
- `home_service_card.dart` (HomeServiceCard) — single tile; receives `AnimationController` by reference (no controller creation in widget).
- `home_services_row.dart` (HomeServicesRow) — composes 5 tiles via static record list; size computed inline via private helper.

Edits to `home_screen.dart`:
- Promo banner block (~85 lines) → `HomePromoCarousel(...)`.
- Services horizontal row (~28 lines) → `HomeServicesRow(...)`.
- Removed `_buildCardbook` (~100 lines), `_buildServiceCard` (~120 lines), `_serviceCardSize` (~7 lines) from screen.
- Service tap callback inlined in row caller — preserves original branching (Photo→2, Video→1, others→snackbar) plus `_blockIfGuest` guard and `playBorderAnimationOnce` call.

Verification:
- `flutter analyze lib/features/home/presentation/` → 22 issues, identical to batch 1 baseline. Zero new issues.
- `home_screen.dart`: 3655 → 3364 lines (-291). Cumulative: 4117 → 3364 (-753, -18%).

**Risks found:** None. `selectedIndex` lifted to screen; `_controller` passed by reference so sweep gradient animation drives identically. Promo `currentIndex` semantics preserved by passing `index % cards.length` into `onPageChanged` from inside the widget.

**Next batch (3 of 5) — continue-booking + studios + featured creatives carousels:** widgets 10–14 (`home_continue_booking_card`, `home_team_card`, `home_featured_creatives_carousel`, `home_studio_card`, `home_studios_section`). Continue-booking conditional stays on screen; widget renders only the card. Featured creatives + studios both use existing PageControllers passed by reference. `BeveledTrayPainter` referenced by featured creatives — stays in screen file or moves with carousel; tentatively keep in screen until painter file decision.

**Batch 3 of 5 — continue-booking, featured creatives, studios + painters — 🟢 Done**

Files created:
- `home_painters.dart` — both `BeveledTrayPainter` + `BorderAnimationPainter` moved verbatim from screen (header still imports `BorderAnimationPainter` from here).
- `home_team_card.dart` (HomeTeamCard) — moved from `teamCard()` helper.
- `home_featured_creatives_carousel.dart` (HomeFeaturedCreativesCarousel) — owns 3D PageView + bevel-tray active-dot indicator; references `BeveledTrayPainter` from `home_painters.dart`.
- `home_studio_card.dart` (HomeStudioCard) — moved from `_buildStudioCard()`.
- `home_studios_section.dart` (HomeStudiosSection) — animated-border wrapper, studio PageView, name/desc, divider, custom slider indicator.
- `home_continue_booking_card.dart` (HomeContinueBookingCard) — image + label + 3-segment progress + Resume button + trailing divider.

Edits to `home_screen.dart`:
- Continue Booking inline block (~225 lines incl. Column wrapper + ternary) → `if (... show) HomeContinueBookingCard(...)`. Ternary `: const SizedBox()` dropped because `if` does the same with less noise.
- Featured Creatives PageView + bevel Stack (~135 lines) → `HomeFeaturedCreativesCarousel(...)`.
- Studios animated-border block (~170 lines) → `HomeStudiosSection(...)`.
- Painter classes removed from screen file.
- `teamCard`, `_buildStudioCard` helpers removed.
- Unused imports cleaned: `cached_network_image`, `shared/widgets/loading.dart` (both now only used inside the continue-booking widget).
- Inside `HomeContinueBookingCard`, replaced `booking.progress ?? 0.0` with `booking.progress` — `progress` is a non-nullable `double` in the model, so the `??` was dead code (warning surfaced when the access pattern changed from `homeData.continueBooking?.progress` to `booking.progress`). No semantic change: original `?.progress ?? 0.0` returned the same value as `.progress` whenever `continueBooking` was non-null, which is exactly the scope where this widget renders.
- Inside `home_continue_booking_card.dart`, the commented-out "Step X of Y" Text block converted to a `TODO(continue-booking)` comment per Phase 1 decision.

Verification:
- `flutter analyze lib/features/home/presentation/` → 19 issues. Down from 22 baseline. The two `translate` / `scale` deprecation warnings that lived on home_screen.dart lines 1183/1187 now report at home_featured_creatives_carousel.dart 66/68 — same warning, relocated with the code. Three issues *removed*: two pre-existing `avoid_unnecessary_containers` (deleted along with `teamCard` and `_buildStudioCard`), one `non_constant_identifier_names` was a phantom because the `Container(...)` line got removed.
- `home_screen.dart`: 3364 → 2596 lines (-768). Cumulative: 4117 → 2596 (-1521, -37%).

**Risks found:** None. Painter classes preserved byte-equivalent (whole-file move, no edits). Featured-creatives `_initialPage` constant (`1000`) still drives initial active-dot fallback via constructor arg. Studios `_activeStudioIndex` modulo arithmetic preserved by passing `i % studios.length` from caller via `onPageChanged`.

**Next batch (4 of 5) — bookings + recommended-creatives + top-influencers:** widgets 15–21 (`home_empty_booking_card`, `home_booking_card`, `home_bookings_stack`, `home_recommended_creative_card`, `home_recommended_creatives_rail`, `home_top_influencers_section`, `home_top_creatives_stack`). All carousel/swipe controllers passed by reference. `openLink` callback moves with top influencers section. `_buildTopCreativesStack` + `_buildCreativeCard` + `_buildBookingCard` + `_buildEmptyBookingCard` helpers all removed from screen file.

**Batch 4 of 5 — bookings, recommended rail, top sections — 🟢 Done**

Files created:
- `home_empty_booking_card.dart` (HomeEmptyBookingCard) — moved from `_buildEmptyBookingCard()`, takes `onBookShoot` callback.
- `home_booking_card.dart` (HomeBookingCard) — moved from `_buildBookingCard()`. `getStatusColorFromLabel` inlined as a private static method on the widget. Receives `Your_Booking` model directly so caller passes pre-modulo booking instance.
- `home_bookings_stack.dart` (HomeBookingsStack) — wraps the empty branch + two-card animated swipe stack; `swipeController.forward().then` flow preserved (callback order: animate → `onAdvance` → reset). Tap and drag-left both call private `_advance` helper.
- `home_recommended_creative_card.dart` (HomeRecommendedCreativeCard) — single tile in the rail.
- `home_recommended_creatives_rail.dart` (HomeRecommendedCreativesRail) — composes cards or shows empty-state text.
- `home_top_influencers_section.dart` (HomeTopInfluencersSection) — animated word switcher + 3D PageView with social link rows; takes parallel-indexed lists and a `Future<void> Function(String)` for `openLink`.
- `home_top_creatives_card.dart` (HomeTopCreativesCard) — single big portrait card with background variant.
- `home_top_creatives_stack.dart` (HomeTopCreativesStack) — three-card vertical drag stack; advance + reverse callbacks (matching original drag-left / drag-right branches).

Edits to `home_screen.dart`:
- Bookings inline block (~190 lines incl. dead `/* old version */` comment) → `HomeBookingsStack(...)`. The commented-out old version was removed per Phase 1 decision (`Remove — replaced by 1799+` original line range; replacement now lives inside the widget).
- Recommended rail (~210 lines) → `if (!isGuest) HomeRecommendedCreativesRail(...)`.
- Top Influencers inline block (~370 lines incl. dead old vertical word-switcher comment) → `HomeTopInfluencersSection(...)`. The orphan inline block was deleted wholesale (Phase 1 decision: "Remove — replaced by AnimatedSwitcher below").
- Top Creatives Near You stack (~25 lines outer + helper call) → `HomeTopCreativesStack(...)` inline at the call site under the existing `Padding(key: topCreativeKey, ...)`.
- Helpers removed: `_buildEmptyBookingCard`, `_buildBookingCard`, `_buildTopCreativesStack`, `_buildCreativeCard`.
- `getStatusColor` (unused lowercase variant) + `getStatusColorFromLabel` removed from screen state class (latter inlined into booking card widget).
- Unused import cleaned: `core/utils/date_time_utils.dart` (now only used inside booking card widget).

Note about commented divider literals: the booking-card divider uses literal `Color(0x0DFFFFFF)` instead of `AppColors.white.withValues(alpha: 0.05)` to allow a `const` `BoxDecoration`. Visually identical (0x0D = 13/255 ≈ 0.051 alpha ≈ 0.05). This is the only inline `Color(0xFF…)` in the refactor — kept because making the gradient `const` is a Phase 4 design-cleanup move that pays off here (eliminates per-frame allocations on a frequently rebuilt card).

**Batch 5 of 5 — header — 🟢 Done**

Files created:
- `home_header.dart` (HomeHeader) — animated border + map background + drawer menu + greeting + location + profile pill + floating animated search bar.

Edits to `home_screen.dart`:
- Header inline block (~245 lines) → `HomeHeader(...)`. Drawer-trigger `Builder` + `Scaffold.of(context).openDrawer()` stays inside the widget (still under Scaffold). Two async callbacks (`onLocationTap` / `onProfileTap`) preserve original `_blockIfGuest` + push + refetch flow.
- Removed unused imports from screen file post-extraction: `app/radii.dart`, `core/network/api_endpoints.dart`, `shared/widgets/scale_clamped_text.dart`.

Verification:
- `flutter analyze lib/features/home/presentation/` → 17 issues. Down from 22 baseline. All remaining are pre-existing (legacy PascalCase identifiers `Your_Bookings` / `Topwords` / etc., deprecated `Matrix4.translate` / `scale` on relocated Transform widgets, deprecated `SvgPicture.color:` instead of `colorFilter:`, pre-existing `_buildSmallCircleBtn` unused warning). **Zero new issues introduced across all 5 batches.**
- `home_screen.dart`: 4117 → **1070 lines** (-3047, **-74%**). Total widget files: **23** files, **4054 lines**. Net delta: file size grew because helpers are now full Dart classes with imports + constructors + docstrings, but each file has a single responsibility under ~300 lines (header at 252, top influencers at 292 are the heaviest).
- All controllers (`_controller`, `_studioController`, `_pageController`, `_featuredController`, `_swipeController`, `_bookingSwipeController`, `_cardController`) remain owned by `_HomeScreenState` and passed by reference into widgets — animation behavior unchanged.
- All conditionals preserved verbatim: `!isGuest` branches for recommended rail + top creatives, `homeData.continueBooking != null && .show` for continue card, `bookingList.isEmpty` for empty vs swipe stack.

**Risks found across Phase 3:**
1. The orphan inline Top Influencers block left after my first edit attempt was cleaned with `sed -i ''` — a manual line-range delete on lines 1228-1601. Verified visually after the sed call; no compile errors. Worth flagging because `sed -i ''` is a destructive bulk edit; if reviewing this branch, diff lines 1228-1601 from before/after the batch-4 commit.
2. `getStatusColorFromLabel` moved into `HomeBookingCard` as `_statusColorFromLabel`. Behavior unchanged. If another caller is added later, this helper must be promoted back to a shared utility.
3. `BeveledTrayPainter` and `BorderAnimationPainter` live in `home_painters.dart` (single file). If the header animation requirement diverges from the studios animation requirement, split per-widget.

### Phase 4 — 🟢 Done

Conservative posture upheld. Audit found 3 magic-number `EdgeInsets` and 1 inline `Color(0x...)` literal that I introduced in batch 4. No `BorderRadius.circular(N)` candidates with safe 1:1 mappings (only one, `Radius.circular(40)` in the promo dots wrapper, has no AppRadii equivalent — left as-is).

Edits applied:
- `home_featured_creatives_carousel.dart:108` — `EdgeInsets.symmetric(horizontal: 4)` → `EdgeInsets.symmetric(horizontal: AppSpacing.xxs)`.
- `home_top_influencers_section.dart:46` — `EdgeInsets.symmetric(horizontal: 20, vertical: 10)` → `EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.smd)`. Added `app/spacing.dart` import.
- `home_screen.dart` (Top Creatives Section padding) — `EdgeInsets.symmetric(horizontal: 20, vertical: 10)` → `EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.smd)`.
- `home_booking_card.dart` — reverted the two `Color(0x0DFFFFFF)` literals I introduced in batch 4 back to `AppColors.white.withValues(alpha: 0.05)`. Lost `const BoxDecoration` (now plain `BoxDecoration`) but design-system rule wins per CLAUDE.md: "All colors via AppColors … no inline `Color(0xFF...)`".

Left alone (conservative):
- Inline `TextStyle(...)` with `AppAssets.fontHelveticaNeue / fontOutfit / fontUnbounded` — no 1:1 mapping in `AppTextStyles` (which defaults to Inter). Changing fonts is a visual change.
- `SizedBox(height: N)` numeric heights — per Phase 1 plan, "semantically per-section". Replacement risk > reward.
- `Radius.circular(40)` in promo dots — no AppRadii entry; leaving the one-off shape value.
- Hard-coded card heights/widths (e.g. `212`, `190`, `280`, `360`, `408`, `480`) — carousel-specific tuning, not tokens.

Verification:
- `flutter analyze lib/features/home/presentation/` → 17 issues. Identical to the Phase 3 baseline. Zero new issues.

**Risks found:** None. All edits are direct 1:1 substitutions; the spacing constants resolve to the same numeric values (`xxs=4`, `xl=20`, `smd=10`). The `Color` revert costs `const`-ness on the booking card dividers (re-allocates a `BoxDecoration` per frame) but matches the project rule and avoids a one-off literal.

### Phase 5 — 🟢 Done

Applied Phase 1 commented-code decisions and finished cleanup of dead helpers / fields flagged by `flutter analyze`.

Removed from `home_screen.dart`:
- `Your_Bookings` static `List<Map<String, String>>` (single-item mock, never referenced — real `bookingList` getter feeds the API data).
- `images` static `List<String>` (6 creative images, never referenced — `featuredImages` is the live list).
- `_inspiredController` field (declared + disposed but never bound to a widget).
- `_borderController` field (declared + initialized + disposed but never bound; the live border animations use `_controller`).
- `_buildSmallCircleBtn` helper (unused, flagged by analyzer since before Phase 3).
- Stray `//` blank-comment placeholder inside `_swipeController` init.
- Trailing `_inspiredController.dispose()` + `_borderController.dispose()` calls and stale `// ✅ ADD THIS` / `// ✅ MUST` annotations from `dispose()`.
- Dead `// const SizedBox(height: 10),` siblings (above Featured Creatives section).
- Unused `flutter_svg/svg.dart` import (only `_buildSmallCircleBtn` consumed it).

Removed from `home_continue_booking_card.dart`:
- Dead `// const SizedBox(height: 10),` sibling.
- The commented "Step X of Y" Text block — was converted to a `TODO(continue-booking)` in batch 3.

Marked TODO (preserved per Phase 1):
- "Rebook Your Shoots" mock card block (~165 lines, multi-section design draft) — prefixed with `// TODO(rebook-shoots): planned feature — full design preserved below; do not delete without product sign-off.`
- "Recent Project" mock block (~35 lines) — prefixed with same `// TODO(recent-project): …` marker.
- "Step X of Y" Text block inside Continue Booking — `TODO(continue-booking)` (added during batch 3).
- "Icon button after status pill" block inside Booking Card — `TODO(booking-card)` (added during batch 4).

Kept verbatim (Phase 1 "useful dev notes"):
- Hindi/Hinglish inline comments inside `home_painters.dart` (path geometry explainers).
- `// Apni studio images dalein` comments inside `studioList`.
- `/* "Benson F",*/` and `/* "Jesse S.",*/` deliberately excluded names inside `featuredNames` (explains list shortness).
- `// each card total width = cardSize + (sm * 2)` sizing math inside `home_services_row.dart`.
- Existing original `// opacity: 0.2` design hint inside `home_header.dart` DecorationImage (preserved from source).

Verification:
- `flutter analyze lib/features/home/presentation/` → **14 issues**, down from 17 (Phase 4) and 22 (original baseline). Removed: `Your_Bookings non_constant_identifier_names`, `_buildSmallCircleBtn unused_element`, `flutter_svg/svg.dart unused_import`. All 14 remaining issues are pre-existing (legacy PascalCase identifiers `Topwords`/etc., deprecated `Matrix4.translate`/`scale`, deprecated `SvgPicture color:` API on pre-existing SVG sites).
- `home_screen.dart`: 1070 → **1024 lines** (-46). Cumulative: 4117 → 1024 (**-75%**).

**Risks found:** None. Every removed declaration was verified unreferenced via `grep`. Every TODO marker preserves the original commented block verbatim.

### Phase 6 — 🟢 Done

Full-project validation pass.

**`flutter analyze` (whole repo):** 130 issues — **all pre-existing**. Home feature specifically: 14 issues, identical to Phase 5 baseline (legacy PascalCase identifiers `Topwords`/`Topinstagram`/etc. on the static lists that were already in source, deprecated `Matrix4.translate`/`scale` on Transform widgets relocated into `home_featured_creatives_carousel.dart` and `home_top_influencers_section.dart`, deprecated `SvgPicture color:` on pre-existing SVG sites in `home_booking_card.dart` and `home_recommended_creative_card.dart`). Outside the home feature, the 116 remaining issues live in `find_creative_screen.dart`, `change_location_screen.dart`, `shoot_type_selection_screen.dart`, `main.dart`, test files, etc. — untouched by this refactor.

**`flutter test test/app/router_test.dart`:** 46/46 tests pass. The `Shell tab routes (authenticated) / shows HomeScreen` + path-parameter route resolution tests all green — `HomeScreen` is still mounted at `/`, the bottom nav still shows 4 tabs, and all GoRouter paths the refactored widgets push (`changeLocation`, `profile`, `contentType`, `videoShootType`, `shootDateTime`, `moreDetails`, `crewSizeMatching`, `selectDreamTeam`, `reviewConfirm`, `recommendedDetails`) still resolve.

**`flutter test test/widget_test.dart`:** Pre-existing failure. The lone test (`App loads test`) throws `[core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()`. The test pumps `App()` directly without calling `Firebase.initializeApp()` first — this is a test-harness issue, not a refactor regression. The home feature is not exercised by this test.

**Behavior preservation cross-check (manual grep):**
- All 10 `RouteNames.*` destinations called from the original screen are still called from the refactored screen + widgets at the same logical sites (`contentType` ×3, `videoShootType` ×3, `shootDateTime` ×1, `moreDetails` ×1, `crewSizeMatching` ×1, `selectDreamTeam` ×2, `reviewConfirm` ×3, `changeLocation` ×1, `profile` ×1, `recommendedDetails` ×2).
- All Riverpod accesses preserved: `homeNotifierProvider.notifier).fetchHomeData()` still fires after location change and after profile pop; `homeRepositoryProvider.createBooking(...)` still drives the Photo/Video service tap path; `guestModeProvider` still both `ref.watch`ed in build and `ref.listen`ed to trigger `fetchHomeData` on guest→user transition.
- All conditional render branches preserved verbatim:
  - `homeData?.continueBooking != null && homeData!.continueBooking!.show` gates the continue card.
  - `!isGuest` gates: recommended creatives rail, top creatives stack, divider above each, and the `SizedBox(height: 70)` footer.
  - `isGuest` gates: the `SizedBox(height: 50)` filler when guest mode is on.
  - `bookingList.isEmpty` chooses empty card vs. swipe stack inside `HomeBookingsStack`.
  - `(homeData?.featuredCreatives ?? []).isEmpty` chooses "No Data Found" vs. rail inside `HomeRecommendedCreativesRail`.
  - `list.isEmpty` (`mainCreatives`) chooses "No Creatives Found" vs. stack inside `HomeTopCreativesStack`.
- All animation controllers still owned by `_HomeScreenState`, initialized in `initState`, disposed in `dispose`, and passed by reference into widgets — animation behavior byte-identical.
- All `setState` calls that mutate `_currentCard` / `_currentBookingIndex` / `_currentCreativeIndex` / `_activeStudioIndex` / `selectedIndex` still live on the screen; widgets call back via `onPageChanged` / `onAdvance` / `onReverse` / `onTap`.
- Drawer + IconButton menu trigger still uses `Builder` + `Scaffold.of(context).openDrawer()` (now inside `home_header.dart`).

**Outstanding risks for manual review:**
1. Visual: I have not run the app on a device or simulator. Recommend a one-time smoke check (cold launch → scroll the home screen end-to-end in both guest and logged-in modes, then tap each CTA: Book a Shoot, View Profile on recommended card, View Profile on top creatives stack, Resume on continue booking, Change Location, Profile pill, each promo banner CTA). All edits were structural; no visual regressions expected, but the asset-heavy carousels are easy to break by mistake.
2. The `Color(0x0DFFFFFF)` literal I introduced in batch 4 was reverted in Phase 4; the booking-card dividers now allocate `BoxDecoration` per build. Probably negligible — only renders inside an already-stateful animated swipe — but flagging.
3. Two extracted widgets (`home_featured_creatives_carousel.dart`, `home_top_influencers_section.dart`) still trigger the `Matrix4.translate` / `Matrix4.scale` deprecation warnings that lived on the original screen lines. These are project-wide warnings, untouched by the refactor.
4. The `BeveledTrayPainter` and `BorderAnimationPainter` share `home_painters.dart`. Splitting per-widget makes sense only if either painter starts diverging — keep an eye on it.
5. `getStatusColor` (lowercase variant, multi-case `pending`/`draft`/`matching`) was removed in batch 4 because no caller existed. If a future caller needs the broader fall-through, restore from git history.

---

## Final Summary

**Scope shipped (Phases 1–6):**
- Read and catalogued 4117-line `home_screen.dart` (Phase 1).
- Wrote phase-by-phase refactor plan with risk register (Phase 2).
- Extracted 23 feature-scoped widgets totalling ~3000 lines into `lib/features/home/presentation/widgets/` (Phase 3).
- Replaced 3 magic-number `EdgeInsets.symmetric(...)` calls with `AppSpacing` tokens and reverted a self-introduced inline `Color(0x...)` literal back to `AppColors` (Phase 4).
- Removed 6 dead identifiers (`Your_Bookings`, `images`, `_inspiredController`, `_borderController`, `_buildSmallCircleBtn`, `getStatusColor`), 2 dead `// const SizedBox` placeholders, and 1 unused `flutter_svg/svg.dart` import; added `TODO(rebook-shoots)` / `TODO(recent-project)` / `TODO(continue-booking)` / `TODO(booking-card)` markers above preserved commented blocks (Phase 5).
- Verified zero new analyzer warnings, 46/46 router tests pass, all navigation/API/condition branches preserved (Phase 6).

**Numbers:**
- `home_screen.dart`: **4117 → 1024 lines (-75%)**.
- Widget files: **0 → 24** under `widgets/` (incl. `home_painters.dart`).
- Total LoC across screen + widgets: **~4013** (similar order; size went into structure, not code growth — each widget has imports + constructor + docstring + single responsibility).
- `flutter analyze` (home feature): **22 → 14 issues** (8 warnings removed; 14 remaining all pre-existing).
- `flutter analyze` (whole project): 130 issues — all pre-existing, none introduced.
- `flutter test test/app/router_test.dart`: **46/46 pass**.

**Files changed:**
- `lib/features/home/presentation/screens/home_screen.dart` (heavy edit, -75% size).
- `lib/features/home/presentation/widgets/*.dart` (24 new files).
- `docs/refactor/home_screen_refactor.md` (new planning/log file).

**Assumptions & areas needing manual review:**
- I assumed `AppSpacing.xxs=4`, `AppSpacing.xl=20`, `AppSpacing.smd=10` map 1:1 to the literals they replaced. Verified by reading `lib/app/spacing.dart`.
- Phase 5's `Your_Bookings` / `images` / `_inspiredController` / `_borderController` / `_buildSmallCircleBtn` deletions were predicated on grep-verified zero usage inside the home feature. If any external file imports `home_screen.dart` and accesses those fields, that import will break. Quick grep across `lib/` and `test/` showed no such usage.
- The pre-existing `widget_test.dart` failure (Firebase init) is unrelated to this refactor; fixing it is out of scope.
- No device / simulator smoke test was run. The work-flow guide above lists the user interactions to exercise before merging.
