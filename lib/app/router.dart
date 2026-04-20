import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../Booking/MY_SelectBookingType.dart';
import '../Booking/Shoot_updated_screen.dart';
import '../Booking/bookin_review_confirm.dart';
import '../Booking/booking_all_screen.dart';
import '../Booking/cancel_booking.dart';
import '../Booking/upcoming_booking_event_summary.dart';
import '../Booking/upcoming_event_summary_managebooking.dart';
import '../Home/HomeSekect/Home_view_profile.dart';
import '../Home/HomeSekect/change_location_screen.dart';
import '../Home/HomeSekect/finding_the_perfect_screen.dart';
import '../Home/HomeSekect/payment_method.dart';
import '../Home/HomeSekect/recommended_detils_screen.dart';
import '../Home/NewBookingFlow/Book_Confirm/PaymentSuccessScreen.dart';
import '../Home/NewBookingFlow/Book_Confirm/review_confirm_screen.dart';
import '../Home/NewBookingFlow/CreateProjectStep1/Content_Type_screen.dart';
import '../Home/NewBookingFlow/CreateProjectStep1/ShootDateTime/Shoot_Date_Time_screen.dart';
import '../Home/NewBookingFlow/CreateProjectStep1/Video_Shoot_Type.dart';
import '../Home/NewBookingFlow/More_Details/crew_size_matching_screen.dart';
import '../Home/NewBookingFlow/More_Details/more_details_screen.dart';
import '../Home/NewBookingFlow/More_Details/select_your_dream_team.dart';
import '../Home/New_Home/new_home_screen.dart';
import '../MyProfile/Booking_History_screen.dart';
import '../MyProfile/Change_Password_screen.dart';
import '../MyProfile/DeleteAccount/delete_account.dart';
import '../MyProfile/DeleteAccount/delete_account_otp_screen.dart';
import '../MyProfile/Favourite_screen.dart';
import '../MyProfile/app_preferences.dart';
import '../MyProfile/edit_profile.dart';
import '../MyProfile/my_profile.dart';
import '../MyProfile/myprofile_enter_otp_screen.dart';
import '../MyProfile/myprofile_new_password_screen.dart';
import '../OnbodingScreen/onboding_screen.dart';
import '../SplashScreen/splash_screen.dart';
import '../auth/Password_successfull.dart';
import '../auth/new_forgot_otp_screen.dart';
import '../auth/new_forgot_passwrod_screen.dart';
import '../auth/new_login_screen.dart';
import '../auth/new_new_passwrod_screen.dart';
import '../auth/new_sing_up_screen.dart';
import 'route_names.dart';

/// Global navigator key — kept temporarily for ScaffoldMessenger compatibility.
/// Will be removed in Batch 14 cleanup.
final rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // ── Auth & Onboarding (outside shell) ──────────────────────────
    GoRoute(
      path: '/splash',
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: RouteNames.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      name: RouteNames.login,
      builder: (context, state) => const NewLoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: RouteNames.signup,
      builder: (context, state) => const NewSingUpScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: RouteNames.forgotPassword,
      builder: (context, state) => const NewForgotPasswrodScreen(),
    ),
    GoRoute(
      path: '/forgot-otp',
      name: RouteNames.forgotOtp,
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return NewForgotOtpScreen(email: email);
      },
    ),
    GoRoute(
      path: '/reset-password',
      name: RouteNames.resetPassword,
      builder: (context, state) {
        final data = state.extra as Map<String, String>? ?? {};
        return NewNewPasswrodScreen(
          email: data['email'] ?? '',
          otp: data['otp'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/password-success',
      name: RouteNames.passwordSuccess,
      builder: (context, state) => const PasswordSuccessfull(),
    ),

    // ── Main Shell (bottom nav with IndexedStack) ──────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: RouteNames.home,
              builder: (context, state) => const NewHomeScreen(),
            ),
          ],
        ),
        // Tab 1: Book Shoot
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/book-shoot',
              name: RouteNames.bookShoot,
              builder: (context, state) => const ContentTypeScreen(fromHome: false),
            ),
          ],
        ),
        // Tab 2: My Shoots
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/my-shoots',
              name: RouteNames.myShoots,
              builder: (context, state) => const BookingAllScreen(),
            ),
          ],
        ),
        // Tab 3: Messages
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/messages',
              name: RouteNames.messages,
              builder: (context, state) => const Center(child: Text('Messages')),
            ),
          ],
        ),
      ],
    ),

    // ── Home Sub-Screens (pushed on top, no bottom nav) ────────────
    GoRoute(
      path: '/view-profile/:id',
      name: RouteNames.viewProfile,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return HomeViewProfile(id: id);
      },
    ),
    GoRoute(
      path: '/recommended/:id',
      name: RouteNames.recommendedDetails,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final bookingId = int.parse(state.uri.queryParameters['bookingId'] ?? '0');
        return RecommendedDetilsScreen(id: id, bookingId: bookingId);
      },
    ),
    GoRoute(
      path: '/change-location',
      name: RouteNames.changeLocation,
      builder: (context, state) => const ChangeLocationScreen(),
    ),
    GoRoute(
      path: '/finding-perfect',
      name: RouteNames.findingPerfect,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return FindingThePerfectScreen(
          bookingId: data['bookingId'] as int? ?? 0,
          specialtyId: data['specialtyId'] as int? ?? 0,
          ShootTypeId: data['ShootTypeId'] as int? ?? 0,
          contentTypeId: data['contentTypeId'] as int? ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/payment-method/:bookingId',
      name: RouteNames.paymentMethod,
      builder: (context, state) {
        final bookingId = int.parse(state.pathParameters['bookingId']!);
        return PaymentMethodScreen(bookingId: bookingId);
      },
    ),

    // ── New Booking Flow ───────────────────────────────────────────
    GoRoute(
      path: '/content-type',
      name: RouteNames.contentType,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return ContentTypeScreen(
          fromHome: true,
          specialtyId: data?['specialtyId'] as int?,
          value: data?['value'] as int?,
        );
      },
    ),
    GoRoute(
      path: '/video-shoot-type',
      name: RouteNames.videoShootType,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return VideoShootType(
          contentTypeId: data['contentTypeId'] as int? ?? 0,
          bookingId: data['bookingId'] as int? ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/shoot-date-time',
      name: RouteNames.shootDateTime,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return ShootDateTimeScreen(
          ShootTypeId: data['ShootTypeId'] as int? ?? 0,
          bookingId: data['bookingId'] as int? ?? 0,
          contentTypeId: data['contentTypeId'] as int? ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/more-details',
      name: RouteNames.moreDetails,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return MoreDetailsScreen(
          contentTypeId: data['contentTypeId'] as int? ?? 0,
          specialtyId: data['specialtyId'] as int? ?? 0,
          ShootTypeId: data['ShootTypeId'] as int? ?? 0,
          bookingId: data['bookingId'] as int? ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/crew-size-matching',
      name: RouteNames.crewSizeMatching,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return CrewSizeMatchingScreen(
          specialtyId: data['specialtyId'] as int? ?? 0,
          ShootTypeId: data['ShootTypeId'] as int? ?? 0,
          bookingId: data['bookingId'] as int? ?? 0,
          contentTypeId: data['contentTypeId'] as int? ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/select-dream-team',
      name: RouteNames.selectDreamTeam,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return SelectYourDreamTeam(
          specialtyId: data['specialtyId'] as int? ?? 0,
          ShootTypeId: data['ShootTypeId'] as int? ?? 0,
          bookingId: data['bookingId'] as int? ?? 0,
          contentTypeId: data['contentTypeId'] as int? ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/review-confirm/:bookingId',
      name: RouteNames.reviewConfirm,
      builder: (context, state) {
        final bookingId = int.parse(state.pathParameters['bookingId']!);
        return ReviewConfirmScreen(bookingId: bookingId);
      },
    ),
    GoRoute(
      path: '/payment-success/:bookingId',
      name: RouteNames.paymentSuccess,
      builder: (context, state) {
        final bookingId = int.parse(state.pathParameters['bookingId']!);
        final data = state.extra as Map<String, dynamic>? ?? {};
        return PaymentSuccessScreen(
          bookingId: bookingId,
          fullName: data['fullName'] as String? ?? '',
          phone: data['phone'] as String? ?? '',
          paymentMethod: data['paymentMethod'] as String? ?? '',
        );
      },
    ),

    // ── Booking Management ─────────────────────────────────────────
    GoRoute(
      path: '/booking-summary/:bookingId',
      name: RouteNames.bookingEventSummary,
      builder: (context, state) {
        final bookingId = int.parse(state.pathParameters['bookingId']!);
        final data = state.extra as Map<String, dynamic>? ?? {};
        return UpcomingBookingEventSummary(
          bookingId: bookingId,
          contentType: data['contentType'] as String?,
          shootTypeId: data['shootTypeId'] as int? ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/manage-booking/:bookingId',
      name: RouteNames.manageBooking,
      builder: (context, state) {
        final bookingId = int.parse(state.pathParameters['bookingId']!);
        final data = state.extra as Map<String, dynamic>? ?? {};
        return UpcomingEventSummaryManagebooking(
          bookingId: bookingId,
          shootTypeId: data['shootTypeId'] as int? ?? 0,
          projectName: data['projectName'] as String?,
          eventDate: data['eventDate'] as String?,
          startTime: data['startTime'] as String?,
          endTime: data['endTime'] as String?,
          // This safely handles nulls, ints, and doubles
          durationHours:(data['durationHours'] as num?)?.toDouble(),
          location: data['location'] as String?,
          imageUrl: data['imageUrl'] as String?,
          contentType: data['contentType'] as String?,
          multiDays: data['multiDays'] as List<dynamic>?,
        );
      },
    ),
    GoRoute(
      path: '/booking-review-confirm/:bookingId',
      name: RouteNames.bookingReviewConfirm,
      builder: (context, state) {
        final bookingId = int.parse(state.pathParameters['bookingId']!);
        return BookinReviewConfirm(bookingId: bookingId);
      },
    ),
    GoRoute(
      path: '/cancel-booking/:bookingId',
      name: RouteNames.cancelBooking,
      builder: (context, state) {
        final bookingId = int.parse(state.pathParameters['bookingId']!);
        final data = state.extra as Map<String, dynamic>? ?? {};
        return CancelBooking(
          bookingId: bookingId,
          projectName: data['projectName'] as String?,
          eventDate: data['eventDate'] as String?,
          startTime: data['startTime'] as String?,
          endTime: data['endTime'] as String?,
          durationHours: data['durationHours'] as int?,
          location: data['location'] as String?,
          contentType: data['contentType'] as String?,
          imageUrl: data['imageUrl'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/select-booking-type/:bookingId',
      name: RouteNames.selectBookingType,
      builder: (context, state) {
        final bookingId = int.parse(state.pathParameters['bookingId']!);
        return MySelectbookingtype(bookingId: bookingId);
      },
    ),
    GoRoute(
      path: '/shoot-updated',
      name: RouteNames.shootUpdated,
      builder: (context, state) => const ShootUpdatedScreen(),
    ),

    // ── Profile ────────────────────────────────────────────────────
    GoRoute(
      path: '/profile',
      name: RouteNames.profile,
      builder: (context, state) => const MyProfile(),
    ),
    GoRoute(
      path: '/edit-profile',
      name: RouteNames.editProfile,
      builder: (context, state) => const EditProfile(),
    ),
    GoRoute(
      path: '/change-password',
      name: RouteNames.changePassword,
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return ChangePasswordScreen(email: email);
      },
    ),
    GoRoute(
      path: '/profile-otp',
      name: RouteNames.profileOtp,
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return EnterOtpCodeScreen(email: email);
      },
    ),
    GoRoute(
      path: '/profile-new-password',
      name: RouteNames.profileNewPassword,
      builder: (context, state) {
        final data = state.extra as Map<String, String>? ?? {};
        return MyprofileNewPasswordScreen(
          email: data['email'] ?? '',
          otp: data['otp'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/booking-history',
      name: RouteNames.bookingHistory,
      builder: (context, state) => const BookingHistoryScreen(),
    ),
    GoRoute(
      path: '/favourites',
      name: RouteNames.favourites,
      builder: (context, state) => const FavouriteScreen(),
    ),
    GoRoute(
      path: '/app-preferences',
      name: RouteNames.appPreferences,
      builder: (context, state) => const AppPreferences(),
    ),
    GoRoute(
      path: '/delete-account',
      name: RouteNames.deleteAccount,
      builder: (context, state) => const DeleteAccount(),
    ),
    GoRoute(
      path: '/delete-account-otp',
      name: RouteNames.deleteAccountOtp,
      builder: (context, state) => const DeleteAccountOtpScreen(),
    ),
  ],
);

/// Shell widget for bottom navigation with IndexedStack.
/// Replaces the destructive switch(_selectedIndex) in old MainScreen.
class _MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _MainShell({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        elevation: 0,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Book Shoot'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'My Shoots'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
        ],
      ),
    );
  }
}
