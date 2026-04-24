class ApiEndpoints {

  static const String login = "auth/login";
  static const String singup = "auth/register";
  static const String forgotpassword = "auth/forgot-password-check";
  static const String forgotpassword_verify_otp = "auth/forgot-password-verify-otp";
  static const String reset_password = "auth/reset-password";
  static const String reset_otp = "auth/resend-otp";

// home screen
  static const String home_data = "home/home-data";
  static const String booking_data = "bookings/start-options";
  static const String chnage_location = "auth/profile";


  //Select Date & Time Slots

  static const String booking_select = "bookings";

  static const String booking_specialties = "bookings/specialties";

  //Stripe
  static const String booking_creatives = "creatives";

  static const String payment = "payment";

  static const String payment_setup = "payment/setup-intent";
  static const String payment_attach = "stripe/confirm";
  static const String payment_sheet = "paymentsheet";

  // static const String payment_now = "payment";
  ///------------------My profile-----------------------\\\
  static const String my_profile_photo = "auth/profile-photo ";
  static const String my_profile = "auth/profile";

  ///------------------favourites-----------------------\\\
  static const String my_favourites = "auth/my-favourites";
  static const String addfavourites = "creatives/favourites";

  ///------------------Bookings History------------------\\\
  static const String my_bookings = "auth/bookings/history";


//---------------------------- delete --------------------------
  static const String user_delete_account = "auth/user/delete-account/request";
  static const String user_delete = "auth/user/delete-account/confirm";


////------------------ My Shoot ----------------------\\\\

  static const String creatives_myshoots = "creatives/my-shoots";



////------------------ New booking flow  ----------------------\\\\

  static const String booking_shoot_types = "bookings/shoot-types/";

  static const String booking = "bookings";
  static const String creatives = "creatives";


//---------------------------- Creative --------------------------
  static const String register_step1 = "auth/register-crew-step1";
  static const String register_roles = "auth/crew-roles";
  static const String register_Skill = "auth/skills";
  static const String register_equipment = "auth/equipment-autocomplete";
  static const String register_step2 = "auth/register-crew-step2";
  static const String register_step3 = "auth/register-crew-step3";

}
