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
