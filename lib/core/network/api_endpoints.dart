import '../../config/env.dart';

abstract class ApiEndpoints {
  static String get baseUrl => Env.apiUrl;
  static String get imageUrl => Env.imageUrl;

  /// 👤 Authentication
  static const String login = "auth/login";
  static const String signup = "auth/register";
  static const String forgotPassword = "auth/forgot-password-check";
  static const String forgotPasswordVerifyOtp =
      "auth/forgot-password-verify-otp";
  static const String resetPassword = "auth/reset-password";
  static const String resendOtp = "auth/resend-otp";

  /// 👤 Profile & User
  static const String myProfile = "auth/profile";
  static const String myProfilePhoto = "auth/profile-photo";
  static const String changeLocation = "auth/profile";
  static const String deleteAccountRequest = "auth/user/delete-account/request";
  static const String deleteAccountConfirm = "auth/user/delete-account/confirm";
  static const String myFavourites = "auth/my-favourites";
  static const String myBookings = "auth/bookings/history";

  /// 🏠 Home
  static const String homeData = "home/home-data";

  /// 📅 Bookings
  static const String bookings = "bookings";
  static const String bookingStartOptions = "bookings/start-options";
  static const String bookingSpecialties = "bookings/specialties";
  static const String bookingShootTypes = "bookings/shoot-types/";

  /// 🎨 Creatives
  static const String creatives = "creatives";
  static const String addFavourite = "creatives/favourites";
  static const String creativesMyShoots = "creatives/my-shoots";

  /// 💳 Payments (Stripe)
  static const String payment = "payment";
  static const String paymentSetup = "payment/setup-intent";
  static const String paymentAttach = "stripe/confirm";
  static const String paymentSheet = "paymentsheet";

  /// 💬 Chat (external-chat)
  static const String chatRooms = 'external-chat/rooms';
  static const String chatDirectory = 'external-chat/directory';
  static String chatMessages(String roomId) => 'external-chat/messages/$roomId';
  static String chatEditMessage(String messageId) =>
      'external-chat/messages/$messageId/edit';
  static String chatDeleteMessage(String messageId) =>
      'external-chat/messages/$messageId/delete';
  static String chatMessageReaction(String messageId) =>
      'external-chat/messages/$messageId/reaction';
  static String chatMarkRead(String roomId) =>
      'external-chat/room/$roomId/mark-read';
  static String chatRoomDetails(String roomId) =>
      'external-chat/room/$roomId/details';
  static String chatParticipants(String roomId) =>
      'external-chat/participants/$roomId';

  /// Multipart upload endpoint — final path TBD with backend. Reserved name
  /// keeps the call site stable while the endpoint settles.
  static String chatUpload(String roomId) =>
      'external-chat/messages/$roomId/upload';

  /// 📅 Meetings (external-meetings)
  static const String meetings = 'external-meetings';
  static const String externalMeetingsCreateEvent =
      'external-meetings/create-event';

  /// Project summaries for the create-meeting shoot picker. Returns
  /// `{data: {stats, projects: [{project: {stream_project_booking_id, name,
  /// ...}}]}}`.
  static const String adminGetProjects = 'admin/get-projects';
  static String meetingsByUser(String userId) =>
      'external-meetings/user/$userId';
  static String meetingById(String id) => 'external-meetings/$id';
  static String meetingParticipants(String id) =>
      'external-meetings/$id/participants';

  /// POST `{ status: 'accepted' | 'declined' }` — records the signed-in
  /// user's RSVP. Backend route name unconfirmed; swap if backend rejects.
  static String meetingRespond(String id) => 'external-meetings/$id/respond';

  // ───── File Manager (FM7 real endpoints) ────────────────────────────────
  static const String fileManagerRoot = 'file-manager/root';
  static String fileManagerFolder(String id) => 'file-manager/folders/$id';
  static String fileManagerFolderDelete(String id) =>
      'file-manager/folders/$id';
  static String fileManagerFileDelete(String id) => 'file-manager/files/$id';
  static String fileManagerFileDownload(String id) =>
      'file-manager/files/$id/download';
  static const String fileManagerShare = 'file-manager/share';

  static const String fmWorkspaceAccess =
      'external-file-manager/workspace-access';
  static const String fmWorkspaces = 'external-file-manager/workspaces';
  static String fmWorkspace(String extId) =>
      'external-file-manager/workspace/$extId';
  static String fmWorkspaceFiles(String extId) =>
      'external-file-manager/workspace/$extId/files';
  static const String fmFolder = 'external-file-manager/folder';
  static const String fmFolderDownloadUrl =
      'external-file-manager/folder-download-url';
  static const String fmUploadPolicies =
      'external-file-manager/upload-policies/batch';
  static const String fmFilesUploaded =
      'external-file-manager/files-uploaded/batch';
  static const String fmFileViewUrl = 'external-file-manager/file-view-url';
  static const String fmFileDownloadUrl =
      'external-file-manager/file-download-url';
  static const String fmDelete = 'external-file-manager/delete';
  static const String fmCopyFiles = 'external-file-manager/copy-files';
  static const String fmRevisionReview =
      'external-file-manager/revision-file/review';
  static const String fmShare = 'external-file-manager/share';
  static const String fmShareAccessLogs =
      'external-file-manager/share/access-logs';
  static const String fmShareRequestOtp =
      'external-file-manager/share/request-otp';
  static const String fmShareVerifyOtp =
      'external-file-manager/share/verify-otp';
  static String fmShareContent(String token) =>
      'external-file-manager/share/$token/content';
  static String fmShareViewUrl(String token) =>
      'external-file-manager/share/$token/view-url';
  static String fmShareDownloadUrl(String token) =>
      'external-file-manager/share/$token/download-url';
  static const String comments = 'comments';
  static String commentReply(String id) => 'comments/$id/reply';
  static String commentById(String id) => 'comments/$id';
  static String fmCommonEvent(String extId) =>
      'external-file-manager/common-events/$extId';
  static String fmCommonEventCreatorFolder(String extId) =>
      'external-file-manager/common-events/$extId/creator-folder';

  /// 👔 Crew Registration
  static const String registerCrewStep1 = "auth/register-crew-step1";
  static const String registerCrewRoles = "auth/crew-roles";
  static const String registerCrewSkills = "auth/skills";
  static const String registerCrewEquipment = "auth/equipment-autocomplete";
  static const String registerCrewStep2 = "auth/register-crew-step2";
  static const String registerCrewStep3 = "auth/register-crew-step3";

  // ─── Legacy aliases (used by pre-migration code) ───
  // These will be removed as each feature is migrated.

  @Deprecated('Use signup instead')
  static const String singup = signup;

  @Deprecated('Use forgotPassword instead')
  static const String forgotpassword = forgotPassword;

  @Deprecated('Use forgotPasswordVerifyOtp instead')
  static const String forgotpassword_verify_otp = forgotPasswordVerifyOtp;

  @Deprecated('Use resetPassword instead')
  static const String reset_password = resetPassword;

  @Deprecated('Use resendOtp instead')
  static const String reset_otp = resendOtp;

  @Deprecated('Use homeData instead')
  static const String home_data = homeData;

  @Deprecated('Use bookingStartOptions instead')
  static const String booking_data = bookingStartOptions;

  @Deprecated('Use changeLocation instead')
  static const String chnage_location = changeLocation;

  @Deprecated('Use bookings instead')
  static const String booking_select = bookings;

  @Deprecated('Use bookings instead')
  static const String booking = bookings;

  @Deprecated('Use bookingShootTypes instead')
  static const String booking_shoot_types = bookingShootTypes;

  @Deprecated('Use bookingSpecialties instead')
  static const String booking_specialties = bookingSpecialties;

  @Deprecated('Use addFavourite instead')
  static const String addfavourites = addFavourite;

  @Deprecated('Use creativesMyShoots instead')
  static const String creatives_myshoots = creativesMyShoots;

  @Deprecated('Use myProfile instead')
  static const String my_profile = myProfile;

  @Deprecated('Use myProfilePhoto instead')
  static const String my_profile_photo = myProfilePhoto;

  @Deprecated('Use myFavourites instead')
  static const String my_favourites = myFavourites;

  @Deprecated('Use myBookings instead')
  static const String my_bookings = myBookings;

  @Deprecated('Use deleteAccountRequest instead')
  static const String user_delete_account = deleteAccountRequest;

  @Deprecated('Use deleteAccountConfirm instead')
  static const String user_delete = deleteAccountConfirm;

  @Deprecated('Use paymentSetup instead')
  static const String payment_setup = paymentSetup;

  @Deprecated('Use paymentAttach instead')
  static const String payment_attach = paymentAttach;

  @Deprecated('Use paymentSheet instead')
  static const String payment_sheet = paymentSheet;
}
