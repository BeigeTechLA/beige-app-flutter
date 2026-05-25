
# Asset Naming Cleanup Plan

Standardize all asset file/folder names to `lowercase_snake_case`. Remove spaces, special chars, Figma export names, hash names, and typos. Centralize all hardcoded paths to `AppAssets`.

## Naming Rules

| Rule | Example |
|------|---------|
| All lowercase | `Filter.svg` → `filter.svg` |
| Underscores only (no spaces/dashes/dots/+) | `AI Matchmaking-1.svg` → `ai_matchmaking_alt.svg` |
| Extensions lowercase | `Photo6.SVG` → `photo_alt.svg` |
| Semantic names (no Figma/hash) | `Group 2087328870.svg` (clock icon) → `clock.svg` |
| Fix typos | `serch.svg` → `search.svg` |
| Drop `_new` suffix | `edit_new.png` → `editing.png` |

---

## Phase 1: Folder Renames ✅ [COMPLETED]

| # | Old Path | New Path | Code Files to Update |
|---|----------|----------|---------------------|
| 1 | `assets/Icons/` | `assets/icons/` | `pubspec.yaml:118`, `lib/app/assets.dart:17` |
| 2 | `assets/Splash/` | `assets/splash/` | `pubspec.yaml:116`, `lib/app/assets.dart:18` |
| 3 | `assets/Onboding/` | `assets/onboarding/` | `pubspec.yaml:117`, `lib/app/assets.dart:19`, `lib/features/onboarding/presentation/screens/onboarding_screen.dart:23,29` |
| 4 | `assets/new_home/` | `assets/home/` | `pubspec.yaml:122`, `lib/app/assets.dart:20`, `lib/features/home/presentation/screens/home_screen.dart` (20+ refs), `lib/features/shoot/presentation/screens/my_shoots_screen.dart:173`, `lib/features/booking/presentation/screens/content_type_screen.dart:230-274` |
| 5 | `assets/new_home/Topwrods/` | `assets/mock_data/top_words/` | `pubspec.yaml:124`, `lib/app/assets.dart:21`, `lib/features/home/presentation/screens/home_screen.dart:182-190` |
| 6 | `assets/svg/my_profile/` | `assets/svg/profile/` | `pubspec.yaml:121`, `lib/app/assets.dart:14`, `lib/features/profile/presentation/screens/profile_screen.dart:242,248,285,297,339,345,396`, `lib/features/profile/presentation/screens/edit_profile_screen.dart:508`, `lib/features/home/presentation/screens/home_screen.dart:844,1463` |
| 7 | `assets/svg/new_bottom_image/` | `assets/svg/bottom_nav/` | `pubspec.yaml:123`, `lib/app/assets.dart:15`, `lib/app/router.dart:527,528,535,536,543,544,551,552` |

---

## Phase 2: SVG Root Files (`assets/svg/`) ✅ [COMPLETED]

| # | Old Name | New Name | Reason | Verified As | Code Files to Update |
|---|----------|----------|--------|-------------|---------------------|
| 1 | `AI Matchmaking-1.svg` | `ai_matchmaking_alt.svg` | spaces, dash | AI feature icon | `lib/app/assets.dart:69` |
| 2 | `AI-Powered Post-Production.svg` | `ai_post_production.svg` | spaces, dashes | AI feature icon | `lib/app/assets.dart:70` |
| 3 | `AI_Matchmaking.svg` | `ai_matchmaking.svg` | PascalCase | AI feature icon | `lib/app/assets.dart:68` |
| 4 | `All_Raw_Content.svg` | `all_raw_content.svg` | PascalCase | feature icon | `lib/app/assets.dart:71`, `lib/features/booking/presentation/screens/shoot_review_screen.dart:824` |
| 5 | `CameraMinimalistic.svg` | `camera_minimalistic.svg` | PascalCase | camera icon | `lib/app/assets.dart:55` |
| 6 | `Filter.svg` | `filter.svg` | PascalCase | filter funnel icon | `lib/app/assets.dart:34`, `lib/features/booking/presentation/screens/crew_selection_screen.dart:332` |
| 7 | `Frame.svg` | `calendar_date.svg` | Figma name (actually calendar with date markers) | calendar/date icon (SVG confirmed) | `lib/app/assets.dart:59`, `lib/features/shoot/presentation/screens/manage_shoot_screen.dart:303,322`, `lib/features/shoot/presentation/screens/cancel_shoot_screen.dart:298,317`, `lib/features/shoot/presentation/screens/shoot_edit_review_screen.dart:303,321`, `lib/features/booking/presentation/screens/shoot_review_screen.dart:512,533` |
| 8 | `Group 2087328870.svg` | `clock.svg` | Figma name (actually clock circle with hands) | clock/time icon (SVG confirmed: circle + clock hands) | `lib/features/booking/presentation/screens/shoot_date_time_screen.dart:1743,1761,1779,1797,1854,1882,1905,1931,2091`, `lib/features/shoot/presentation/screens/manage_shoot_screen.dart:308,328`, `lib/features/shoot/presentation/screens/cancel_shoot_screen.dart:303,324`, `lib/features/shoot/presentation/screens/shoot_edit_review_screen.dart:297,315`, `lib/features/booking/presentation/screens/shoot_review_screen.dart:504,525` |
| 9 | `Group_2087329363.svg` | `info.svg` | Figma name (actually info "i" icon) | info icon (SVG confirmed: dark square with "i") | search codebase — may be unused |
| 10 | `Heart.svg` | `heart.svg` | PascalCase | heart outline | `lib/app/assets.dart:53`, `lib/features/booking/presentation/screens/crew_selection_screen.dart:843` |
| 11 | `Heart_COLOR.svg` | `heart_filled.svg` | unclear name | heart filled/colored | `lib/app/assets.dart:54`, `lib/features/booking/presentation/screens/crew_selection_screen.dart:842` |
| 12 | `Icon_.svg` | `video_camera.svg` | trailing underscore (actually video camera) | video camera icon (SVG confirmed: camera + lens) | search codebase — may be unused |
| 13 | `Include_Edited_Deliverable .svg` | `include_edited_deliverable.svg` | PascalCase, trailing space | feature icon | `lib/app/assets.dart:73`, `lib/features/booking/presentation/screens/shoot_review_screen.dart:829` |
| 14 | `Instagram.svg` | `instagram.svg` | PascalCase | social icon | `lib/app/assets.dart:81` |
| 15 | `LocationPin.svg` | `location_pin.svg` | PascalCase | map pin icon | `lib/app/assets.dart:38`, `lib/features/auth/presentation/screens/sign_up_screen.dart:894` |
| 16 | `Photo.svg` | `photo.svg` | PascalCase | photo icon | `lib/app/assets.dart:56` |
| 17 | `Photo6.SVG` | `photo_alt.svg` | PascalCase, uppercase ext | photo variant | `lib/app/assets.dart:57` |
| 18 | `Production.svg` | `production.svg` | PascalCase | feature icon | `lib/app/assets.dart:75` |
| 19 | `Tiktok.svg` | `tiktok.svg` | PascalCase | social icon | `lib/app/assets.dart:82` |
| 20 | `Unlimited_Usage_Rights.svg` | `unlimited_usage_rights.svg` | PascalCase | feature icon | `lib/app/assets.dart:72`, `lib/features/booking/presentation/screens/shoot_review_screen.dart:819` |
| 21 | `Up_to _Sets _Revisions.svg` | `up_to_sets_revisions.svg` | spaces in name | feature icon | `lib/app/assets.dart:74`, `lib/features/booking/presentation/screens/shoot_review_screen.dart:834` |
| 22 | `Youtube.svg` | `youtube.svg` | PascalCase | social icon | `lib/app/assets.dart:83` |
| 23 | `calendar-03.svg` | `calendar.svg` | dash, number | calendar icon | `lib/app/assets.dart:39`, `lib/features/booking/presentation/screens/shoot_date_time_screen.dart:1970,2062` |
| 24 | `notification.1.svg` | `notification.svg` | dot in name | bell icon | `lib/app/assets.dart:36` |
| 25 | `persone.svg` | `person.svg` | typo | person silhouette | `lib/app/assets.dart:51`, `lib/features/auth/presentation/screens/sign_up_screen.dart:1374,1462` |
| 26 | `serch.svg` | `search.svg` | typo | search/magnifier | `lib/app/assets.dart:35` |
| 27 | `imag_placeholder.svg` | `image_placeholder.svg` | typo | placeholder for missing images | `lib/app/assets.dart:62`, `lib/features/shoot/presentation/screens/manage_shoot_screen.dart:73,79,204,212`, `lib/features/shoot/presentation/screens/cancel_shoot_screen.dart:86,93,203,211`, `lib/features/shoot/presentation/screens/shoot_edit_review_screen.dart:194,202`, `lib/features/booking/presentation/screens/shoot_review_screen.dart:407,414`, `lib/features/home/presentation/screens/recommended_creative_detail_screen.dart:94,223,273`, `lib/features/shoot/presentation/screens/my_shoots_screen.dart:308,381,443,451`, `lib/features/booking/presentation/screens/crew_selection_screen.dart:780` |
| 28 | `zoom+.svg` | `zoom_in.svg` | special char | zoom in icon | `lib/app/assets.dart:42` |
| 29 | `zoom-.svg` | `zoom_out.svg` | special char | zoom out icon | `lib/app/assets.dart:43` |
| 30 | `chando.svg` | `change_password.svg` | meaningless name | password icon | `lib/app/assets.dart:96` |
| 31 | `chando1.svg` | `change_password_alt.svg` | meaningless name | password icon variant | `lib/app/assets.dart:97` |
| 32 | `true.svg` | `checkmark.svg` | misleading name (actually checkmark) | checkmark (SVG confirmed) | `lib/features/booking/presentation/screens/shoot_date_time_screen.dart:1943` |

---

## Phase 3: SVG Profile Subfolder (`assets/svg/my_profile/` → `assets/svg/profile/`) ✅ [COMPLETED]

| # | Old Name | New Name | Reason | Code Files to Update |
|---|----------|----------|--------|---------------------|
| 1 | `App_Preferences.svg` | `app_preferences.svg` | PascalCase | `lib/features/profile/presentation/screens/profile_screen.dart:339` |
| 2 | `BookingHistory.svg` | `booking_history.svg` | PascalCase | `lib/features/profile/presentation/screens/profile_screen.dart:248` |
| 3 | `Favourites.svg` | `favourites.svg` | PascalCase | `lib/features/profile/presentation/screens/profile_screen.dart:242` |
| 4 | `Help & Support.svg` | `help_support.svg` | space, ampersand | search codebase — may be unused |
| 5 | `Logout.svg` | `logout.svg` | PascalCase | `lib/features/profile/presentation/screens/profile_screen.dart:345` |
| 6 | `Notifications Settings.svg` | `notification_settings.svg` | space, PascalCase | search codebase — may be unused |
| 7 | `Payment methods.svg` | `payment_methods.svg` | space | search codebase — may be unused |
| 8 | `Privacy Policy.svg` | `privacy_policy.svg` | space, PascalCase | `lib/features/profile/presentation/screens/profile_screen.dart:297` |
| 9 | `Terms & Condition.svg` | `terms_conditions.svg` | space, ampersand | `lib/features/profile/presentation/screens/profile_screen.dart:285` |
| 10 | `edit.svg` | `edit.svg` | already correct | `lib/features/profile/presentation/screens/edit_profile_screen.dart:508` |
| 11 | `layer1.svg` | `chevron_right.svg` | meaningless name (actually right arrow chevron) | `lib/features/profile/presentation/screens/profile_screen.dart:396`, `lib/features/home/presentation/screens/home_screen.dart:844,1463` |

---

## Phase 4: SVG Bottom Nav Subfolder (`assets/svg/new_bottom_image/` → `assets/svg/bottom_nav/`) ✅ [COMPLETED]

| # | Old Name | New Name | Reason | Code Files to Update |
|---|----------|----------|--------|---------------------|
| 1 | `active_Book a Shoot.svg` | `active_book_shoot.svg` | space, PascalCase | `lib/app/router.dart:535` |
| 2 | `active_Home.svg` | `active_home.svg` | PascalCase | `lib/app/router.dart:527` |
| 3 | `active_Messages.svg` | `active_messages.svg` | PascalCase | `lib/app/router.dart:551` |
| 4 | `active_My Shoots.svg` | `active_my_shoots.svg` | space, PascalCase | `lib/app/router.dart:543` |
| 5 | `in_active_Book_Shoot.svg` | `inactive_book_shoot.svg` | inconsistent prefix | `lib/app/router.dart:536` |
| 6 | `in_active_Home.svg` | `inactive_home.svg` | inconsistent prefix | `lib/app/router.dart:528` |
| 7 | `in_active_Messages.svg` | `inactive_messages.svg` | inconsistent prefix | `lib/app/router.dart:552` |
| 8 | `in_active_My Shoots.svg` | `inactive_my_shoots.svg` | space, inconsistent prefix | `lib/app/router.dart:544` |

---

## Phase 5: Icons Folder (`assets/Icons/` → `assets/icons/`) ✅ [COMPLETED]

| # | Old Name | New Name | Reason | Code Files to Update |
|---|----------|----------|--------|---------------------|
| 1 | `Share 2.png` | `share.png` | space, number | search codebase — may be unused |
| 2 | `Heart_Angl_COLOR.png` | `heart_angle_filled.png` | PascalCase, abbreviation | `lib/features/booking/presentation/screens/crew_selection_screen.dart:446` |
| 3 | `user_chec_time_linek.png` | `user_check_timeline.png` | typos | `lib/features/shoot/presentation/screens/shoot_summary_screen.dart:656` |
| 4 | `emoji_photo.png` | `emoji_photo.png` | already correct | `lib/features/booking/presentation/screens/shoot_date_time_screen.dart:2896` |
| 5 | `inactive_book_shoot.png` | `inactive_book_shoot.png` | already correct | search codebase |
| 6 | `inactive_booking.png` | `inactive_booking.png` | already correct | search codebase |
| 7 | `sale.png` | `sale.png` | already correct | `lib/features/booking/presentation/screens/crew_selection_screen.dart:682` |
| 8 | `stripe.png` | `stripe.png` | already correct | `lib/features/booking/presentation/screens/payment_method_screen.dart:190,290` |

---

## Phase 6: Mock Data Separation & Images Folder (`assets/images/`) ✅ [COMPLETED]

Mock/dummy data will be moved to `assets/mock_data/creatives/` to keep core UI assets clean.

| # | Old Name | New Name | Reason | Code Files to Update |
|---|----------|----------|--------|---------------------|
| 1 | `Alec+H.png` | `assets/mock_data/creatives/alec_h.png` | `+` char, move to mock | search codebase |
| 2 | `Christopher+R.png` | `assets/mock_data/creatives/christopher_r.png` | `+` char, move to mock | search codebase |
| 3 | `Corey+B.png` | `assets/mock_data/creatives/corey_b.png` | `+` char, move to mock | search codebase |
| 4 | `Cornelius+M. (1).png` | `assets/mock_data/creatives/cornelius_m.png` | `+`, parens, move to mock | search codebase |
| 5 | `Daniel+A.png` | `assets/mock_data/creatives/daniel_a.png` | `+` char, move to mock | search codebase |
| 6 | `Daniel+C.png` | `assets/mock_data/creatives/daniel_c.png` | `+` char, move to mock | search codebase |
| 7 | `Gary+Ahmed.png` | `assets/mock_data/creatives/gary_ahmed.png` | `+` char, move to mock | search codebase |
| 8 | `Mikey+D (1).jpg` | `assets/mock_data/creatives/mikey_d.jpg` | `+`, parens, move to mock | search codebase |
| 9 | `Nathan+Grant.png` | `assets/mock_data/creatives/nathan_grant.png` | `+` char, move to mock | search codebase |
| 10 | `Group 1171276698 (1).png` | `booking_confirmed.png` | Figma name (actually calendar + shield checkmark) | `lib/features/shoot/presentation/screens/cancel_shoot_screen.dart:445` |
| 11 | `Group 2087328887.png` | `equipment_icon.png` | Figma name (actually drum/equipment icon in dark square) | search codebase |
| 12 | `Group 2087328980.png` | `navigate_arrow.png` | Figma name (actually dark circle with arrow) | `lib/features/booking/presentation/screens/crew_selection_screen.dart:640` |
| 13 | `Image.png` | `role_selection.png` | generic name | `lib/features/auth/presentation/screens/sign_up_screen.dart:271,312` |
| 14 | `Rectangle_574057023.png` | `auth_background.png` | Figma name | `lib/features/auth/presentation/screens/login_screen.dart:124`, `lib/features/auth/presentation/screens/forgot_password_screen.dart:90`, `lib/features/auth/presentation/screens/reset_password_screen.dart:102`, `lib/features/auth/presentation/screens/sign_up_screen.dart:748`, `lib/features/auth/presentation/screens/forgot_password_otp_screen.dart:129` |
| 15 | `Rectangle 34661070.png` | `creative_card_bg.png` | Figma name, space | `lib/features/booking/presentation/screens/crew_selection_screen.dart:381,784` |
| 16 | `Heart Angle.png` | `heart_angle.png` | space, PascalCase | `lib/features/booking/presentation/screens/crew_selection_screen.dart:447` |
| 17 | `mappp.png` | `map.png` | typo | search codebase |
| 18 | `chooese_your_role2.png` | `choose_your_role.png` | typo | search codebase |
| 19 | `home2.png` | `home2.png` | acceptable | search codebase |
| 20 | `man2.png` | `man2.png` | acceptable | search codebase |
| 21 | `profile.png` | `profile.png` | already correct | search codebase |
| 22 | `star.png` | `star.png` | already correct | search codebase |

---

## Phase 7: Home Folder (`assets/new_home/` → `assets/home/`) ✅ [COMPLETED]

| # | Old Name | New Name | Verified As | Reason | Code Files to Update |
|---|----------|----------|-------------|--------|---------------------|
| 1 | `4ce6dbc682ece...f13.png` | `assets/mock_data/studios/beige_media.png` | Studio listing image | hash name, move to mock | `lib/features/home/presentation/screens/home_screen.dart:145` |
| 2 | `77443dc57b82c...dff.png` | `assets/mock_data/studios/creative_zone.png` | Studio listing image | hash name, move to mock | `lib/features/home/presentation/screens/home_screen.dart:154` |
| 3 | `baab5672af97f...353.png` | `assets/mock_data/studios/beige_media_alt.png` | Studio listing image | hash name, move to mock | `lib/features/home/presentation/screens/home_screen.dart:162` |
| 4 | `Group 2087329746.png` | `home_card_bg.png` | Hero card background image | Figma name, space | `lib/features/home/presentation/screens/home_screen.dart:79,100,2617` |
| 5 | `Image_fx (5) 1.png` | `home_fx_image.png` | Unknown usage | parens, spaces | search codebase — may be unused |
| 6 | `Livestream_new.png` | `livestream.png` | Service category icon | PascalCase, `_new` | `lib/features/home/presentation/screens/home_screen.dart:861`, `lib/features/booking/presentation/screens/content_type_screen.dart:274` |
| 7 | `Videography.png` | `videography.png` | Service category icon | PascalCase | `lib/features/home/presentation/screens/home_screen.dart:859`, `lib/features/booking/presentation/screens/content_type_screen.dart:238` |
| 8 | `Your-Bookings.png` | `your_bookings.png` | Bookings section image | PascalCase, dash | `lib/features/home/presentation/screens/home_screen.dart:2706` |
| 9 | `RebookYourShoots_img.webp` | `rebook_your_shoots.webp` | Rebook CTA image | PascalCase | `lib/features/home/presentation/screens/home_screen.dart:1920` |
| 10 | `stuido_new.png` | `studio.png` | Service category icon | typo, `_new` | `lib/features/home/presentation/screens/home_screen.dart:862`, `lib/features/booking/presentation/screens/content_type_screen.dart:256` |
| 11 | `upcoming_nodata_imge.png` | `upcoming_no_data.png` | Empty state for upcoming shoots | typo | `lib/features/shoot/presentation/screens/my_shoots_screen.dart:173` |
| 12 | `homebackground_new.png` | `home_background.png` | Hero card background variant | `_new` | `lib/features/home/presentation/screens/home_screen.dart:85,91` |
| 13 | `home_book1.png` | `home_book_1.png` | Hero card foreground image | inconsistent numbering | `lib/features/home/presentation/screens/home_screen.dart:80,101` |
| 14 | `home_book_2.png` | `home_book_2.png` | Hero card foreground image | already correct | `lib/features/home/presentation/screens/home_screen.dart:86` |
| 15 | `home_book3.png` | `home_book_3.png` | Hero card foreground image | inconsistent numbering | `lib/features/home/presentation/screens/home_screen.dart:92` |
| 16 | `photography.png` | `photography.png` | Service category icon | already correct | `lib/features/home/presentation/screens/home_screen.dart:858`, `lib/features/booking/presentation/screens/content_type_screen.dart:247` |
| 17 | `selectall.png` | `select_all.png` | "All" content type icon | missing underscore | `lib/features/booking/presentation/screens/content_type_screen.dart:230` |
| 18 | `edit_new.png` | `editing.png` | Service category icon | `_new` | `lib/features/home/presentation/screens/home_screen.dart:860`, `lib/features/booking/presentation/screens/content_type_screen.dart:265` |
| 19 | `photo_new.png` | `photo.png` | Unknown usage | `_new` | search codebase — may be unused |

### Home — Top Words Subfolder (`assets/new_home/Topwrods/` → `assets/mock_data/top_words/`)

Moved to `mock_data` to separate demo content from core UI assets.

| # | Old Name | New Name | Reason | Code Files to Update |
|---|----------|----------|--------|---------------------|
| 1 | `Justin Beiber.webp` | `justin_bieber.webp` | space, typo ("Beiber" → "Bieber") | `lib/features/home/presentation/screens/home_screen.dart:182` |
| 2 | `Cedric The Entertainer.webp` | `cedric_the_entertainer.webp` | spaces | `lib/features/home/presentation/screens/home_screen.dart:183` |
| 3 | `Wiz Khalifa.webp` | `wiz_khalifa.webp` | space | `lib/features/home/presentation/screens/home_screen.dart:184` |
| 4 | `Pressa.webp` | `pressa.webp` | PascalCase | `lib/features/home/presentation/screens/home_screen.dart:185` |
| 5 | `Tyga.webp` | `tyga.webp` | PascalCase | `lib/features/home/presentation/screens/home_screen.dart:186` |
| 6 | `CentralCee.webp` | `central_cee.webp` | PascalCase | `lib/features/home/presentation/screens/home_screen.dart:187` |
| 7 | `Chief Keef.webp` | `chief_keef.webp` | space | `lib/features/home/presentation/screens/home_screen.dart:188` |
| 8 | `Swae Lee.webp` | `swae_lee.webp` | space | `lib/features/home/presentation/screens/home_screen.dart:189` |
| 9 | `Natasha Graziano.jpg` | `natasha_graziano.jpg` | space | `lib/features/home/presentation/screens/home_screen.dart:190` |

---

## Phase 8: Splash Folder (`assets/Splash/` → `assets/splash/`) ✅ [COMPLETED]

| # | Old Name | New Name | Reason | Code Files to Update |
|---|----------|----------|--------|---------------------|
| 1 | `Property_1.png` | `splash_1.png` | PascalCase, generic | `lib/features/splash/presentation/screens/splash_screen.dart:25` |
| 2 | `Property_2.png` | `splash_2.png` | PascalCase, generic | `lib/features/splash/presentation/screens/splash_screen.dart:26` |
| 3 | `Property_3.png` | `splash_3.png` | PascalCase, generic | `lib/features/splash/presentation/screens/splash_screen.dart:27` |
| 4 | `Property_4.png` | `splash_4.png` | PascalCase, generic | `lib/features/splash/presentation/screens/splash_screen.dart:28` |
| 5 | `Propety_5.png` | `splash_5.png` | PascalCase, typo ("Propety") | `lib/features/splash/presentation/screens/splash_screen.dart:29` |
| 6 | `Property_6.png` | `splash_6.png` | PascalCase, generic | `lib/features/splash/presentation/screens/splash_screen.dart:30` |

---

## Phase 9: Onboarding Folder (`assets/Onboding/` → `assets/onboarding/`) ✅ [COMPLETED]

| # | Old Name | New Name | Reason | Code Files to Update |
|---|----------|----------|--------|---------------------|
| 1 | `img.webp` | `onboarding_1.webp` | generic name | `lib/features/onboarding/presentation/screens/onboarding_screen.dart:29` |
| 2 | `img_1.webp` | `onboarding_2.webp` | generic name | `lib/features/onboarding/presentation/screens/onboarding_screen.dart:23` |

---

## Phase 10: Centralize Hardcoded Paths to `AppAssets` ✅ [COMPLETED]

After all renames, replace every inline `"assets/..."` string with `AppAssets.*` constant.

### Missing constants to add in `lib/app/assets.dart`

| Constant Name | Path | Used In |
|---------------|------|---------|
| `activeHome` | `$svgBottom/active_home.svg` | `router.dart:527` |
| `inactiveHome` | `$svgBottom/inactive_home.svg` | `router.dart:528` |
| `activeBookShoot` | `$svgBottom/active_book_shoot.svg` | `router.dart:535` |
| `inactiveBookShoot` | `$svgBottom/inactive_book_shoot.svg` | `router.dart:536` |
| `activeMyShoot` | `$svgBottom/active_my_shoots.svg` | `router.dart:543` |
| `inactiveMyShoot` | `$svgBottom/inactive_my_shoots.svg` | `router.dart:544` |
| `activeMessages` | `$svgBottom/active_messages.svg` | `router.dart:551` |
| `inactiveMessages` | `$svgBottom/inactive_messages.svg` | `router.dart:552` |
| `clock` | `$_svg/clock.svg` | `shoot_date_time_screen.dart` (9 refs), `manage_shoot_screen.dart` (2), `cancel_shoot_screen.dart` (2), `shoot_edit_review_screen.dart` (2), `shoot_review_screen.dart` (2) |
| `calendarDate` | `$_svg/calendar_date.svg` | `manage_shoot_screen.dart` (2), `cancel_shoot_screen.dart` (2), `shoot_edit_review_screen.dart` (2), `shoot_review_screen.dart` (2) |
| `checkmark` | `$_svg/checkmark.svg` | `shoot_date_time_screen.dart:1943` |
| `authBackground` | `$images/auth_background.png` | `login_screen.dart`, `sign_up_screen.dart`, `forgot_password_screen.dart`, `reset_password_screen.dart`, `forgot_password_otp_screen.dart` |
| `roleSelection` | `$images/role_selection.png` | `sign_up_screen.dart:271,312` |
| `creativeCardBg` | `$images/creative_card_bg.png` | `crew_selection_screen.dart:381,784` |
| `heartAngle` | `$images/heart_angle.png` | `crew_selection_screen.dart:447` |
| `heartAngleFilled` | `$icons/heart_angle_filled.png` | `crew_selection_screen.dart:446` |
| `navigateArrow` | `$images/navigate_arrow.png` | `crew_selection_screen.dart:640` |
| `saleIcon` | `$icons/sale.png` | `crew_selection_screen.dart:682` |
| `stripeIcon` | `$icons/stripe.png` | `payment_method_screen.dart:190,290` |
| `bookingConfirmed` | `$images/booking_confirmed.png` | `cancel_shoot_screen.dart:445` |
| `userCheckTimeline` | `$icons/user_check_timeline.png` | `shoot_summary_screen.dart:656` |
| `emojiPhoto` | `$icons/emoji_photo.png` | `shoot_date_time_screen.dart:2896` |
| `upcomingNoData` | `$newHome/upcoming_no_data.png` | `my_shoots_screen.dart:173` |
| `homeCardBg` | `$newHome/home_card_bg.png` | `home_screen.dart:79,100,2617` |
| `homeBackground` | `$newHome/home_background.png` | `home_screen.dart:85,91` |
| `homeBook1` | `$newHome/home_book_1.png` | `home_screen.dart:80,101` |
| `homeBook2` | `$newHome/home_book_2.png` | `home_screen.dart:86` |
| `homeBook3` | `$newHome/home_book_3.png` | `home_screen.dart:92` |
| `servicePhotography` | `$newHome/photography.png` | `home_screen.dart:858`, `content_type_screen.dart:247` |
| `serviceVideography` | `$newHome/videography.png` | `home_screen.dart:859`, `content_type_screen.dart:238` |
| `serviceEditing` | `$newHome/editing.png` | `home_screen.dart:860`, `content_type_screen.dart:265` |
| `serviceLivestream` | `$newHome/livestream.png` | `home_screen.dart:861`, `content_type_screen.dart:274` |
| `serviceStudio` | `$newHome/studio.png` | `home_screen.dart:862`, `content_type_screen.dart:256` |
| `selectAll` | `$newHome/select_all.png` | `content_type_screen.dart:230` |
| `rebookShoots` | `$newHome/rebook_your_shoots.webp` | `home_screen.dart:1920` |
| `yourBookings` | `$newHome/your_bookings.png` | `home_screen.dart:2706` |
| `chevronRight` | `$svgProfile/chevron_right.svg` | `profile_screen.dart:396`, `home_screen.dart:844,1463` |
| `profileFavourites` | `$svgProfile/favourites.svg` | `profile_screen.dart:242` |
| `profileBookingHistory` | `$svgProfile/booking_history.svg` | `profile_screen.dart:248` |
| `profileTerms` | `$svgProfile/terms_conditions.svg` | `profile_screen.dart:285` |
| `profilePrivacy` | `$svgProfile/privacy_policy.svg` | `profile_screen.dart:297` |
| `profilePreferences` | `$svgProfile/app_preferences.svg` | `profile_screen.dart:339` |
| `profileLogout` | `$svgProfile/logout.svg` | `profile_screen.dart:345` |
| `profileEdit` | `$svgProfile/edit.svg` | `edit_profile_screen.dart:508` |
| `onboarding1` | `$onboarding/onboarding_1.webp` | `onboarding_screen.dart:29` |
| `onboarding2` | `$onboarding/onboarding_2.webp` | `onboarding_screen.dart:23` |
| `splash1`–`splash6` | `$splash/splash_1.png` ... | `splash_screen.dart:25-30` |

### Files with hardcoded paths (must replace with AppAssets)

| # | File | Hardcoded Count |
|---|------|-----------------|
| 1 | `lib/app/router.dart` | 8 |
| 2 | `lib/features/home/presentation/screens/home_screen.dart` | 25+ |
| 3 | `lib/features/booking/presentation/screens/crew_selection_screen.dart` | 15+ |
| 4 | `lib/features/booking/presentation/screens/shoot_date_time_screen.dart` | 14+ |
| 5 | `lib/features/booking/presentation/screens/shoot_review_screen.dart` | 12 |
| 6 | `lib/features/shoot/presentation/screens/cancel_shoot_screen.dart` | 12 |
| 7 | `lib/features/shoot/presentation/screens/manage_shoot_screen.dart` | 10 |
| 8 | `lib/features/auth/presentation/screens/sign_up_screen.dart` | 10 |
| 9 | `lib/features/shoot/presentation/screens/shoot_edit_review_screen.dart` | 8 |
| 10 | `lib/features/booking/presentation/screens/content_type_screen.dart` | 7 |
| 11 | `lib/features/shoot/presentation/screens/my_shoots_screen.dart` | 7 |
| 12 | `lib/features/profile/presentation/screens/profile_screen.dart` | 7 |
| 13 | `lib/features/auth/presentation/screens/reset_password_screen.dart` | 5 |
| 14 | `lib/features/auth/presentation/screens/login_screen.dart` | 4 |
| 15 | `lib/features/home/presentation/screens/recommended_creative_detail_screen.dart` | 4 |
| 16 | `lib/features/booking/presentation/screens/payment_method_screen.dart` | 3 |
| 17 | `lib/features/auth/presentation/screens/forgot_password_screen.dart` | 2 |
| 18 | `lib/features/auth/presentation/screens/forgot_password_otp_screen.dart` | 2 |
| 19 | `lib/features/booking/presentation/screens/shoot_type_screen.dart` | 2 |
| 20 | `lib/features/onboarding/presentation/screens/onboarding_screen.dart` | 2 |
| 21 | `lib/features/splash/presentation/screens/splash_screen.dart` | 6 |
| 22 | `lib/features/booking/presentation/screens/payment_success_screen.dart` | 1 |
| 23 | `lib/features/shoot/presentation/screens/shoot_summary_screen.dart` | 1 |
| 24 | `lib/features/profile/presentation/screens/edit_profile_screen.dart` | 1 |
| 25 | `lib/shared/widgets/loading.dart` | 1 |

---

## Dead References (remove from code)

| # | File | Line | Path | Issue |
|---|------|------|------|-------|
| 1 | `home_screen.dart` | 2079 | `assets/new_home/e5843d2072dc20c350afa27e2260f0c1bb588db3.png` | File does not exist on disk |
| 2 | `home_screen.dart` | 2089 | `assets/new_home/e5843d2072dc20c350afa27e2260f0c1bb588db3.png` | File does not exist on disk |
| 3 | `assets.dart` | 27 | `assets/Icons/app_icon.png` | File does not exist in Icons folder |
| 4 | `crew_selection_screen.dart` | 1146 | `assets/svg/Icon_.svg` | Commented-out code referencing asset |
| 5 | `crew_selection_screen.dart` | 1236 | `assets/svg/video6.svg` | Commented-out code, file does not exist |
| 6 | `crew_selection_screen.dart` | 1271 | `assets/svg/Photo6.SVG` | Commented-out code referencing asset |

## Unused Asset Files (no code references found)

These files exist on disk but have zero references in Dart code. Verify visually before deleting.

| # | File Path | Recommendation |
|---|-----------|----------------|
| 1 | `assets/Icons/Share 2.png` | Likely unused — delete |
| 2 | `assets/Icons/inactive_book_shoot.png` | Likely unused — delete |
| 3 | `assets/Icons/inactive_booking.png` | Likely unused — delete |
| 4 | `assets/svg/my_profile/Help & Support.svg` | Likely unused — delete |
| 5 | `assets/svg/my_profile/Notifications Settings.svg` | Likely unused — delete |
| 6 | `assets/svg/my_profile/Payment methods.svg` | Likely unused — delete |
| 7 | `assets/new_home/Image_fx (5) 1.png` | Likely unused — delete |
| 8 | `assets/new_home/photo_new.png` | Likely unused — delete |
| 9 | `assets/images/home2.png` | Likely unused — delete |
| 10 | `assets/images/man2.png` | Likely unused — delete |
| 11 | `assets/images/chooese_your_role2.png` | Likely unused — delete |
| 12 | `assets/images/Group 2087328887.png` | Likely unused — delete |

## Missing References Found During Review

These were NOT in the original plan. Must be added to Phase 10 centralization.

| # | File | Line | Hardcoded Path | Status |
|---|------|------|----------------|--------|
| 1 | `home_screen.dart` | 121-131 | `assets/images/Alec+H.png` ... `Nathan+Grant.png` (9 creative photos) | referenced in 2 lists (~18 refs total) |
| 2 | `home_screen.dart` | 548 | `assets/images/mappp.png` | map background image |
| 3 | `shoot_date_time_screen.dart` | 2312 | `assets/images/star.png` | star rating icon |
| 4 | `profile_screen.dart` | 45 | `assets/images/profile.png` | profile placeholder |
| 5 | `edit_profile_screen.dart` | 217 | `assets/images/profile.png` | profile placeholder |
| 6 | `crew_size_matching_screen.dart` | 198 | `assets/svg/Group_2087329363.svg` | info icon |

---

## Risk Assessment

### Severity Levels

| Level | Meaning | Impact |
|-------|---------|--------|
| CRITICAL | App crashes or screen won't render | User sees error/blank screen |
| HIGH | Wrong image shown or image missing | UI broken, user confusion |
| MEDIUM | Build warning or analyze issue | No user impact, dev friction |
| LOW | Cosmetic or code quality | No functional impact |

### Risk Matrix

| # | Risk | Severity | Likelihood | Screens Affected | Mitigation |
|---|------|----------|------------|------------------|------------|
| R1 | **File renamed but path NOT updated in code** — asset not found at runtime, Flutter shows error widget (broken image icon or red error box) | CRITICAL | HIGH | All 25 screens with hardcoded paths | Each phase: rename file → update ALL code refs → compile → verify. Never rename without updating refs in same commit |
| R2 | **Folder renamed but `pubspec.yaml` not updated** — Flutter can't locate entire folder of assets, ALL images in that folder break | CRITICAL | MEDIUM | Every screen using that folder | Update `pubspec.yaml` in same commit as folder rename. Run `flutter pub get` immediately after |
| R3 | **Case-sensitivity mismatch** — macOS filesystem is case-insensitive by default, `icons/` and `Icons/` resolve to same folder. But Linux CI/Android build treats them as different | CRITICAL | MEDIUM | CI/CD, Android builds | Use `git mv` (2-step for case-only: `git mv Icons temp && git mv temp icons`). Verify on CI after merge |
| R4 | **`pubspec.yaml` indentation wrong** — YAML is indent-sensitive, broken indentation = assets not bundled | CRITICAL | LOW | All assets | Use exact 4-space indent. Run `flutter pub get` to validate |
| R5 | **Missed hardcoded path** — a file has inline `"assets/..."` string we didn't find in grep | HIGH | MEDIUM | Unknown screens | After all renames: `grep -r "assets/" lib/` to find any remaining hardcoded paths. Also search in comments |
| R6 | **Trailing space in filename** — `Include_Edited_Deliverable .svg` has trailing space. Renaming might silently fail on some OS | HIGH | LOW | `shoot_review_screen.dart` | Verify file actually exists after rename with `ls -la`. Test this rename first |
| R7 | **Special chars in current filenames** — `zoom+.svg`, `zoom-.svg`, `Cornelius+M. (1).png` may need shell escaping in `git mv` | MEDIUM | MEDIUM | Affected files | Use quotes around paths: `git mv "assets/svg/zoom+.svg" "assets/svg/zoom_in.svg"` |
| R8 | **Bottom nav breaks** — 8 SVGs power the tab bar. Wrong path = all 4 tabs show broken icons, app looks completely broken | CRITICAL | MEDIUM | `router.dart` — entire app navigation | Test this rename group FIRST. Verify all 4 tabs render after change |
| R9 | **Auth screens break** — `auth_background.png` (was `Rectangle_574057023.png`) used across 5 auth screens. Miss one = broken login/signup | HIGH | LOW | 5 auth screens | Single `AppAssets.authBackground` constant → update once, all 5 screens fixed |
| R10 | **Dead reference causes runtime error** — `e5843d...png` doesn't exist. If code path is reached, Image.asset throws | HIGH | Already broken | `home_screen.dart:2079,2089` | Fix this BEFORE renaming anything — it's already a bug |
| R11 | **`app_icon.png` missing** — `AppAssets.appIcon` points to non-existent file. If used at runtime, crash | HIGH | Already broken | Wherever `AppAssets.appIcon` is used | Either add the file or remove the constant |

### High-Risk Screens (most hardcoded paths = most breakage potential)

| # | Screen | Hardcoded Count | Risk Notes |
|---|--------|-----------------|------------|
| 1 | `home_screen.dart` | 25+ | Highest risk. Hero cards, service icons, studios, top words, creative photos. Most user-visible screen |
| 2 | `crew_selection_screen.dart` | 15+ | Hearts, badges, placeholders, filter. Complex screen with conditional images |
| 3 | `shoot_date_time_screen.dart` | 14+ | Clock icon used 9 times. Miss one = time picker broken |
| 4 | `shoot_review_screen.dart` | 12 | Booking review — user sees before paying |
| 5 | `cancel_shoot_screen.dart` | 12 | Cancel flow — critical UX path |

---

## Rollback Plan

### Pre-Execution Safety

```bash
# 1. Create safety branch BEFORE starting
git checkout -b asset-cleanup-backup
git checkout improvments-phase1

# 2. Create a tagged snapshot
git tag pre-asset-cleanup

# 3. Verify clean state
git status  # must show no uncommitted changes
flutter analyze  # must pass (or note existing warnings)
flutter run --flavor dev -t lib/main_dev.dart  # app must run correctly
```

### Commit Strategy (Atomic Commits per Phase)

Each phase gets its own commit. This allows surgical rollback of any single phase.

```
Commit 1: refactor(assets): rename folders to lowercase_snake_case
Commit 2: refactor(assets): rename svg files to lowercase_snake_case
Commit 3: refactor(assets): rename svg/profile files to lowercase_snake_case
Commit 4: refactor(assets): rename svg/bottom_nav files to lowercase_snake_case
Commit 5: refactor(assets): rename icon files to lowercase_snake_case
Commit 6: refactor(assets): rename image files to lowercase_snake_case
Commit 7: refactor(assets): rename home folder files to lowercase_snake_case
Commit 8: refactor(assets): rename splash files to lowercase_snake_case
Commit 9: refactor(assets): rename onboarding files to lowercase_snake_case
Commit 10: refactor(assets): add missing AppAssets constants
Commit 11: refactor(assets): centralize hardcoded paths to AppAssets
Commit 12: fix(assets): remove dead references and unused files
```

### Verification Checklist (Run After EACH Commit)

```bash
# Must pass — if any fails, DO NOT proceed to next phase
flutter pub get                                          # assets registered
flutter analyze                                          # no broken imports
flutter run --flavor dev -t lib/main_dev.dart            # app launches

# Manual screen checks after each commit:
# [ ] Splash screen — images load
# [ ] Onboarding — images load
# [ ] Login screen — background image + eye icons
# [ ] Sign up — background + location pin + eye icons
# [ ] Home screen — hero cards, service icons, studios, top words, creative photos
# [ ] Bottom nav — all 4 tab icons (active + inactive states)
# [ ] Book a Shoot — content type icons
# [ ] Crew selection — hearts, filter, badges, placeholders
# [ ] Date/time — clock icons, calendar icons, checkmark
# [ ] Review — all info row icons + feature icons
# [ ] Profile — all menu icons + chevron
# [ ] My Shoots — placeholder images, no-data state
```

### Rollback Procedures

#### Rollback Entire Change
```bash
# Undo everything, go back to pre-cleanup state
git reset --hard pre-asset-cleanup
flutter pub get
```

#### Rollback Single Phase
```bash
# Find the commit to undo
git log --oneline -15

# Revert specific commit (creates inverse commit)
git revert <commit-hash> --no-edit
flutter pub get
flutter analyze
```

#### Rollback When Mid-Phase (Uncommitted)
```bash
# Discard all uncommitted changes
git checkout -- .
flutter pub get
```

#### Emergency Fix (Single Broken Image)
```bash
# If only one image is broken after merge, fastest fix:
# 1. Find what file it was renamed FROM (check git log)
git log --diff-filter=R --summary | grep <broken_filename>

# 2. Either fix the code reference or revert the file rename
git checkout pre-asset-cleanup -- "assets/path/to/original_file.png"
```

### Post-Completion Validation

```bash
# Full grep — NO hardcoded asset paths should remain (except in assets.dart)
grep -rn "\"assets/" lib/ --include="*.dart" | grep -v "assets.dart"
# Expected output: empty (zero results)

# Verify all declared assets exist on disk
flutter pub get  # will warn about missing assets

# Run full analysis
flutter analyze

# Run tests
flutter test
```

---


---

## Phase 11: Scripted Execution & Automation ✅ [COMPLETED]

To avoid human error from manually executing ~75 `git mv` commands and ~135 manual code string replacements, this cleanup will be executed via an automated bash script. 

A script `scripts/asset_cleanup.sh` should be created to:
1. Create necessary directories (`assets/mock_data/...`, `assets/home/`, etc.)
2. Execute `git mv` operations programmatically.
3. Use `sed` or Dart scripts to replace the hardcoded strings in Dart files.

---

## Prevent Future Messes: Git Pre-Commit Hook ✅ [COMPLETED]

To ensure future assets uploaded by developers strictly adhere to the `lowercase_snake_case` rule, we will add a pre-commit hook.

Save this script to `.git/hooks/pre-commit` and make it executable (`chmod +x .git/hooks/pre-commit`):

```bash
#!/bin/bash
# Pre-commit hook to enforce lowercase_snake_case for asset files

ASSET_DIR="assets/"
FAILED=0

# Get a list of staged files in the assets directory
STAGED_FILES=$(git diff --cached --name-only --diff-filter=A | grep "^$ASSET_DIR")

for FILE in $STAGED_FILES; do
  BASENAME=$(basename "$FILE")
  # Regex allows lowercase letters, numbers, underscores, and lowercase extensions
  if [[ ! "$BASENAME" =~ ^[a-z0-9_]+\.[a-z0-9]+$ ]]; then
    echo "ERROR: Invalid asset filename: $FILE"
    echo "Files in assets/ must be lowercase_snake_case with no spaces or special characters."
    FAILED=1
  fi
done

if [ $FAILED -ne 0 ]; then
  echo "Commit rejected due to invalid asset filenames."
  exit 1
fi
exit 0
```

## Execution Order (Updated)

- [x] 1. **Pre-flight** — Create backup branch + tag, verify app runs
- [x] 2. **Fix existing bugs first** — Dead references (R10, R11)
- [x] 3. **Execution Script** — Run `bash scripts/asset_cleanup.sh` to automatically rename folders/files and update references.
- [x] 4. **Update `pubspec.yaml`** — Immediately after folder renames
- [x] 5. **Verify Script Output** — Ensure paths in `lib/app/assets.dart` and the 25+ affected files were successfully updated.
- [x] 6. **Remove dead references + unused files** — Clean up remaining artifacts manually if needed.
- [x] 7. **Install Pre-Commit Hook** — Run `chmod +x .git/hooks/pre-commit` to prevent future bad names.
- [x] 8. **Final grep sweep** — Confirm zero remaining hardcoded paths
- [x] 9. **Full verification** — `flutter analyze` + manual screen walkthrough

## Stats

| Metric | Count |
|--------|-------|
| Folders to rename | 7 |
| Files to rename | ~75 |
| New AppAssets constants to add | ~45 |
| Hardcoded paths to centralize | ~135+ |
| Dart files needing updates | 27 screens + assets.dart + pubspec.yaml |
| Dead references to remove | 6 |
| Unused files to delete | 12 |
| Atomic commits | 12 |
| Screens requiring manual verification | 12+ |