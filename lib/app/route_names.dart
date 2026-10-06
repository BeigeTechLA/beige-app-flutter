/// Centralized route name constants for GoRouter.
///
/// All route names are lowercase_snake_case per MIGRATION_RULES.md.
/// Every GoRoute must reference a name from this class.
abstract class RouteNames {
  // Auth
  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const login = 'login';
  static const signup = 'signup';
  static const forgotPassword = 'forgot_password';
  static const forgotOtp = 'forgot_otp';
  static const resetPassword = 'reset_password';
  static const passwordSuccess = 'password_success';

  // Main shell tabs
  static const home = 'home';
  static const bookShoot = 'book_shoot';
  static const myShoots = 'my_shoots';
  static const messages = 'messages';
  static const fileManager = 'file_manager';
  static const filesFolder = 'files_folder';
  static const filesSuccess = 'files_success';
  static const meetings = 'meetings';
  static const meetingCreate = 'meeting_create';
  static const meetingEdit = 'meeting_edit';
  static const meetingScheduled = 'meeting_scheduled';
  static const chat = 'chat';
  static const chatDetails = 'chat_details';

  // Home sub-screens
  static const viewProfile = 'view_profile';
  static const recommendedDetails = 'recommended_details';
  static const changeLocation = 'change_location';
  static const findingPerfect = 'finding_perfect';
  static const paymentMethod = 'payment_method';

  // New Booking Flow
  static const contentType = 'content_type';
  static const videoShootType = 'video_shoot_type';
  static const shootDateTime = 'shoot_date_time';
  static const moreDetails = 'more_details';
  static const crewSizeMatching = 'crew_size_matching';
  static const selectDreamTeam = 'select_dream_team';
  static const reviewConfirm = 'review_confirm';
  static const commasCheckout = 'commas_checkout';
  static const paymentFailed = 'payment_failed';
  static const paymentSuccess = 'payment_success';

  // Book-a-Shoot v4 flow (api_flow.pdf). Route names are the stable step keys;
  // screens land across Phases 2-6. When & Where is a sheet inside
  // [bookingSchedule], not its own route.
  static const bookingContent = 'booking_content';
  static const bookingShootType = 'booking_shoot_type';
  static const bookingSchedule = 'booking_schedule';
  static const bookingDetails = 'booking_details';
  static const bookingMatchingChoice = 'booking_matching_choice';
  static const bookingCrewCount = 'booking_crew_count';
  static const bookingEdits = 'booking_edits';
  static const bookingCreatorSelection = 'booking_creator_selection';
  static const bookingAddons = 'booking_addons';
  static const bookingReviewContact = 'booking_review_contact';
  static const bookingConfirmPay = 'booking_confirm_pay';
  static const bookingConfirmation = 'booking_confirmation';

  // Booking Management
  static const bookingEventSummary = 'booking_event_summary';
  static const manageBooking = 'manage_booking';
  static const bookingReviewConfirm = 'booking_review_confirm';
  static const cancelBooking = 'cancel_booking';
  static const selectBookingType = 'select_booking_type';
  static const shootUpdated = 'shoot_updated';

  // Profile & Auth Image Cropping
  static const profile = 'profile';
  static const cropImage = 'crop_image';
  static const cropImageSignup = 'crop_image_signup';
  static const cropImageProfile = 'crop_image_profile';
  static const editProfile = 'edit_profile';
  static const changePassword = 'change_password';
  static const profileOtp = 'profile_otp';
  static const profileNewPassword = 'profile_new_password';
  static const bookingHistory = 'booking_history';
  static const favourites = 'favourites';
  static const appPreferences = 'app_preferences';
  static const deleteAccount = 'delete_account';
  static const deleteAccountOtp = 'delete_account_otp';
}
