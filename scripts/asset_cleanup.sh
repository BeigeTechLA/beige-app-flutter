#!/bin/bash

# Create necessary directories
mkdir -p assets/mock_data/creatives
mkdir -p assets/mock_data/studios
mkdir -p assets/mock_data/top_words
mkdir -p scripts

echo "Starting folder renames..."
# Folder Renames (Case-sensitive safe)
[ -d "assets/Icons" ] && { git mv assets/Icons assets/icons_temp; git mv assets/icons_temp assets/icons; }
[ -d "assets/Splash" ] && { git mv assets/Splash assets/splash_temp; git mv assets/splash_temp assets/splash; }
[ -d "assets/Onboding" ] && { git mv assets/Onboding assets/onboarding_temp; git mv assets/onboarding_temp assets/onboarding; }
[ -d "assets/new_home/Topwrods" ] && { git mv assets/new_home/Topwrods/* assets/mock_data/top_words/; rm -rf assets/new_home/Topwrods; }
[ -d "assets/new_home" ] && { git mv assets/new_home assets/home_temp; git mv assets/home_temp assets/home; }
[ -d "assets/svg/my_profile" ] && { git mv assets/svg/my_profile assets/svg/profile_temp; git mv assets/svg/profile_temp assets/svg/profile; }
[ -d "assets/svg/new_bottom_image" ] && { git mv assets/svg/new_bottom_image assets/svg/bottom_nav_temp; git mv assets/svg/bottom_nav_temp assets/svg/bottom_nav; }

echo "Starting file renames..."
# Helper function to safely rename files
rename_file() {
  if [ -f "$1" ]; then
    git mv "$1" "$2"
  fi
}

# Phase 2
rename_file "assets/svg/AI Matchmaking-1.svg" "assets/svg/ai_matchmaking_alt.svg"
rename_file "assets/svg/AI-Powered Post-Production.svg" "assets/svg/ai_post_production.svg"
rename_file "assets/svg/AI_Matchmaking.svg" "assets/svg/ai_matchmaking.svg"
rename_file "assets/svg/All_Raw_Content.svg" "assets/svg/all_raw_content.svg"
rename_file "assets/svg/CameraMinimalistic.svg" "assets/svg/camera_minimalistic.svg"
rename_file "assets/svg/Filter.svg" "assets/svg/filter.svg"
rename_file "assets/svg/Frame.svg" "assets/svg/calendar_date.svg"
rename_file "assets/svg/Group 2087328870.svg" "assets/svg/clock.svg"
rename_file "assets/svg/Group_2087329363.svg" "assets/svg/info.svg"
rename_file "assets/svg/Heart.svg" "assets/svg/heart.svg"
rename_file "assets/svg/Heart_COLOR.svg" "assets/svg/heart_filled.svg"
rename_file "assets/svg/Icon_.svg" "assets/svg/video_camera.svg"
rename_file "assets/svg/Include_Edited_Deliverable .svg" "assets/svg/include_edited_deliverable.svg"
rename_file "assets/svg/Instagram.svg" "assets/svg/instagram.svg"
rename_file "assets/svg/LocationPin.svg" "assets/svg/location_pin.svg"
rename_file "assets/svg/Photo.svg" "assets/svg/photo.svg"
rename_file "assets/svg/Photo6.SVG" "assets/svg/photo_alt.svg"
rename_file "assets/svg/Production.svg" "assets/svg/production.svg"
rename_file "assets/svg/Tiktok.svg" "assets/svg/tiktok.svg"
rename_file "assets/svg/Unlimited_Usage_Rights.svg" "assets/svg/unlimited_usage_rights.svg"
rename_file "assets/svg/Up_to _Sets _Revisions.svg" "assets/svg/up_to_sets_revisions.svg"
rename_file "assets/svg/Youtube.svg" "assets/svg/youtube.svg"
rename_file "assets/svg/calendar-03.svg" "assets/svg/calendar.svg"
rename_file "assets/svg/notification.1.svg" "assets/svg/notification.svg"
rename_file "assets/svg/persone.svg" "assets/svg/person.svg"
rename_file "assets/svg/serch.svg" "assets/svg/search.svg"
rename_file "assets/svg/imag_placeholder.svg" "assets/svg/image_placeholder.svg"
rename_file "assets/svg/zoom+.svg" "assets/svg/zoom_in.svg"
rename_file "assets/svg/zoom-.svg" "assets/svg/zoom_out.svg"
rename_file "assets/svg/chando.svg" "assets/svg/change_password.svg"
rename_file "assets/svg/chando1.svg" "assets/svg/change_password_alt.svg"
rename_file "assets/svg/true.svg" "assets/svg/checkmark.svg"

# Phase 3
rename_file "assets/svg/profile/App_Preferences.svg" "assets/svg/profile/app_preferences.svg"
rename_file "assets/svg/profile/BookingHistory.svg" "assets/svg/profile/booking_history.svg"
rename_file "assets/svg/profile/Favourites.svg" "assets/svg/profile/favourites.svg"
rename_file "assets/svg/profile/Help & Support.svg" "assets/svg/profile/help_support.svg"
rename_file "assets/svg/profile/Logout.svg" "assets/svg/profile/logout.svg"
rename_file "assets/svg/profile/Notifications Settings.svg" "assets/svg/profile/notification_settings.svg"
rename_file "assets/svg/profile/Payment methods.svg" "assets/svg/profile/payment_methods.svg"
rename_file "assets/svg/profile/Privacy Policy.svg" "assets/svg/profile/privacy_policy.svg"
rename_file "assets/svg/profile/Terms & Condition.svg" "assets/svg/profile/terms_conditions.svg"
rename_file "assets/svg/profile/layer1.svg" "assets/svg/profile/chevron_right.svg"

# Phase 4
rename_file "assets/svg/bottom_nav/active_Book a Shoot.svg" "assets/svg/bottom_nav/active_book_shoot.svg"
rename_file "assets/svg/bottom_nav/active_Home.svg" "assets/svg/bottom_nav/active_home.svg"
rename_file "assets/svg/bottom_nav/active_Messages.svg" "assets/svg/bottom_nav/active_messages.svg"
rename_file "assets/svg/bottom_nav/active_My Shoots.svg" "assets/svg/bottom_nav/active_my_shoots.svg"
rename_file "assets/svg/bottom_nav/in_active_Book_Shoot.svg" "assets/svg/bottom_nav/inactive_book_shoot.svg"
rename_file "assets/svg/bottom_nav/in_active_Home.svg" "assets/svg/bottom_nav/inactive_home.svg"
rename_file "assets/svg/bottom_nav/in_active_Messages.svg" "assets/svg/bottom_nav/inactive_messages.svg"
rename_file "assets/svg/bottom_nav/in_active_My Shoots.svg" "assets/svg/bottom_nav/inactive_my_shoots.svg"

# Phase 5
rename_file "assets/icons/Share 2.png" "assets/icons/share.png"
rename_file "assets/icons/Heart_Angl_COLOR.png" "assets/icons/heart_angle_filled.png"
rename_file "assets/icons/user_chec_time_linek.png" "assets/icons/user_check_timeline.png"

# Phase 6
rename_file "assets/images/Alec+H.png" "assets/mock_data/creatives/alec_h.png"
rename_file "assets/images/Christopher+R.png" "assets/mock_data/creatives/christopher_r.png"
rename_file "assets/images/Corey+B.png" "assets/mock_data/creatives/corey_b.png"
rename_file "assets/images/Cornelius+M. (1).png" "assets/mock_data/creatives/cornelius_m.png"
rename_file "assets/images/Daniel+A.png" "assets/mock_data/creatives/daniel_a.png"
rename_file "assets/images/Daniel+C.png" "assets/mock_data/creatives/daniel_c.png"
rename_file "assets/images/Gary+Ahmed.png" "assets/mock_data/creatives/gary_ahmed.png"
rename_file "assets/images/Mikey+D (1).jpg" "assets/mock_data/creatives/mikey_d.jpg"
rename_file "assets/images/Nathan+Grant.png" "assets/mock_data/creatives/nathan_grant.png"

rename_file "assets/images/Group 1171276698 (1).png" "assets/images/booking_confirmed.png"
rename_file "assets/images/Group 2087328887.png" "assets/images/equipment_icon.png"
rename_file "assets/images/Group 2087328980.png" "assets/images/navigate_arrow.png"
rename_file "assets/images/Image.png" "assets/images/role_selection.png"
rename_file "assets/images/Rectangle_574057023.png" "assets/images/auth_background.png"
rename_file "assets/images/Rectangle 34661070.png" "assets/images/creative_card_bg.png"
rename_file "assets/images/Heart Angle.png" "assets/images/heart_angle.png"
rename_file "assets/images/mappp.png" "assets/images/map.png"
rename_file "assets/images/chooese_your_role2.png" "assets/images/choose_your_role.png"

# Phase 7
rename_file "assets/home/4ce6dbc682ece7bfa93433aeb6d222629b357f13.png" "assets/mock_data/studios/beige_media.png"
rename_file "assets/home/77443dc57b82c6b4cf617e452a831e5055018dff.png" "assets/mock_data/studios/creative_zone.png"
rename_file "assets/home/baab5672af97faec6fb4cf661917f300c14b2353.png" "assets/mock_data/studios/beige_media_alt.png"

rename_file "assets/home/Group 2087329746.png" "assets/home/home_card_bg.png"
rename_file "assets/home/Image_fx (5) 1.png" "assets/home/home_fx_image.png"
rename_file "assets/home/Livestream_new.png" "assets/home/livestream.png"
rename_file "assets/home/Videography.png" "assets/home/videography.png"
rename_file "assets/home/Your-Bookings.png" "assets/home/your_bookings.png"
rename_file "assets/home/RebookYourShoots_img.webp" "assets/home/rebook_your_shoots.webp"
rename_file "assets/home/stuido_new.png" "assets/home/studio.png"
rename_file "assets/home/upcoming_nodata_imge.png" "assets/home/upcoming_no_data.png"
rename_file "assets/home/homebackground_new.png" "assets/home/home_background.png"
rename_file "assets/home/home_book1.png" "assets/home/home_book_1.png"
rename_file "assets/home/home_book3.png" "assets/home/home_book_3.png"
rename_file "assets/home/selectall.png" "assets/home/select_all.png"
rename_file "assets/home/edit_new.png" "assets/home/editing.png"
rename_file "assets/home/photo_new.png" "assets/home/photo.png"

# Top Words
rename_file "assets/mock_data/top_words/Justin Beiber.webp" "assets/mock_data/top_words/justin_bieber.webp"
rename_file "assets/mock_data/top_words/Cedric The Entertainer.webp" "assets/mock_data/top_words/cedric_the_entertainer.webp"
rename_file "assets/mock_data/top_words/Wiz Khalifa.webp" "assets/mock_data/top_words/wiz_khalifa.webp"
rename_file "assets/mock_data/top_words/Pressa.webp" "assets/mock_data/top_words/pressa.webp"
rename_file "assets/mock_data/top_words/Tyga.webp" "assets/mock_data/top_words/tyga.webp"
rename_file "assets/mock_data/top_words/CentralCee.webp" "assets/mock_data/top_words/central_cee.webp"
rename_file "assets/mock_data/top_words/Chief Keef.webp" "assets/mock_data/top_words/chief_keef.webp"
rename_file "assets/mock_data/top_words/Swae Lee.webp" "assets/mock_data/top_words/swae_lee.webp"
rename_file "assets/mock_data/top_words/Natasha Graziano.jpg" "assets/mock_data/top_words/natasha_graziano.jpg"

# Phase 8
rename_file "assets/splash/Property_1.png" "assets/splash/splash_1.png"
rename_file "assets/splash/Property_2.png" "assets/splash/splash_2.png"
rename_file "assets/splash/Property_3.png" "assets/splash/splash_3.png"
rename_file "assets/splash/Property_4.png" "assets/splash/splash_4.png"
rename_file "assets/splash/Propety_5.png" "assets/splash/splash_5.png"
rename_file "assets/splash/Property_6.png" "assets/splash/splash_6.png"

# Phase 9
rename_file "assets/onboarding/img.webp" "assets/onboarding/onboarding_1.webp"
rename_file "assets/onboarding/img_1.webp" "assets/onboarding/onboarding_2.webp"

echo "Creating python code replacement script..."
cat << 'EOF' > scripts/replace_strings.py
import os

REPLACEMENTS = {
    # Replace folder paths in pubspec (note: using exact strings to avoid replacing unrelated things)
    "assets/Icons/": "assets/icons/",
    "assets/Splash/": "assets/splash/",
    "assets/Onboding/": "assets/onboarding/",
    "assets/new_home/": "assets/home/",
    "assets/svg/my_profile/": "assets/svg/profile/",
    "assets/svg/new_bottom_image/": "assets/svg/bottom_nav/",
    "assets/new_home/Topwrods/": "assets/mock_data/top_words/",

    # Phase 10: Specific AppAssets Replacements
    # Bottom Nav
    "'assets/svg/new_bottom_image/active_Home.svg'": "AppAssets.activeHome",
    "'assets/svg/new_bottom_image/in_active_Home.svg'": "AppAssets.inactiveHome",
    "'assets/svg/new_bottom_image/active_Book a Shoot.svg'": "AppAssets.activeBookShoot",
    "'assets/svg/new_bottom_image/in_active_Book_Shoot.svg'": "AppAssets.inactiveBookShoot",
    "'assets/svg/new_bottom_image/active_My Shoots.svg'": "AppAssets.activeMyShoot",
    "'assets/svg/new_bottom_image/in_active_My Shoots.svg'": "AppAssets.inactiveMyShoot",
    "'assets/svg/new_bottom_image/active_Messages.svg'": "AppAssets.activeMessages",
    "'assets/svg/new_bottom_image/in_active_Messages.svg'": "AppAssets.inactiveMessages",
    
    # Generic SVG Root
    "'assets/svg/Group 2087328870.svg'": "AppAssets.clock",
    "'assets/svg/Frame.svg'": "AppAssets.calendarDate",
    "'assets/svg/true.svg'": "AppAssets.checkmark",
    "'assets/svg/Group_2087329363.svg'": "'assets/svg/info.svg'",

    # Images
    "'assets/images/Rectangle_574057023.png'": "AppAssets.authBackground",
    "'assets/images/Image.png'": "AppAssets.roleSelection",
    "'assets/images/Rectangle 34661070.png'": "AppAssets.creativeCardBg",
    "'assets/images/Heart Angle.png'": "AppAssets.heartAngle",
    "'assets/images/Group 2087328980.png'": "AppAssets.navigateArrow",
    "'assets/images/Group 1171276698 (1).png'": "AppAssets.bookingConfirmed",
    "'assets/images/star.png'": "'assets/images/star.png'", 
    "'assets/images/profile.png'": "'assets/images/profile.png'",
    "'assets/images/mappp.png'": "'assets/images/map.png'",

    # Icons
    "'assets/Icons/Heart_Angl_COLOR.png'": "AppAssets.heartAngleFilled",
    "'assets/Icons/sale.png'": "AppAssets.saleIcon",
    "'assets/Icons/stripe.png'": "AppAssets.stripeIcon",
    "'assets/Icons/user_chec_time_linek.png'": "AppAssets.userCheckTimeline",
    "'assets/Icons/emoji_photo.png'": "AppAssets.emojiPhoto",

    # Home & Content Types
    "'assets/new_home/upcoming_nodata_imge.png'": "AppAssets.upcomingNoData",
    "'assets/new_home/Group 2087329746.png'": "AppAssets.homeCardBg",
    "'assets/new_home/homebackground_new.png'": "AppAssets.homeBackground",
    "'assets/new_home/home_book1.png'": "AppAssets.homeBook1",
    "'assets/new_home/home_book_2.png'": "AppAssets.homeBook2",
    "'assets/new_home/home_book3.png'": "AppAssets.homeBook3",
    "'assets/new_home/photography.png'": "AppAssets.servicePhotography",
    "'assets/new_home/Videography.png'": "AppAssets.serviceVideography",
    "'assets/new_home/edit_new.png'": "AppAssets.serviceEditing",
    "'assets/new_home/Livestream_new.png'": "AppAssets.serviceLivestream",
    "'assets/new_home/stuido_new.png'": "AppAssets.serviceStudio",
    "'assets/new_home/selectall.png'": "AppAssets.selectAll",
    "'assets/new_home/RebookYourShoots_img.webp'": "AppAssets.rebookShoots",
    "'assets/new_home/Your-Bookings.png'": "AppAssets.yourBookings",

    # Profile
    "'assets/svg/my_profile/layer1.svg'": "AppAssets.chevronRight",
    "'assets/svg/my_profile/Favourites.svg'": "AppAssets.profileFavourites",
    "'assets/svg/my_profile/BookingHistory.svg'": "AppAssets.profileBookingHistory",
    "'assets/svg/my_profile/Terms & Condition.svg'": "AppAssets.profileTerms",
    "'assets/svg/my_profile/Privacy Policy.svg'": "AppAssets.profilePrivacy",
    "'assets/svg/my_profile/App_Preferences.svg'": "AppAssets.profilePreferences",
    "'assets/svg/my_profile/Logout.svg'": "AppAssets.profileLogout",
    "'assets/svg/my_profile/edit.svg'": "AppAssets.profileEdit",

    # Onboarding & Splash
    "'assets/Onboding/img.webp'": "AppAssets.onboarding1",
    "'assets/Onboding/img_1.webp'": "AppAssets.onboarding2",
    "'assets/Splash/Property_1.png'": "'assets/splash/splash_1.png'",
    "'assets/Splash/Property_2.png'": "'assets/splash/splash_2.png'",
    "'assets/Splash/Property_3.png'": "'assets/splash/splash_3.png'",
    "'assets/Splash/Property_4.png'": "'assets/splash/splash_4.png'",
    "'assets/Splash/Propety_5.png'": "'assets/splash/splash_5.png'",
    "'assets/Splash/Property_6.png'": "'assets/splash/splash_6.png'",

    # Mock Data Strings (Creatives)
    "'assets/images/Alec+H.png'": "'assets/mock_data/creatives/alec_h.png'",
    "'assets/images/Christopher+R.png'": "'assets/mock_data/creatives/christopher_r.png'",
    "'assets/images/Corey+B.png'": "'assets/mock_data/creatives/corey_b.png'",
    "'assets/images/Cornelius+M. (1).png'": "'assets/mock_data/creatives/cornelius_m.png'",
    "'assets/images/Daniel+A.png'": "'assets/mock_data/creatives/daniel_a.png'",
    "'assets/images/Daniel+C.png'": "'assets/mock_data/creatives/daniel_c.png'",
    "'assets/images/Gary+Ahmed.png'": "'assets/mock_data/creatives/gary_ahmed.png'",
    "'assets/images/Mikey+D (1).jpg'": "'assets/mock_data/creatives/mikey_d.jpg'",
    "'assets/images/Nathan+Grant.png'": "'assets/mock_data/creatives/nathan_grant.png'",
    
    # Mock Data Strings (Studios)
    "'assets/new_home/4ce6dbc682ece7bfa93433aeb6d222629b357f13.png'": "'assets/mock_data/studios/beige_media.png'",
    "'assets/new_home/77443dc57b82c6b4cf617e452a831e5055018dff.png'": "'assets/mock_data/studios/creative_zone.png'",
    "'assets/new_home/baab5672af97faec6fb4cf661917f300c14b2353.png'": "'assets/mock_data/studios/beige_media_alt.png'",

    # Mock Data Strings (Top Words)
    "'assets/new_home/Topwrods/Justin Beiber.webp'": "'assets/mock_data/top_words/justin_bieber.webp'",
    "'assets/new_home/Topwrods/Cedric The Entertainer.webp'": "'assets/mock_data/top_words/cedric_the_entertainer.webp'",
    "'assets/new_home/Topwrods/Wiz Khalifa.webp'": "'assets/mock_data/top_words/wiz_khalifa.webp'",
    "'assets/new_home/Topwrods/Pressa.webp'": "'assets/mock_data/top_words/pressa.webp'",
    "'assets/new_home/Topwrods/Tyga.webp'": "'assets/mock_data/top_words/tyga.webp'",
    "'assets/new_home/Topwrods/CentralCee.webp'": "'assets/mock_data/top_words/central_cee.webp'",
    "'assets/new_home/Topwrods/Chief Keef.webp'": "'assets/mock_data/top_words/chief_keef.webp'",
    "'assets/new_home/Topwrods/Swae Lee.webp'": "'assets/mock_data/top_words/swae_lee.webp'",
    "'assets/new_home/Topwrods/Natasha Graziano.jpg'": "'assets/mock_data/top_words/natasha_graziano.jpg'",
}

# Recursively iterate through lib and replace
def process_file(path):
    try:
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()

        changed = False
        for old, new in REPLACEMENTS.items():
            if old in content:
                content = content.replace(old, new)
                changed = True

        if changed:
            with open(path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Updated {path}")
    except Exception as e:
        print(f"Failed to process {path}: {e}")

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

process_file('pubspec.yaml')

EOF

python3 scripts/replace_strings.py

# Clean up the python script
rm scripts/replace_strings.py

echo "Cleanup automation complete!"
