import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../features/shoot/presentation/screens/cancel_shoot_screen.dart';
import '../features/shoot/presentation/screens/manage_shoot_screen.dart';
import '../features/shoot/presentation/screens/my_shoots_screen.dart';
import '../features/shoot/presentation/screens/shoot_edit_review_screen.dart';
import '../features/shoot/presentation/screens/shoot_summary_screen.dart';
import '../features/shoot/presentation/screens/shoot_type_selection_screen.dart';
import '../features/shoot/presentation/screens/shoot_update_success_screen.dart';
import '../features/booking/presentation/screens/content_type_screen.dart';
import '../features/booking/presentation/screens/crew_selection_screen.dart';
import '../features/booking/presentation/screens/crew_size_matching_screen.dart';
import '../features/booking/presentation/screens/payment_method_screen.dart';
import '../features/booking/presentation/screens/payment_success_screen.dart';
import '../features/booking/presentation/screens/shoot_date_time_screen.dart';
import '../features/booking/presentation/screens/shoot_details_screen.dart';
import '../features/booking/presentation/screens/shoot_review_screen.dart';
import '../features/booking/presentation/screens/shoot_type_screen.dart';
import '../features/home/presentation/screens/change_location_screen.dart';
import '../features/home/presentation/screens/creative_profile_screen.dart';
import '../features/home/presentation/screens/find_creative_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/home/presentation/screens/recommended_creative_detail_screen.dart';
import '../features/profile/presentation/screens/delete_account_otp_screen.dart';
import '../features/profile/presentation/screens/delete_account_screen.dart';
import '../features/profile/presentation/screens/app_preferences_screen.dart';
import '../features/profile/presentation/screens/change_password_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/favorites_screen.dart';
import '../features/profile/presentation/screens/profile_new_password_screen.dart';
import '../features/profile/presentation/screens/profile_otp_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/shoot_history_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/forgot_password_otp_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/password_reset_success_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/screens/sign_up_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../core/connectivity/connectivity_providers.dart';
import '../core/connectivity/connectivity_status.dart';
import '../core/providers/auth_state_provider.dart';
import '../core/providers/guest_mode_provider.dart';
import '../core/restoration/draft_store.dart';
import '../core/restoration/restoration_providers.dart';
import '../shared/widgets/login_dialog.dart';
import '../shared/widgets/scale_clamped_text.dart';
import 'assets.dart';
import 'colors.dart';
import 'navigator_key.dart';
import 'route_names.dart';
import 'text_styles.dart';

/// Routes that do not require authentication.
const _publicRoutes = {
  '/splash',
  '/onboarding',
  '/login',
  '/signup',
  '/forgot-password',
  '/forgot-otp',
  '/reset-password',
  '/password-success',
};

/// Routes a guest user may visit. Anything outside this set redirects to '/'.
/// Public auth routes are included so guest can tap "Ok" in [showLoginDialog].
const _guestAllowedRoutes = {
  '/',
  '/splash',
  '/onboarding',
  '/login',
  '/signup',
  '/forgot-password',
  '/forgot-otp',
  '/reset-password',
  '/password-success',
};

/// GoRouter provider — uses [authStateProvider] and [connectivityStatusProvider]
/// for redirect logic.
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<bool>(ref.read(authStateProvider));
  final guestNotifier = ValueNotifier<bool>(ref.read(guestModeProvider));
  final connNotifier = ValueNotifier<ConnectivityStatus>(
    ref.read(connectivityStatusProvider),
  );

  ref.listen(authStateProvider, (_, next) {
    authNotifier.value = next;
  });

  ref.listen(guestModeProvider, (_, next) {
    guestNotifier.value = next;
  });

  ref.listen(connectivityStatusProvider, (_, next) {
    connNotifier.value = next;
  });

  final refreshListenable =
      Listenable.merge([authNotifier, guestNotifier, connNotifier]);

  // Set of routes the user has already visited while online during this
  // session. While offline, navigation is allowed only to these (plus public
  // routes) so the user can still back-pop through already-loaded screens
  // but cannot push forward into routes that would need a network fetch.
  final visitedOnlineLocations = <String>{};
  String? lastOnlineLocation;

  final restorationService = ref.read(routeRestorationServiceProvider);
  final draftStore = ref.read(draftStoreProvider);

  /// Reads route extra, falls back to [DraftStore.readBookingDraft], and
  /// captures the live extra back into the draft for future cold-start
  /// restores.
  BookingDraft bookingDraftFor(GoRouterState state, String routeName) {
    final extra = state.extra as Map<String, dynamic>?;
    final previous = draftStore.readBookingDraft() ?? const BookingDraft();
    if (extra != null) {
      final fresh = BookingDraft.fromRouteExtra(extra, currentRoute: routeName)
          .mergeOver(previous);
      // ignore: discarded_futures
      draftStore.writeBookingDraft(fresh);
      return fresh;
    }
    final hydrated = previous;
    if (hydrated.currentRoute != routeName) {
      // ignore: discarded_futures
      draftStore.writeBookingDraft(BookingDraft(
        contentTypeId: hydrated.contentTypeId,
        shootTypeId: hydrated.shootTypeId,
        bookingId: hydrated.bookingId,
        value: hydrated.value,
        currentRoute: routeName,
      ));
    }
    return hydrated;
  }

  late final GoRouter router;

  void persistOnChange() {
    final matches = router.routerDelegate.currentConfiguration;
    if (matches.isEmpty) return;
    final fullPath = matches.fullPath.isNotEmpty
        ? matches.fullPath
        : matches.uri.path;
    // ignore: discarded_futures
    restorationService.persist(
      matchedLocation: fullPath,
      queryParameters: matches.uri.queryParameters,
      pathParameters: matches.pathParameters,
    );
  }

  ref.onDispose(() {
    router.routerDelegate.removeListener(persistOnChange);
    authNotifier.dispose();
    guestNotifier.dispose();
    connNotifier.dispose();
  });

  router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    observers: [
      FirebaseAnalyticsObserver(
        analytics: FirebaseAnalytics.instance,
        nameExtractor: (settings) => settings.name ?? 'unknown',
      ),
    ],
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final isLoggedIn = authNotifier.value;
      final isGuest = guestNotifier.value;
      final connectivity = connNotifier.value;
      final location = state.matchedLocation;

      final isPublicRoute = _publicRoutes.contains(location);

      // Auth gate first — runs regardless of connectivity.
      if (isLoggedIn && isPublicRoute) {
        return '/';
      }
      if (!isLoggedIn && !isGuest && !isPublicRoute) {
        return '/login';
      }
      // Guest can only access the home shell + public auth routes.
      if (!isLoggedIn &&
          isGuest &&
          !_guestAllowedRoutes.contains(location)) {
        return '/';
      }

      // Offline gate — allow public routes + any route already visited while
      // online (so back-nav still works). Block forward pushes into routes
      // that have never loaded successfully this session. Unknown status
      // (first frame) is treated as online so cold-start does not deadlock.
      if (connectivity == ConnectivityStatus.offline &&
          !isPublicRoute &&
          !visitedOnlineLocations.contains(location)) {
        return lastOnlineLocation;
      }

      if (connectivity != ConnectivityStatus.offline) {
        visitedOnlineLocations.add(location);
        lastOnlineLocation = location;
      }

      return null;
    },
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
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: RouteNames.signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/forgot-otp',
        name: RouteNames.forgotOtp,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return ForgotPasswordOtpScreen(email: email);
        },
      ),
      GoRoute(
        path: '/reset-password',
        name: RouteNames.resetPassword,
        builder: (context, state) {
          final data = state.extra as Map<String, String>? ?? {};
          return ResetPasswordScreen(
            email: data['email'] ?? '',
            otp: data['otp'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/password-success',
        name: RouteNames.passwordSuccess,
        builder: (context, state) => const PasswordResetSuccessScreen(),
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
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Tab 1: Book Shoot
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/book-shoot',
                name: RouteNames.bookShoot,
                builder: (context, state) =>
                    const ContentTypeScreen(fromHome: false),
              ),
            ],
          ),
          // Tab 2: My Shoots
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-shoots',
                name: RouteNames.myShoots,
                builder: (context, state) => const MyShootsScreen(),
              ),
            ],
          ),
          // Tab 3: Messages
          // Temporarily hidden. Keep this branch code for when messages are
          // ready to bind back into the bottom navigation.
          // StatefulShellBranch(
          //   routes: [
          //     GoRoute(
          //       path: '/messages',
          //       name: RouteNames.messages,
          //       builder: (context, state) =>
          //           const Center(child: Text('Messages')),
          //     ),
          //   ],
          // ),
        ],
      ),

      // ── Home Sub-Screens (pushed on top, no bottom nav) ────────────
      GoRoute(
        path: '/view-profile/:id',
        name: RouteNames.viewProfile,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CreativeProfileScreen(id: id);
        },
      ),
      GoRoute(
        path: '/recommended/:id',
        name: RouteNames.recommendedDetails,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final bookingId = int.parse(
            state.uri.queryParameters['bookingId'] ?? '0',
          );
          return RecommendedCreativeDetailScreen(id: id, bookingId: bookingId);
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
          final draft = bookingDraftFor(state, '/finding-perfect');
          return FindCreativeScreen(
            bookingId: draft.bookingId ?? 0,
            ShootTypeId: draft.shootTypeId ?? 0,
            contentTypeId: draft.contentTypeId ?? 0,
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
          final draft = bookingDraftFor(state, '/content-type');
          return ContentTypeScreen(
            fromHome: true,
            value: draft.value,
          );
        },
      ),
      GoRoute(
        path: '/video-shoot-type',
        name: RouteNames.videoShootType,
        builder: (context, state) {
          final draft = bookingDraftFor(state, '/video-shoot-type');
          return ShootTypeScreen(
            contentTypeId: draft.contentTypeId ?? 0,
            bookingId: draft.bookingId ?? 0,
          );
        },
      ),
      GoRoute(
        path: '/shoot-date-time',
        name: RouteNames.shootDateTime,
        builder: (context, state) {
          final draft = bookingDraftFor(state, '/shoot-date-time');
          return ShootDateTimeScreen(
            ShootTypeId: draft.shootTypeId ?? 0,
            bookingId: draft.bookingId ?? 0,
            contentTypeId: draft.contentTypeId ?? 0,
          );
        },
      ),
      GoRoute(
        path: '/more-details',
        name: RouteNames.moreDetails,
        builder: (context, state) {
          final draft = bookingDraftFor(state, '/more-details');
          return ShootDetailsScreen(
            contentTypeId: draft.contentTypeId ?? 0,
            ShootTypeId: draft.shootTypeId ?? 0,
            bookingId: draft.bookingId ?? 0,
          );
        },
      ),
      GoRoute(
        path: '/crew-size-matching',
        name: RouteNames.crewSizeMatching,
        builder: (context, state) {
          final draft = bookingDraftFor(state, '/crew-size-matching');
          return CrewSizeMatchingScreen(
            ShootTypeId: draft.shootTypeId ?? 0,
            bookingId: draft.bookingId ?? 0,
            contentTypeId: draft.contentTypeId ?? 0,
          );
        },
      ),
      GoRoute(
        path: '/select-dream-team',
        name: RouteNames.selectDreamTeam,
        builder: (context, state) {
          final draft = bookingDraftFor(state, '/select-dream-team');
          return CrewSelectionScreen(
            ShootTypeId: draft.shootTypeId ?? 0,
            bookingId: draft.bookingId ?? 0,
            contentTypeId: draft.contentTypeId ?? 0,
          );
        },
      ),
      GoRoute(
        path: '/review-confirm/:bookingId',
        name: RouteNames.reviewConfirm,
        builder: (context, state) {
          final bookingId = int.parse(state.pathParameters['bookingId']!);
          return ShootReviewScreen(bookingId: bookingId);
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
          return ShootSummaryScreen(
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
          final extra = state.extra as Map<String, dynamic>?;
          ManageBookingDraft draft;
          if (extra != null) {
            draft = ManageBookingDraft.fromRouteExtra(bookingId, extra);
            // ignore: discarded_futures
            draftStore.writeManageBookingDraft(draft);
          } else {
            final stored = draftStore.readManageBookingDraft();
            draft = (stored != null && stored.bookingId == bookingId)
                ? stored
                : ManageBookingDraft(bookingId: bookingId);
          }
          return ManageShootScreen(
            bookingId: bookingId,
            shootTypeId: draft.shootTypeId ?? 0,
            projectName: draft.projectName,
            eventDate: draft.eventDate,
            startTime: draft.startTime,
            endTime: draft.endTime,
            durationHours: draft.durationHours,
            location: draft.location,
            imageUrl: draft.imageUrl,
            contentType: draft.contentType,
            multiDays: draft.multiDays,
          );
        },
      ),
      GoRoute(
        path: '/booking-review-confirm/:bookingId',
        name: RouteNames.bookingReviewConfirm,
        builder: (context, state) {
          final bookingId = int.parse(state.pathParameters['bookingId']!);
          return ShootEditReviewScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: '/cancel-booking/:bookingId',
        name: RouteNames.cancelBooking,
        builder: (context, state) {
          final bookingId = int.parse(state.pathParameters['bookingId']!);
          final extra = state.extra as Map<String, dynamic>?;
          CancelBookingDraft draft;
          if (extra != null) {
            draft = CancelBookingDraft.fromRouteExtra(bookingId, extra);
            // ignore: discarded_futures
            draftStore.writeCancelBookingDraft(draft);
          } else {
            final stored = draftStore.readCancelBookingDraft();
            draft = (stored != null && stored.bookingId == bookingId)
                ? stored
                : CancelBookingDraft(bookingId: bookingId);
          }
          return CancelShootScreen(
            bookingId: bookingId,
            projectName: draft.projectName,
            eventDate: draft.eventDate,
            startTime: draft.startTime,
            endTime: draft.endTime,
            durationHours: draft.durationHours,
            location: draft.location,
            contentType: draft.contentType,
            imageUrl: draft.imageUrl,
          );
        },
      ),
      GoRoute(
        path: '/select-booking-type/:bookingId',
        name: RouteNames.selectBookingType,
        builder: (context, state) {
          final bookingId = int.parse(state.pathParameters['bookingId']!);
          return ShootTypeSelectionScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: '/shoot-updated',
        name: RouteNames.shootUpdated,
        builder: (context, state) => const ShootUpdateSuccessScreen(),
      ),

      // ── Profile ────────────────────────────────────────────────────
      GoRoute(
        path: '/profile',
        name: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: RouteNames.editProfile,
        builder: (context, state) => const EditProfileScreen(),
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
          return ProfileOtpScreen(email: email);
        },
      ),
      GoRoute(
        path: '/profile-new-password',
        name: RouteNames.profileNewPassword,
        builder: (context, state) {
          final data = state.extra as Map<String, String>? ?? {};
          return ProfileNewPasswordScreen(
            email: data['email'] ?? '',
            otp: data['otp'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/booking-history',
        name: RouteNames.bookingHistory,
        builder: (context, state) => const ShootHistoryScreen(),
      ),
      GoRoute(
        path: '/favourites',
        name: RouteNames.favourites,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/app-preferences',
        name: RouteNames.appPreferences,
        builder: (context, state) => const AppPreferencesScreen(),
      ),
      GoRoute(
        path: '/delete-account',
        name: RouteNames.deleteAccount,
        builder: (context, state) => const DeleteAccountScreen(),
      ),
      GoRoute(
        path: '/delete-account-otp',
        name: RouteNames.deleteAccountOtp,
        builder: (context, state) => const DeleteAccountOtpScreen(),
      ),
    ],
  );

  router.routerDelegate.addListener(persistOnChange);

  return router;
});

/// Shell widget for bottom navigation with IndexedStack.
/// Replaces the destructive switch(_selectedIndex) in old MainScreen.
class _MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _MainShell({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: ScaleClampedText(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top gradient fade — transparent to dark
            Container(
              height: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.transparent,
                    AppColors.background,
                  ],
                ),
              ),
            ),
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 85, sigmaY: 75),
                child: BottomNavigationBar(
                  currentIndex: navigationShell.currentIndex,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: AppColors.background,
                  selectedItemColor: AppColors.white,
                  unselectedItemColor: AppColors.white70,
                  iconSize: _bottomNavIconSize,
                  selectedFontSize: _bottomNavLabelFontSize,
                  unselectedFontSize: _bottomNavLabelFontSize,
                  selectedLabelStyle: AppTextStyles.labelSmall,
                  unselectedLabelStyle: AppTextStyles.labelSmall,
                  onTap: (index) {
                    final isGuest = ref.read(guestModeProvider);
                    if (isGuest && index != 0) {
                      showLoginDialog(context);
                      return;
                    }
                    navigationShell.goBranch(
                      index,
                      initialLocation: index == navigationShell.currentIndex,
                    );
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: _buildInactiveIcon(AppAssets.inactiveHome),
                      activeIcon: _buildActiveIcon(AppAssets.activeHome),
                      label: "  Home",
                    ),
                    BottomNavigationBarItem(
                      icon: _buildInactiveIcon(AppAssets.inactiveBookShoot),
                      activeIcon: _buildActiveIcon(
                        AppAssets.activeBookShoot,
                        width: _bottomNavActiveBookShootArtWidth,
                      ),
                      label: " Book Shoot",
                    ),
                    BottomNavigationBarItem(
                      icon: _buildInactiveIcon(AppAssets.inactiveMyShoot),
                      activeIcon: _buildActiveIcon(
                        AppAssets.activeMyShoot,
                        width: _bottomNavActiveMyShootsArtWidth,
                        height: _bottomNavActiveMyShootsArtHeight,
                      ),
                      label: " My Shoots",
                    ),
                    // Messages tab is temporarily hidden until the feature is
                    // ready to bind. Keep the item code for easy re-enable.
                    // BottomNavigationBarItem(
                    //   icon: _buildInactiveIcon(AppAssets.inactiveMessages),
                    //   activeIcon: _buildActiveIcon(AppAssets.activeMessages),
                    //   label: " Messages",
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const double _bottomNavIconSize = 26;
  static const double _bottomNavActiveArtSize = 44;
  static const double _bottomNavActiveBookShootArtWidth = 46;
  static const double _bottomNavActiveMyShootsArtWidth = 50;
  static const double _bottomNavActiveMyShootsArtHeight = 48;
  static const double _bottomNavIconSlotWidth = 44;
  static const double _bottomNavLabelFontSize = 10;

  Widget _buildInactiveIcon(String path) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        width: _bottomNavIconSlotWidth,
        height: _bottomNavIconSize,
        child: Center(
          child: SvgPicture.asset(
            path,
            height: _bottomNavIconSize,
            width: _bottomNavIconSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveIcon(String path, {double? width, double? height}) {
    final artWidth = width ?? _bottomNavActiveArtSize;
    final artHeight = height ?? _bottomNavActiveArtSize;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        width: artWidth,
        height: _bottomNavIconSize,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Soft white glow behind active icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.white.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              path,
              width: artWidth,
              height: artHeight,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
