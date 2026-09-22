# Styling System Audit — Beige App

> Audited: 2026-04-19
> Target: AppColors, AppTextStyles, AppSpacing, AppRadii, AppShadows, AppDurations, AppTheme (from FLUTTER_DESIGN_SYSTEM.md)

---

## Summary Table

| Category | Current State | Gap vs Target | Priority |
|---|---|---|---|
| ThemeData | Minimal — scaffold bg + AppBar only | Full `AppTheme.light()` / `AppTheme.dark()` with all component themes | **P1** |
| Dark mode | `ColorScheme.dark()` stub — not a real dark theme | Full dark color scheme + `ThemeMode.system` | **P2** |
| Material 3 | Commented out (`// useMaterial3: false`) | `useMaterial3: true` required | **P1** |
| `lib/app/` directory | Does not exist | Entire `lib/app/` folder must be created | **P1** |
| AppColors | `ColorCode.dart` exists but wrong pattern | Replace with semantically named `AppColors` | **P1** |
| AppTextStyles | Does not exist | 568 inline `TextStyle()` calls to replace | **P1** |
| AppSpacing | Does not exist | 458 inline `EdgeInsets` calls to replace | **P1** |
| AppRadii | Does not exist | 350 inline `BorderRadius` calls to replace | **P1** |
| AppShadows | Does not exist | Shadows hardcoded inline where used | **P2** |
| AppDurations | Does not exist | 60 inline `Duration()` calls to replace | **P2** |
| AppAssets | `images.dart` exists — 14 entries only | 9 usages of class vs hundreds of hardcoded strings | **P2** |
| Theme.of(context) | Used 2 times total (`SliderTheme` only) | All surface/text/border colors must go through theme | **P1** |
| Semantics/Accessibility | 0 usages | semanticsLabel, text scale clamping needed | **P2** |

---

## 1. CURRENT THEME

### ThemeData — defined in `lib/main.dart` (lines 106–150)

```dart
theme: ThemeData(
  scaffoldBackgroundColor: ColorCode.bcakgroundcolor,  // dark background
  appBarTheme: const AppBarTheme(
    backgroundColor: ColorCode.bcakgroundcolor,
    iconTheme: IconThemeData(color: Colors.white),
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.transparent,
  ),
  colorScheme: ColorScheme.dark(
    background: ColorCode.bcakgroundcolor,
    primary: Colors.white,
  ),
  splashFactory: NoSplash.splashFactory,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  hoverColor: Colors.transparent,
  elevatedButtonTheme: ...,  // splash removal only
  textButtonTheme: ...,      // splash removal only
  outlinedButtonTheme: ...,  // splash removal only
)
```

| Question | Answer |
|---|---|
| ThemeData defined? | Yes — minimal, in `main.dart` |
| Dark mode supported? | No — `ColorScheme.dark()` is used for a single-color override, not a real dark theme. `darkTheme:` is not set |
| `useMaterial3: true`? | No — commented out: `// useMaterial3: false` |
| Centralized `AppTheme.light()` / `AppTheme.dark()`? | No — inline `ThemeData(...)` anonymous object in `main.dart` |
| Button/input/card/dialog themes? | None — only button splash removal |
| Text theme? | Not set — all text styled inline |
| 2 previous commented-out `theme:` blocks? | Yes — 2 full commented ThemeData blocks remain in `main.dart` (lines 56–105) |

---

## 2. DESIGN TOKEN FILES — EXISTENCE CHECK

| Target File | Exists? | Completeness | Notes |
|---|---|---|---|
| `lib/app/colors.dart` | ❌ No | 0% | `lib/app/` directory does not exist |
| `lib/app/text_styles.dart` | ❌ No | 0% | — |
| `lib/app/spacing.dart` | ❌ No | 0% | — |
| `lib/app/radii.dart` | ❌ No | 0% | — |
| `lib/app/shadows.dart` | ❌ No | 0% | — |
| `lib/app/durations.dart` | ❌ No | 0% | — |
| `lib/app/theme.dart` | ❌ No | 0% | — |
| `lib/app/assets.dart` | ❌ No | 0% | — |

### What exists instead

| Existing File | Purpose | Quality |
|---|---|---|
| `lib/utility/ColorCode.dart` | 50+ color constants | Wrong naming (`k282828`, `bcakgroundcolor`) — no semantic intent |
| `lib/utility/images.dart` | 14 SVG/asset path constants | Partial — only SVGs, ignored by most screens |
| `lib/utility/date_time_utils.dart` | Date formatting utilities | Not related to design tokens |

---

## 3. HARDCODED STYLES SCAN

### Total Count by Type

| Type | Count | Notes |
|---|---|---|
| `Color(0xFF...)` / `Color(0x...)` inline | **311** | Spread across 35+ files |
| `Colors.xxx` (Material colors) | **732** | `Colors.white` (363), `Colors.black` (142), `Colors.transparent` (73), others (154) |
| `TextStyle(...)` inline | **568** | Zero use of any shared text style class |
| `EdgeInsets.xxx` inline | **458** | All magic numbers |
| `BorderRadius.circular(...)` inline | **350** | 10+ distinct values used |
| `fontSize:` hardcoded | **502** | Across all TextStyle definitions |
| `Duration(milliseconds: ...)` inline | **60** | Scattered across animations |
| **TOTAL hardcoded style values** | **~2,981** | — |

### Top 10 Most Repeated Hardcoded Values

| Rank | Value | Count | Should Be |
|---|---|---|---|
| 1 | `fontSize: 14` | 183 | `AppTextStyles.bodyMedium` |
| 2 | `FontWeight.w500` (inline) | 192 | Part of `AppTextStyles` |
| 3 | `Colors.white` | 363 | `AppColors.textOnColor` or `Theme.of(context)` |
| 4 | `BorderRadius.circular(12)` | 104 | `AppRadii.mdAll` |
| 5 | `fontSize: 12` | 85 | `AppTextStyles.bodySmall` / `labelMedium` |
| 6 | `fontSize: 16` | 82 | `AppTextStyles.bodyLarge` / `titleSmall` |
| 7 | `SizedBox(height: 20)` | 75 | `SizedBox(height: AppSpacing.lg)` |
| 8 | `Colors.black` | 142 | `AppColors.textPrimary` or `Theme.of(context)` |
| 9 | `Color(0xFFE8D1AB)` | 48+13 = **61** | `AppColors.primary` (brand gold — used but not in ColorCode) |
| 10 | `BorderRadius.circular(14)` | 50 | `AppRadii` (undefined value — needs new token) |

> `Color(0xFFE8D1AB)` — the primary brand gold — appears **61 times** inline (48 as `0xFFE8D1AB` + 13 as `0xffE8D1AB` with different casing), despite being the single most important brand color. It is in `ColorCode.kButtonColor` and `ColorCode.kGoldBorder` but screens bypass the class and hardcode it directly.

---

## 4. TEXT STYLE ANALYSIS

### Naming Convention

❌ **No shared text style class exists.** All 568 `TextStyle()` calls are inline.

```dart
// What exists everywhere in the codebase:
Text('Title', style: TextStyle(
  fontFamily: 'Outfit',
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Colors.white,
))

// What the target requires:
Text('Title', style: AppTextStyles.titleSmall)
```

### Font Families in Use

| Font Family | Inline References | In pubspec.yaml? | Notes |
|---|---|---|---|
| `Outfit` | 17 | ✅ Yes | Used for body/label text |
| `Unbounded` | 6 | ✅ Yes | Used for headings |
| `Helvetica Neue` | 4 | ✅ Yes | Used sparingly |
| `InstrumentSans` | 2 | ❌ **No** | Referenced in code but not registered in pubspec — will silently fall back to system font |

**`InstrumentSans` is a bug** — referenced in at least 2 files but missing from `pubspec.yaml`. Text using it renders in the system default font at runtime.

### FontWeight Distribution (all inline)

| Weight | Count |
|---|---|
| `FontWeight.w500` | 192 |
| `FontWeight.w400` | 85 |
| `FontWeight.w600` | 78 |
| `FontWeight.bold` (= w700) | 25 |
| `FontWeight.w700` | 22 |

---

## 5. DARK MODE READINESS

### `Theme.of(context)` usage: **2 total**

Both are `SliderTheme.of(context)` calls (not even `Theme.of(context).colorScheme`) in:
- `auth/new_sing_up_screen.dart:280`
- `MyProfile/edit_profile.dart:421`

There is **zero** use of `Theme.of(context).colorScheme`, `Theme.of(context).textTheme`, or `Theme.of(context).scaffoldBackgroundColor` anywhere in the UI code.

### How colors are applied

```dart
// What the entire codebase does (dark mode BREAKS):
color: Colors.white
color: ColorCode.bcakgroundcolor  // hardcoded dark bg
color: Color(0xFFE8D1AB)          // hardcoded gold

// What the target requires (dark mode works automatically):
color: Theme.of(context).colorScheme.onSurface
color: Theme.of(context).scaffoldBackgroundColor
color: AppColors.primary  // brand colors are same in both modes
```

| Color type | Current approach | Dark mode safe? |
|---|---|---|
| Background | `ColorCode.bcakgroundcolor` hardcoded | ❌ No |
| Text | `Colors.white` / `Colors.black` direct | ❌ No |
| Brand gold | `Color(0xFFE8D1AB)` inline | ⚠️ Acceptable for brand color |
| Surfaces | `Color(0xFF1E1E1E)`, `Color(0xFF121212)` etc. inline | ❌ No |
| Borders | `Color(0xFF282828)` etc. inline | ❌ No |

### Files using `Colors.white` / `Colors.black` directly

- `Colors.white`: **363 instances** across ~35 files
- `Colors.black`: **142 instances** across ~25 files

Every one of these is a dark mode bug waiting to happen when light mode or system theme switching is added.

---

## 6. ACCESSIBILITY

| Check | Status | Details |
|---|---|---|
| `semanticsLabel` on icon buttons | ❌ None | 0 usages found across all files |
| `Semantics()` widget | ❌ None | 0 usages found |
| Text scale clamping on rigid UI | ❌ None | `TextScaler` / `textScaleFactor` not used anywhere |
| Touch target minimum (48×48dp) | ⚠️ Unknown | No standardized button height — buttons sized by content with arbitrary padding |
| Most common SizedBox heights | `20`, `10`, `12`, `8` | Used as spacers, not as touch targets — actual tap areas unverified |

---

## 7. ASSET MANAGEMENT

### Current State

| Mechanism | Files Using It | Coverage |
|---|---|---|
| `images.dart` constants class | ~9 usages | ~5% of asset references |
| Hardcoded `'assets/...'` strings inline | ~hundreds | ~95% of asset references |

### `images.dart` quality issues

- Only 14 constants defined (SVGs only)
- Class named `images` (lowercase — violates Dart style)
- Contains blank lines where constants were removed
- Does not cover: `assets/images/`, `assets/lottie/`, `assets/new_home/`, `assets/Icons/`, `assets/Onboding/`, `assets/Splash/`

### Most hardcoded asset strings (by repetition)

```dart
'assets/svg/true.svg'          // 2x hardcoded
'assets/lottie/success_animation.json'  // scattered
'assets/images/star.png'       // scattered
```

The vast majority of the ~130 active asset files are referenced by hardcoded strings. If any file moves or is renamed, the reference breaks at runtime (no compile-time error).

### Unused asset constants in `images.dart`

```dart
// These constants exist in images.dart but may reference deleted files:
static const String chando1   // likely unused
static const String delete2   // likely unused
static const String appversion3 // likely unused
```

---

## 8. MIGRATION PRIORITIES

### P1 — Blocking (must be done before any feature work on migrated screens)

| Task | Effort | Impact |
|---|---|---|
| Create `lib/app/` directory + all 8 token files | Medium | Unblocks everything else |
| Define `AppColors` with semantic names from brand palette | Medium | Replaces 311 + 732 = 1,043 color references |
| Define `AppTextStyles` with Outfit/Unbounded/Helvetica Neue | Medium | Replaces 568 inline TextStyle() calls |
| Define `AppSpacing` (4px grid) | Small | Replaces 458 EdgeInsets calls |
| Define `AppRadii` | Small | Replaces 350 BorderRadius calls |
| Define `AppTheme.light()` wiring all component themes | Large | Replaces minimal inline ThemeData in main.dart |
| Enable `useMaterial3: true` | Small | Required by design system |
| Fix `InstrumentSans` — add to pubspec or remove from code | Small | Silent runtime bug fix |

### P2 — Required before production design sign-off

| Task | Effort | Impact |
|---|---|---|
| Define `AppShadows` and `AppDurations` | Small | Replaces 60 Duration() calls |
| Implement `AppTheme.dark()` + `ThemeMode.system` | Large | Real dark mode support |
| Replace `Colors.white`/`Colors.black` with `Theme.of(context)` calls | Large | 505 references across 35+ files |
| Add `semanticsLabel` to all icon-only buttons | Medium | Accessibility compliance |
| Add text scale clamping to bottom nav / buttons / tabs | Small | Accessibility compliance |
| Rebuild `AppAssets` class covering all asset paths | Small | Replaces hardcoded strings |

### P3 — Polish

| Task | Effort | Impact |
|---|---|---|
| Standardize touch targets to 48×48dp minimum | Medium | Accessibility |
| Remove 2 commented-out ThemeData blocks from `main.dart` | Trivial | Code hygiene |
| Rename `images` class → `AppAssets` | Trivial | Dart naming conventions |
| Fix `ColorCode` naming (`bcakgroundcolor` typo, hex-based names) | Small | Replaced entirely by AppColors |
