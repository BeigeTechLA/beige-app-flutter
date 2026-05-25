// All event names: lowercase_snake_case, max 40 chars
class AnalyticsEvents {
  // Auth
  static const String login            = 'login';
  static const String signUp           = 'sign_up';
  static const String logout           = 'logout';
  static const String forgotPassword   = 'forgot_password';
  static const String passwordReset    = 'password_reset';

  // Booking Flow Step Numbers:
  // Step 1: Content Type Selection (booking_started + booking_step_content_type)
  // Step 2: Shoot Type Selection (booking_step_shoot_type)
  // Step 3: Date & Time Selection (booking_step_date_time)
  // Step 4: Shoot Details / Location (booking_step_details)
  // Step 5: Crew Size Recommendation (booking_step_crew_size)
  // Step 6: Crew Selection (booking_step_crew)
  // Step 7: Review & Confirm (booking_step_review)
  // Step 8: Payment Initiated (payment_initiated)
  // Step 9: Purchase Complete (purchase + payment_success + booking_completed)

  // Booking flow
  static const String bookingStarted       = 'booking_started';
  static const String bookingStepContent   = 'booking_step_content_type';
  static const String bookingStepShootType = 'booking_step_shoot_type';
  static const String bookingStepDateTime  = 'booking_step_date_time';
  static const String bookingStepDetails   = 'booking_step_details';
  static const String bookingStepCrewSize  = 'booking_step_crew_size';
  static const String bookingStepCrew      = 'booking_step_crew';
  static const String bookingStepReview    = 'booking_step_review';
  static const String bookingCompleted     = 'booking_completed';
  static const String bookingCancelled     = 'booking_cancelled';
  static const String bookingAbandoned     = 'booking_abandoned';

  // Payment
  static const String paymentInitiated = 'payment_initiated';
  static const String paymentSuccess   = 'payment_success';
  static const String paymentFailed    = 'payment_failed';
  static const String purchase         = 'purchase';

  // Profile
  static const String profileViewed    = 'profile_viewed';
  static const String profileUpdated   = 'profile_updated';
  static const String creativeViewed   = 'creative_viewed';
  static const String favouriteAdded   = 'favourite_added';
  static const String favouriteRemoved = 'favourite_removed';

  // Account
  static const String accountDeleted   = 'account_deleted';
}
