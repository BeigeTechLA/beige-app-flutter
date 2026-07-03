import 'package:flutter/material.dart';
import '../../../../app/assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:beige/features/home/data/models/home_model.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/core/providers/guest_mode_provider.dart';
import 'package:beige/features/home/presentation/providers/home_notifier.dart';
import 'package:beige/features/home/presentation/providers/home_providers.dart';
import 'package:beige/features/home/presentation/widgets/bookings/home_bookings_stack.dart';
import 'package:beige/features/home/presentation/widgets/common/home_section_divider.dart';
import 'package:beige/features/home/presentation/widgets/common/home_section_title.dart';
import 'package:beige/features/home/presentation/widgets/continue_booking/home_continue_booking_card.dart';
import 'package:beige/features/home/presentation/widgets/featured_creatives/home_featured_creatives_carousel.dart';
import 'package:beige/features/home/presentation/widgets/header/home_header.dart';
import 'package:beige/features/home/presentation/widgets/how_it_works/home_how_it_works_section.dart';
import 'package:beige/features/home/presentation/widgets/promo/home_promo_carousel.dart';
import 'package:beige/features/home/presentation/widgets/recommended_creatives/home_recommended_creatives_rail.dart';
import 'package:beige/features/home/presentation/widgets/services/home_services_row.dart';
import 'package:beige/features/home/presentation/widgets/studios/home_studios_section.dart';
import 'package:beige/features/home/presentation/widgets/top_creatives/home_top_creatives_stack.dart';
import 'package:beige/features/home/presentation/widgets/top_influencers/home_top_influencers_section.dart';
import 'package:beige/shared/widgets/loading.dart';
import 'package:beige/shared/widgets/login_dialog.dart';

import '../../../app_drawer/screen/drawer_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final GlobalKey featuredKey = GlobalKey();
  final GlobalKey topCreativeKey = GlobalKey();
  int? contentTypeId;
  int? bookingId;
  int _currentCard = 0;

  HomeModel? get homeData => ref.read(homeNotifierProvider).homeData;
  List<Your_Booking> get bookingList => homeData?.yourBookings ?? [];

  late AnimationController _controller;
  late PageController _studioController;
  int _activeStudioIndex = 0;
  final PageController _featuredController = PageController(
    initialPage: 1000,
    viewportFraction: 0.65,
  );

  late PageController _cardController;
  int _currentBookingIndex = 0;
  late AnimationController _bookingSwipeController;
  final Set<int> selectedIndices = {};

  late AnimationController _swipeController;
  int _currentCreativeIndex = 0;

  final int _initialPage = 1000;

  void scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  // Data used by animated and static home sections.
  final List<String> _searchTexts = [
    "I want a Wedding Photographer",
    "I want a Wedding Videographer",
  ];

  final List<Map<String, String>> cardData = [
    {
      "bg": AppAssets.homeCardBg,
      "image": AppAssets.homeBook1,
      "title": "Find Your Perfect Creator\nAnywhere, Anytime.",
      "button": "Book a Shoot",
    },
    {
      "bg": AppAssets.homeBackground,
      "image": AppAssets.homeBook2,
      "title": "Trusted by Leading\nBrands.",
      "button": " Explore Creatives",
    },
    {
      "bg": AppAssets.homeBackground,
      "image": AppAssets.homeBook3,
      "title": "Instant Pricing &\nIntelligent Matchmaking.",
      "button": "Find Your Creative",
    },
  ];

  final List<Map<String, String>> featuredCreativeList = [
    {
      "image": AppAssets.creativeBensonF,
      "name": "Benson F.",
      "location": "Phoenix",
    },
    {
      "image": AppAssets.creativeCoreyB,
      "name": "Corey B.",
      "location": "Los Angeles",
    },
    {
      "image": AppAssets.creativeMikeyD,
      "name": "Mikey D.",
      "location": "Nashville",
    },
    {
      "image": AppAssets.creativeGaryAhmed,
      "name": "Gary A.",
      "location": "Los Angeles",
    },
    {
      "image": AppAssets.creativeNathanGrant,
      "name": "Nathan G.",
      "location": "New York",
    },
    {
      "image": AppAssets.creativeCorneliumM,
      "name": "Cornelius M.",
      "location": "Portland",
    },
    {
      "image": AppAssets.creativeJesseS,
      "name": "Jesse S.",
      "location": "Seattle",
    },
    {
      "image": AppAssets.creativeAlecH,
      "name": "Alec H.",
      "location": "Houston",
    },
    {
      "image": AppAssets.creativeDanielC,
      "name": "Daniel C.",
      "location": "Dallas",
    },
    {
      "image": AppAssets.creativeChristopherR,
      "name": "Christopher R.",
      "location": "Austin",
    },
    {
      "image": AppAssets.creativeDanielA,
      "name": "Daniel A.",
      "location": "Atlanta",
    },
  ];
  final List<Map<String, String>> studioList = [
    {
      "image": AppAssets.studioBeige,
      // Studio image used by the Beige Media carousel entry.
      "name": "Beige Media",
      "desc": "(Modern Resort Villa with Jacuzzi)",
      "location": "Woodland Hills, Los Angeles,",
      "price": "\$150/Hr",
      "rating": "4.5 (120)",
    },
    {
      "image": AppAssets.studioCreativeZone,
      "name": "Creative Zone",
      "desc": "(Professional Photo Studio & Lights)",
      "location": "Santa Ana, Illinois,",
      "price": "\$120/Hr",
      "rating": "4.8 (95)",
    },
    {
      "image": AppAssets.studioBeigeAlt,
      // Alternate studio image for the repeated Beige Media entry.
      "name": "Beige Media",
      "desc": "(Modern Resort Villa with Jacuzzi)",
      "location": "Woodland Hills, Los Angeles,",
      "price": "\$150/Hr",
      "rating": "4.5 (120)",
    },
  ];

  Future<void> openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  final List<String> words = [
    "Influencers",
    "Streamers",
    "Actors",
    "Models",
    "Personalities",
  ];

  final List<String> Topwords = [
    AppAssets.topJustinBieber,
    AppAssets.topCedric,
    AppAssets.topWizKhalifa,
    AppAssets.topPressa,
    AppAssets.topTyga,
    AppAssets.topCentralCee,
    AppAssets.topChiefKeef,
    AppAssets.topSwaeLee,
    AppAssets.topNatashaGraziano,
  ];

  final List<String> Topinstagram = [
    "https://www.instagram.com/lilbieber/",
    "https://www.instagram.com/cedtheentertainer/",
    "https://www.instagram.com/wizkhalifa/",
    "https://www.instagram.com/pressa.armani/",
    "https://www.instagram.com/tyga/",
    "https://www.instagram.com/centralcee/",
    "https://www.instagram.com/chiefkeeffsossa/",
    "https://www.instagram.com/swaelee/",
    "https://www.instagram.com/natashagraziano/",
  ];

  final List<String> Topyoutube = [
    "https://youtube.com/@justinbieber",
    "",
    "https://youtube.com/@wizkhalifa",
    "https://youtube.com/",
    "https://youtube.com/@tyga",
    "https://youtube.com/@centralcee",
    "https://youtube.com/",
    "https://youtube.com/@swaelee",
    "https://youtube.com/",
  ];

  final List<String> Toptiktok = [
    "https://www.tiktok.com/@justinbieber", // Justin Bieber
    "", // Cedric (no official)
    "https://www.tiktok.com/@wizkhalifa", // Wiz Khalifa
    "https://www.tiktok.com/@officialpressa", // Pressa
    "https://www.tiktok.com/@tyga", // Tyga
    "https://www.tiktok.com/@centralcee", // Central Cee
    "https://www.tiktok.com/@chiefkeefsossa1", // Chief Keef
    "https://www.tiktok.com/@swaelee", // Swae Lee
    "https://www.tiktok.com/@natasha.graziano", // Natasha Graziano
    "",
  ];

  final List<String> Topname = [
    "Justin Bieber",
    "Cedric The Entertainer",
    "Wiz Khalifa",
    "Pressa",
    "Tyga",
    "Central Cee",
    "Chief Keef",
    "Swae Lee",
    "Natasha Graziano",
  ];

  final List<String> instaFollowers = [
    "292M",
    "3.3M",
    "39.7M",
    "442K",
    "45.5M",
    "16.6M",
    "10M",
    "11.7M",
    "14M",
  ];

  final List<String> youtubeFollowers = [
    "76.7M",
    "-",
    "30.1M",
    "163K",
    "12M",
    "6.42M",
    "2.26M",
    "921K",
    "1.11M",
  ];

  final List<String> tiktokFollowers = [
    "29.5M",
    "-",
    "7.7M",
    "557K",
    "11.3M",
    "19.2M",
    "703K",
    "3.8M",
    "4.8M",
  ];

  final PageController _pageController = PageController(
    initialPage: 1000,
    viewportFraction: 0.65,
  );

  int getContentTypeId(String type) {
    switch (type.toLowerCase()) {
      case "photographer":
        return 2;
      case "videographer":
        return 1;
      case "Select All":
        return 3;
      default:
        return 1;
    }
  }

  Future<void> handleResume(ContinueBooking booking) async {
    /// Uses the booking content type returned by the backend.
    String type = booking.contentType ?? "photographer";

    int contentTypeId = getContentTypeId(type);

    int shootTypeId = 0; // Shoot type is resolved later in the booking flow.

    openResumeScreen(
      booking.currentScreen,
      booking.bookingId,
      contentTypeId,
      shootTypeId,
      {},
    );
  }

  void openResumeScreen(
    String screen,
    int bookingId,
    int contentTypeId,
    int shootTypeId,
    Map<String, dynamic> data,
  ) {
    switch (screen) {
      case "save_content_type":
        context.pushNamed(RouteNames.contentType);
        break;

      case "save_shoot_type":
        context.pushNamed(
          RouteNames.videoShootType,
          extra: {'bookingId': bookingId, 'contentTypeId': contentTypeId},
        );
        break;

      case "get_edit_types":
        context.pushNamed(
          RouteNames.videoShootType,
          extra: {'bookingId': bookingId, 'contentTypeId': contentTypeId},
        );
        break;

      case "save_time":
        context.pushNamed(
          RouteNames.shootDateTime,
          extra: {
            'bookingId': bookingId,
            'contentTypeId': contentTypeId,
            'shootTypeId': shootTypeId,
          },
        );
        break;

      case "save_details":
        context.pushNamed(
          RouteNames.moreDetails,
          extra: {
            'bookingId': bookingId,
            'contentTypeId': contentTypeId,
            'shootTypeId': shootTypeId,
          },
        );
        break;

      case "crew_recommendation":
        context.pushNamed(
          RouteNames.crewSizeMatching,
          extra: {
            'bookingId': bookingId,
            'contentTypeId': contentTypeId,
            'shootTypeId': shootTypeId,
          },
        );
        break;

      case "creative_matches":
        context.pushNamed(
          RouteNames.selectDreamTeam,
          extra: {
            'bookingId': bookingId,
            'contentTypeId': contentTypeId,
            'shootTypeId': shootTypeId,
          },
        );
        break;

      case "selected_creatives":
        context.pushNamed(
          RouteNames.selectDreamTeam,
          extra: {
            'bookingId': bookingId,
            'contentTypeId': contentTypeId,
            'shootTypeId': shootTypeId,
          },
        );
        break;

      case "summary":
        context.pushNamed(
          RouteNames.reviewConfirm,
          pathParameters: {'bookingId': bookingId.toString()},
        );
        break;

      case "payment_method":
        context.pushNamed(
          RouteNames.reviewConfirm,
          pathParameters: {'bookingId': bookingId.toString()},
        );
        break;

      case "pay_now":
        context.pushNamed(
          RouteNames.reviewConfirm,
          pathParameters: {'bookingId': bookingId.toString()},
        );
        break;

      default:
        debugPrint("Unknown screen: $screen");
    }
  }

  final List<Color> _textColors = [
    AppColors.white.withValues(alpha: 0.5),
    AppColors.primary,
    AppColors.white70,
  ];
  Future<void> _continueBooking(int contentType) async {
    final repo = ref.read(homeRepositoryProvider);
    final result = await repo.createBooking(
      contentType: contentType,
      bookingId: bookingId,
    );

    if (!mounted) return;

    result.fold(
      (error) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message))),
      (response) async {
        if (response['error'] == false) {
          bookingId = response['data']?['booking_id'];

          final navResult = await context.pushNamed<int>(
            RouteNames.videoShootType,
            extra: {'bookingId': bookingId!, 'contentTypeId': contentType},
          );

          if (navResult != null) {
            bookingId = navResult;
          }
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _studioController = PageController(
      initialPage: studioList.length * 50,
      viewportFraction: 0.7,
    );

    _activeStudioIndex = _studioController.initialPage % studioList.length;

    _controller = AnimationController(
      vsync: this,

      duration: const Duration(seconds: 10),
    )..repeat();

    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardController = PageController(
      initialPage: cardData.length * 50,
      viewportFraction: 0.88,
    );
    _bookingSwipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _swipeController.dispose();
    _bookingSwipeController.dispose();
    super.dispose();
  }

  /// Returns true if a guest user tapped — shows login dialog and aborts the
  /// caller's navigation. Returns false for an authenticated user; caller
  /// proceeds with its normal action.
  bool _blockIfGuest() {
    if (ref.read(guestModeProvider)) {
      showLoginDialog(context);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // When the guest flag flips to false (login success), refetch home data.
    ref.listen<bool>(guestModeProvider, (prev, next) {
      if (prev == true && next == false) {
        ref.read(homeNotifierProvider.notifier).fetchHomeData();
      }
    });

    final isGuest = ref.watch(guestModeProvider);
    final homeState = ref.watch(homeNotifierProvider);
    final homeData = homeState.homeData;
    final isLoading = homeState.status == HomeStatus.loading;

    return Scaffold(
      drawer: const DrawerScreen(),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 76,
              ),
              child: Column(
                children: [
                  HomeMapSection(
                    controller: _controller,
                    searchTexts: _searchTexts,
                    searchTextColors: _textColors,
                  ),
                  const SizedBox(height: 30),
                  const HomeSectionDivider(),
                  const SizedBox(height: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Section 2: Explore Services ──
                      const HomeSectionTitle(title: "Explore Services"),

                      const SizedBox(height: 10),

                      HomeServicesRow(
                        selectedIndices: selectedIndices,
                        controller: _controller,
                        onTap: (index, title) {
                          if ((title == "Photo" || title == "Video") &&
                              _blockIfGuest()) {
                            return;
                          }
                          if (title == "Photo" || title == "Video") {
                            setState(() {
                              if (selectedIndices.contains(index)) {
                                selectedIndices.remove(index);
                              } else {
                                selectedIndices.add(index);
                              }
                            });
                            playBorderAnimationOnce();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("$title Coming Soon"),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                      ),

                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Padding(
                          padding: const EdgeInsets.only(
                            left: AppSpacing.xl,
                            right: AppSpacing.xl,
                            top: AppSpacing.md,
                            bottom: AppSpacing.xs,
                          ),
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                if (selectedIndices.isEmpty) return;
                                final hasPhoto = selectedIndices.contains(0);
                                final hasVideo = selectedIndices.contains(1);

                                if (hasPhoto && hasVideo) {
                                  if (_blockIfGuest()) return;
                                  _continueBooking(3);
                                } else if (hasPhoto) {
                                  if (_blockIfGuest()) return;
                                  _continueBooking(2);
                                } else if (hasVideo) {
                                  if (_blockIfGuest()) return;
                                  _continueBooking(1);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.onPrimary,
                                shape: const StadiumBorder(),
                                minimumSize: const Size(double.infinity, 56),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Continue",
                                    style: TextStyle(
                                      fontFamily: AppAssets.fontUnbounded,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                        crossFadeState: selectedIndices.isNotEmpty
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),

                      const HomeSectionDivider(centerAlpha: 0.24),

                      // ── Section 3: Continue Booking (conditional) ──
                      if (homeData?.continueBooking != null &&
                          homeData!.continueBooking!.show)
                        HomeContinueBookingCard(
                          booking: homeData.continueBooking!,
                          onResume: () =>
                              handleResume(homeData.continueBooking!),
                        ),

                      const SizedBox(height: 20),
                      // ── Section 4: Promo Carousel ──
                      HomePromoCarousel(
                        controller: _cardController,
                        cards: cardData,
                        currentIndex: _currentCard,
                        onPageChanged: (index) {
                          setState(() {
                            _currentCard = index;
                          });
                        },
                        onBookShoot: () {
                          if (_blockIfGuest()) return;
                          context.pushNamed(
                            RouteNames.contentType,
                            extra: {'fromHome': true},
                          );
                        },
                        onExploreCreatives: () => scrollTo(featuredKey),
                        onFindCreative: () => scrollTo(topCreativeKey),
                      ),
                      const SizedBox(height: 20),
                      const HomeSectionDivider(centerAlpha: 0.24),
                      const SizedBox(height: 10),
                      // ── Section 5: Featured Creatives ──
                      HomeSectionTitle(
                        key: featuredKey,
                        title: "Featured Creatives",
                      ),
                      const SizedBox(height: 20),
                      HomeFeaturedCreativesCarousel(
                        controller: _pageController,
                        creatives: featuredCreativeList,
                        initialPage: _initialPage,
                      ),
                      const SizedBox(height: 10),

                      const HomeSectionDivider(centerAlpha: 0.24),
                      const SizedBox(height: 10),
                      // ── Section 6: Studios ──
                      HomeStudiosSection(
                        borderController: _controller,
                        studioController: _studioController,
                        activeIndex: _activeStudioIndex,
                        studios: studioList,
                        onPageChanged: (i) =>
                            setState(() => _activeStudioIndex = i),
                      ),
                      const SizedBox(height: 20),
                      const HomeSectionDivider(centerAlpha: 0.24),
                      const SizedBox(height: 20),
                      // ── Section 7: Your Bookings ──
                      HomeSectionTitle(
                        title: "Your Bookings",
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppAssets.fontUnbounded,
                        ),
                        trailing: GestureDetector(
                          onTap: () => context.goNamed(RouteNames.myShoots),
                          behavior: HitTestBehavior.opaque,
                          child: const Icon(
                            Icons.chevron_right,
                            color: AppColors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      HomeBookingsStack(
                        swipeController: _bookingSwipeController,
                        bookings: bookingList,
                        currentIndex: _currentBookingIndex,
                        onAdvance: () => setState(() {
                          _currentBookingIndex =
                              (_currentBookingIndex + 1) % bookingList.length;
                        }),
                        onBookShoot: () {
                          if (_blockIfGuest()) return;
                          context.pushNamed(
                            RouteNames.contentType,
                            extra: {'fromHome': true},
                          );
                        },
                        onCardTap: (booking) {
                          context.pushNamed(
                            RouteNames.bookingEventSummary,
                            pathParameters: {
                              'bookingId': booking.bookingId.toString(),
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 10),
                      // ── Section 8: Recommended Creatives (non-guest) ──
                      if (!isGuest) const HomeSectionDivider(centerAlpha: 0.09),
                      if (!isGuest) const SizedBox(height: 20),
                      if (!isGuest)
                        HomeSectionTitle(
                          title: "We Think You’ll Love These ",
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.white,
                            height: 1.2,
                          ),
                        ),
                      if (!isGuest) const SizedBox(height: 20),

                      if (!isGuest)
                        HomeRecommendedCreativesRail(
                          creatives: homeData?.featuredCreatives ?? const [],
                          onViewProfile: (id) {
                            context.pushNamed(
                              RouteNames.recommendedDetails,
                              pathParameters: {'id': id.toString()},
                              queryParameters: {'bookingId': '121'},
                            );
                          },
                        ),
                      const SizedBox(height: 10),
                      const HomeSectionDivider(centerAlpha: 0.09),
                      const SizedBox(height: 10),
                      // TODO(rebook-shoots): planned feature — full design
                      //  preserved below; do not delete without product sign-off.
                      /*  Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const AppSpacing.insetsHXl,
                                child: Text(
                                  "Rebook Your Shoots",
                                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.white, height: 1.2),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                                child: Container(
                                  height: 280,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadii.roundAll,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.black.withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      )
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // 1. MAIN BACKGROUND IMAGE
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius: AppRadii.roundAll,
                                          child: Image.asset(
                                            AppAssets.rebookShoots,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),

                                      // 2. BLACK GRADIENT (Bottom to Top)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: AppRadii.roundAll,
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                AppColors.black.withValues(alpha: 0.9),
                                                AppColors.black.withValues(alpha: 0.4),
                                                AppColors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      // 3. CONTENT (Icon, Text, Buttons)
                                      Positioned(
                                        bottom: 20,
                                        left: 20,
                                        right: 20,
                                        child: Column(
                                          children: [
                                            // --- MUSIC INFO ROW ---
                                            Row(
                                              children: [
                                                // Dark Circular Icon Background
                                                Container(
                                                  padding: const EdgeInsets.all(AppSpacing.smd),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.white.withValues(alpha: 0.12),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(Icons.music_note,
                                                      color: AppColors.white, size: 20),
                                                ),
                                                const SizedBox(width: 12),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment
                                                      .start,
                                                  children: const [
                                                    Text(
                                                      "Music Video",
                                                      style: TextStyle(
                                                        color: AppColors.white,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: AppAssets.fontOutfit,
                                                      ),
                                                    ),
                                                    Text(
                                                      "March 18, 2026 • Las Vegas, USA",
                                                      style: AppTextStyles.bodySmall.copyWith(
                                                        color: AppColors.white60,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 20),

                                            // --- ACTION BUTTONS ROW ---
                                            Row(
                                              children: [
                                                // Book Again Button
                                                Expanded(
                                                  child: Container(
                                                    height: 30,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary,
                                                      // Uses the app's primary beige action color.
                                                      borderRadius: AppRadii.roundAll,
                                                    ),
                                                    child: const Text(
                                                      "Book Again",
                                                      style: TextStyle(
                                                        color: AppColors.black,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w700,
                                                        fontFamily: AppAssets.fontHelveticaNeue,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                // Circular Arrow Button
                                                SvgPicture.asset(
                                                  AppAssets.homeViewProfile,

                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            ],
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.smd),
                            child: Container(
                              height: 1,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.white.withValues(alpha: 0.09), // left
                                    AppColors.white.withValues(alpha: 0.09), // center
                                    AppColors.white.withValues(alpha: 0.09), // right
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),*/
                      // Recent Project section.
                      // TODO(recent-project): planned feature — full design
                      //  preserved below; do not delete without product sign-off.
                      /*       Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Recent Project",
                              style: AppTextStyles.titleSmall.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 15),

                            // Card 1 with "D" Badge
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                _buildProjectCard(
                                    "Private Event", "Mar 10, 2025", "136 Files",
                                    AppAssets.studioBeige),

                              ],
                            ),

                            const SizedBox(height: 12),

                            // Card 2
                            _buildProjectCard(
                                "Wedding Photography", "Feb 15, 2025", "150 Files",
                                AppAssets.studioBeige),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),*/
                      /*    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.smd),
                        child: Container(
                          height: 1,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.white.withValues(alpha: 0.09), // left
                                AppColors.white.withValues(alpha: 0.09), // center
                                AppColors.white.withValues(alpha: 0.09), // right
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),*/
                      // ── Section 9: How It Works ──
                      const HomeHowItWorksSection(),
                      const HomeSectionDivider(centerAlpha: 0.09),
                      const SizedBox(height: 10),
                      // ── Section 10: Top Influencers ──
                      HomeTopInfluencersSection(
                        animationController: _controller,
                        pageController: _featuredController,
                        words: words,
                        images: Topwords,
                        names: Topname,
                        instagramUrls: Topinstagram,
                        youtubeUrls: Topyoutube,
                        tiktokUrls: Toptiktok,
                        instagramFollowers: instaFollowers,
                        youtubeFollowers: youtubeFollowers,
                        tiktokFollowers: tiktokFollowers,
                        onOpenLink: openLink,
                      ),
                      const SizedBox(height: 20),

                      const HomeSectionDivider(centerAlpha: 0.09),
                      const SizedBox(height: 20),

                      // ── Section 11: Top Creatives Near You (non-guest) ──
                      if (isGuest) const SizedBox(height: 50),
                      if (!isGuest)
                        Padding(
                          key: topCreativeKey,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.smd,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Top Creatives Near you",
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: AppColors.white,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              HomeTopCreativesStack(
                                swipeController: _swipeController,
                                creatives: homeData?.mainCreatives ?? const [],
                                currentIndex: _currentCreativeIndex,
                                onAdvance: () => setState(() {
                                  final list =
                                      homeData?.mainCreatives ?? const [];
                                  if (list.isEmpty) return;
                                  _currentCreativeIndex =
                                      (_currentCreativeIndex + 1) % list.length;
                                }),
                                onReverse: () => setState(() {
                                  final list =
                                      homeData?.mainCreatives ?? const [];
                                  if (list.isEmpty) return;
                                  _currentCreativeIndex =
                                      (_currentCreativeIndex -
                                          1 +
                                          list.length) %
                                      list.length;
                                }),
                                onViewProfile: (id) {
                                  if (_blockIfGuest()) return;
                                  context.pushNamed(
                                    RouteNames.recommendedDetails,
                                    pathParameters: {'id': id.toString()},
                                    queryParameters: {'bookingId': '121'},
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      if (!isGuest) const SizedBox(height: 70),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ── Sticky Header ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HomeHeader(
              userName: homeData?.name,
              location: homeData?.location,
              profileImageUrl: homeData?.profileImageUrl,
              isGuest: isGuest,
              onLocationTap: () async {
                if (_blockIfGuest()) return;
                final result = await context.pushNamed<Map<String, dynamic>>(
                  RouteNames.changeLocation,
                );
                if (result != null) {
                  ref.read(homeNotifierProvider.notifier).fetchHomeData();
                }
              },
              onProfileTap: () async {
                if (_blockIfGuest()) return;
                await context.pushNamed(RouteNames.profile);
                ref.read(homeNotifierProvider.notifier).fetchHomeData();
              },
            ),
          ),
          if (isLoading) const AppLoadingOverlay(),
        ],
      ),
    );
  }

  void playBorderAnimationOnce() {
    _controller.reset();
    _controller.forward(); // Play once from the reset position.
  }
}
