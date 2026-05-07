
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../app/assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:beige/features/home/data/models/home_model.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/features/home/presentation/providers/home_notifier.dart';
import 'package:beige/features/home/presentation/providers/home_providers.dart';
import 'package:beige/shared/widgets/loading.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {

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
      viewportFraction: 0.65);

  late PageController _cardController;
  int _currentBookingIndex = 0;
  late AnimationController _bookingSwipeController;
  late AnimationController _borderController;
  int selectedIndex = -1;
  final PageController _inspiredController = PageController(
    initialPage: 1000,

    viewportFraction: 0.65,
  );

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
  // --- DATA LISTS FOR TEXT & COLORS ---
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

  final List<Map<String, String>> Your_Bookings = [
    {
      "bg": AppAssets.homeCardBg,
      "image": AppAssets.homeBook1,
      "title": "Find Your Perfect Creator\nAnywhere, Anytime.",
      "button": "Book a Shoot",
    },
  ];
  final List<String> featuredNames = [
    "Alec H",
   /* "Benson F",*/
    "Christopher R",
    "Corey B",
    "Cornelius M",
    "Daniel A",
    "Daniel C",
    "Gary Ahmed",
   /* "Jesse S.",*/
    "Mikey D",
    "Nathan Grant"
  ];

  final List<String> featuredImages = [
    AppAssets.creativeAlecH,
    AppAssets.creativeChristopherR,
    AppAssets.creativeCoreyB,
    AppAssets.creativeCorneliumM,
    AppAssets.creativeDanielA,
    AppAssets.creativeDanielC,
    AppAssets.creativeGaryAhmed,
    AppAssets.creativeMikeyD,
    AppAssets.creativeNathanGrant
  ];
  final List<String> images = [
    AppAssets.creativeAlecH,
    AppAssets.creativeChristopherR,
    AppAssets.creativeCoreyB,
    AppAssets.creativeCorneliumM,
    AppAssets.creativeDanielA,
    AppAssets.creativeDanielC,

  ];
  final List<Map<String, String>> studioList = [
    {
      "image": AppAssets.studioBeige,
      // Apni studio images dalein
      "name": "Beige Media",
      "desc": "(Modern Resort Villa with Jacuzzi)",
      "location": "Woodland Hills, Los Angeles,",
      "price": "\$150/Hr",
      "rating": "4.5 (120)"
    },
    {
      "image": AppAssets.studioCreativeZone,
      "name": "Creative Zone",
      "desc": "(Professional Photo Studio & Lights)",
      "location": "Santa Ana, Illinois,",
      "price": "\$120/Hr",
      "rating": "4.8 (95)"
    },
    {
      "image": AppAssets.studioBeigeAlt,
      // Apni studio images dalein
      "name": "Beige Media",
      "desc": "(Modern Resort Villa with Jacuzzi)",
      "location": "Woodland Hills, Los Angeles,",
      "price": "\$150/Hr",
      "rating": "4.5 (120)"
    },
  ];

  Future<void> openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  final List<String> words = ["Influencers", "Streamers", "Actors", "Models", "Personalities"];

  final List<String> Topwords = [
    AppAssets.topJustinBieber,
    AppAssets.topCedric,
    AppAssets.topWizKhalifa,
    AppAssets.topPressa,
    AppAssets.topTyga,
    AppAssets.topCentralCee,
    AppAssets.topChiefKeef,
    AppAssets.topSwaeLee,
    AppAssets.topNatashaGraziano
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
    "https://www.instagram.com/natashagraziano/"
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
    "https://youtube.com/"
  ];

  final List<String> Toptiktok = [
    "https://www.tiktok.com/@justinbieber",      // Justin Bieber
    "",                                         // Cedric (no official)
    "https://www.tiktok.com/@wizkhalifa",        // Wiz Khalifa
    "https://www.tiktok.com/@officialpressa",    // Pressa
    "https://www.tiktok.com/@tyga",              // Tyga
    "https://www.tiktok.com/@centralcee",        // Central Cee
    "https://www.tiktok.com/@chiefkeefsossa1",   // Chief Keef
    "https://www.tiktok.com/@swaelee",           // Swae Lee
    "https://www.tiktok.com/@natasha.graziano",  // Natasha Graziano
    ""
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
    "Natasha Graziano"
  ];

  final List<String> instaFollowers = [
    "292M","3.3M","39.7M","442K","45.5M","16.6M","10M","11.7M","14M"
  ];

  final List<String> youtubeFollowers = [
    "76.7M","-","30.1M","163K","12M","6.42M","2.26M","921K","1.11M"
  ];

  final List<String> tiktokFollowers = [
    "29.5M","-","7.7M","557K","11.3M","19.2M","703K","3.8M","4.8M"
  ];

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "completed":
        return AppColors.success;   // ✅ Completed → GREEN
      case "pending":
      case "draft":
      case "matching":
        return AppColors.error;     // 🔴 Sab pending type → RED
      default:
        return AppColors.error;     // Default bhi pending maan lo
    }
  }


  Color getStatusColorFromLabel(String label) {
    switch (label.toLowerCase()) {
      case "completed":
        return AppColors.success;   // ✅ Green
      case "pending":
        return AppColors.error;     // 🔴 Red
      default:
        return AppColors.error;
    }
  }
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

    /// 🔥 content_type direct backend se
    String type = booking.contentType ?? "photographer";

    int contentTypeId = getContentTypeId(type);

    int shootTypeId = 0; // abhi pending hai

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
        context.pushNamed(RouteNames.videoShootType, extra: {
          'bookingId': bookingId,
          'contentTypeId': contentTypeId,
        });
        break;

      case "get_edit_types":
        context.pushNamed(RouteNames.videoShootType, extra: {
          'bookingId': bookingId,
          'contentTypeId': contentTypeId,
        });
        break;

      case "save_time":
        context.pushNamed(RouteNames.shootDateTime, extra: {
          'bookingId': bookingId,
          'contentTypeId': contentTypeId,
          'shootTypeId': shootTypeId,
        });
        break;

      case "save_details":
        context.pushNamed(RouteNames.moreDetails, extra: {
          'bookingId': bookingId,
          'contentTypeId': contentTypeId,
          'shootTypeId': shootTypeId,
          'specialtyId': 22,
        });
        break;

      case "crew_recommendation":
        context.pushNamed(RouteNames.crewSizeMatching, extra: {
          'bookingId': bookingId,
          'contentTypeId': contentTypeId,
          'specialtyId': 22,
          'shootTypeId': shootTypeId,
        });
        break;

      case "creative_matches":
        context.pushNamed(RouteNames.selectDreamTeam, extra: {
          'bookingId': bookingId,
          'contentTypeId': contentTypeId,
          'specialtyId': 22,
          'shootTypeId': shootTypeId,
        });
        break;

      case "selected_creatives":
        context.pushNamed(RouteNames.selectDreamTeam, extra: {
          'bookingId': bookingId,
          'contentTypeId': contentTypeId,
          'specialtyId': 22,
          'shootTypeId': shootTypeId,
        });
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

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "";

    final d = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy').format(d); // 👉 04 08, 2026
  }
  String formatTime(String? time) {
    if (time == null || time.isEmpty) return "";
    final parsed = DateFormat("HH:mm:ss").parse(time);
    return DateFormat("hh:mm a").format(parsed); // 👉 09:00 AM
  }
  final List<Color> _textColors = [
    AppColors.white.withValues(alpha: 0.5),
    AppColors.primary,
    AppColors.white70
  ];
  Future<void> _continueBooking(int contentType) async {
    final repo = ref.read(homeRepositoryProvider);
    final result = await repo.createBooking(
      contentType: contentType,
      bookingId: bookingId,
    );

    if (!mounted) return;

    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      ),
      (response) async {
        if (response['error'] == false) {
          bookingId = response['data']?['booking_id'];

          final navResult = await context.pushNamed<int>(
            RouteNames.videoShootType,
            extra: {
              'bookingId': bookingId!,
              'contentTypeId': contentType,
            },
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
      initialPage: studioList.length * 50, //
      viewportFraction: 0.7, //
    );

    _activeStudioIndex =
        _studioController.initialPage % studioList.length;

    _controller = AnimationController(
      vsync: this,

      duration: const Duration(seconds: 10),
    )
      ..repeat();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(); // 🔥 continuous animation

    _swipeController = AnimationController( //
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardController = PageController(
        initialPage: cardData.length * 50,
        viewportFraction: 0.88);
    _bookingSwipeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),


    );
    
  }

  @override
  void dispose() {
    _controller.dispose();
    _swipeController.dispose(); // ✅ MUST
    _inspiredController.dispose(); // ✅ ADD THIS
    _bookingSwipeController.dispose();
    _borderController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final homeData = homeState.homeData;
    final isLoading = homeState.status == HomeStatus.loading;

    return Scaffold(

      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [

                    // --- 1. ANIMATED BORDER SECTION ---
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: BorderAnimationPainter(_controller.value,),
                          child: child,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 60, AppSpacing.xl, 80),
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadii.pillSm)),

                          // ✅ IMAGE ADDED HERE
                          image: DecorationImage(
                            image: AssetImage(AppAssets.mapImage),
                            // opacity: 0.2, // Subtle look ke liye opacity kam rakhi hai
                            fit: BoxFit.contain,
                            alignment: Alignment(0, 0.7),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Hello ${homeData?.name ?? "User"} 👋",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(

                                          color: AppColors.white,
                                          fontSize: 22,
                                          fontFamily: AppAssets.fontOutfit,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      GestureDetector(
                                        onTap: () async {
                                          final result = await context.pushNamed<Map<String, dynamic>>(RouteNames.changeLocation);

                                          if (result != null) {
                                            ref.read(homeNotifierProvider.notifier).fetchHomeData();
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Flexible(
                                                child:
                                                Text(
                                                    homeData?.location ?? "Loading...",

                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: AppColors.white.withValues(alpha: 0.6),
                                                        fontSize: 15,
                                                        fontFamily: AppAssets.fontOutfit))),
                                            const Icon(Icons.expand_more,
                                                color: AppColors.white, size: 20),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                // Profile Pill
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.xxs),
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadii.pillAll,
                                    color: AppColors.borderFaint,
                                    border: Border.all(
                                        color: AppColors.primary.withValues(alpha: 0.3),
                                        width: 0.5),
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smd),
                                        child:SvgPicture.asset(AppAssets.notification)
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          await context.pushNamed(RouteNames.profile);
                                          ref.read(homeNotifierProvider.notifier).fetchHomeData();
                                        },

                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: AppColors.transparent,
                                          child: ClipOval(
                                            child: homeData != null &&
                                                homeData.profileImageUrl.isNotEmpty
                                                ? Image.network(
                                              ApiEndpoints.imageUrl + homeData.profileImageUrl,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            )
                                                : SvgPicture.asset(
                                              AppAssets.person,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),

                    // --- 2. DYNAMIC SEARCH BAR (Text & Color Change) ---
                    Positioned(
                      bottom: -20,
                      child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.70,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppRadii.roundAll,
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              width: 0.5),
                          boxShadow: [
                            BoxShadow(color: AppColors.black.withValues(alpha: 0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8))
                          ],
                        ),
                        alignment: Alignment.center,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            // Logic to change text based on animation progress
                            int index = (_controller.value * _searchTexts.length)
                                .floor() % _searchTexts.length;

                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 800),
                              // Smooth Fade
                              child: Text(
                                _searchTexts[index],
                                key: ValueKey<int>(index),
                                // Key badalne par hi animation hoga
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _textColors[index], // DYNAMIC COLOR
                                  fontSize: 15,
                                  fontFamily: AppAssets.fontOutfit,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.smd),
                  child: Container(
                    height: 1,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.dividerGradientEdge, // 9% approx
                          AppColors.white15, // 15% (main center)
                          AppColors.dividerGradientEdge, // 9% approx
                        ],
                        /* begin: Alignment.centerLeft,
                              end: Alignment.centerRight,*/
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- 1. PROMO BANNER ---
                      SizedBox(
                        height: 160,
                        child: PageView.builder(
                          controller: _cardController,
                          itemCount: 1000, //
                          onPageChanged: (index) {
                            setState(() {
                              _currentCard = index % cardData.length;
                            });
                          },
                          itemBuilder: (context, index) {
                            final data = cardData[index % cardData.length]; //
                            return _buildCardbook(data);
                          },
                        ),
                      ),
                      // Banner Dots Indicator
                      Transform.translate(
                        offset: const Offset(0, -7), //
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(3, (index) {
                                bool isActive = index == _currentCard;

                                return GestureDetector(
                                  onTap: () {
                                    _cardController.animateToPage(
                                      index,
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeInOut,

                                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),

                                    height: 2, // 🔥 thoda better thickness
                                    width: isActive ? 26 : 14, // 🔥 smooth pill effect

                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? AppColors.primary
                                          : AppColors.white.withValues(alpha: 0.25),

                                      borderRadius: AppRadii.hugeAll,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.smd),
                        child: Container(
                          height: 1,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.dividerGradientEdge, // 9% approx
                                AppColors.white15, // 15% (main center)
                                AppColors.dividerGradientEdge, // 9% approx
                              ],
                             /* begin: Alignment.centerLeft,
                              end: Alignment.centerRight,*/
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // --- 2. EXPLORE SERVICES SECTION ---
                      Padding(
                        padding:  AppSpacing.insetsHXl,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Explore Services",
                              style: AppTextStyles.labelLarge.copyWith(
                                fontFamily: AppAssets.fontUnbounded,
                                color: AppColors.white,
                                height: 1.2,
                              ),

                            ),
                           /* SvgPicture.asset(
                              AppAssets.chevronRight,
                            ),*/
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Services Horizontal List
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: AppSpacing.smd),
                        child: Row(
                          children: [
                            _buildServiceCard(0, "Photo", AppAssets.servicePhotography),
                            _buildServiceCard(1, "Video", AppAssets.serviceVideography),
                            _buildServiceCard(2, "Editing", AppAssets.serviceEditing),
                            _buildServiceCard(3, "Livestream", AppAssets.serviceLivestream),
                            _buildServiceCard(4, "Studio", AppAssets.serviceStudio),
                          ],
                        ),
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
                                AppColors.white24,
                                AppColors.white.withValues(alpha: 0.09), // right
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                      // Main Card

                      const SizedBox(height: 10),
                      Column(
                        children: [
                      /// 🔥 CONTINUE BOOKING DYNAMIC (NO ERROR VERSION)
                      homeData?.continueBooking != null &&
                      homeData!.continueBooking!.show
                      ? Column(
                        children: [

                          Padding(
                            padding:  AppSpacing.insetsHXl,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Continue Your Booking",
                                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.white, height: 1.2),


                                ),

                              ],
                            ),
                          ),

                            // const SizedBox(height: 10),
                          Container(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                                margin: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(AppRadii.massive),
                                ),
                                child: Column(
                                  children: [

                                    /// TOP ROW
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: AppRadii.hugeAll,
                                          child: (homeData.continueBooking?.imageUrl != null &&
                                              homeData.continueBooking!.imageUrl!.trim().isNotEmpty)
                                              ? CachedNetworkImage(
                                            imageUrl: ApiEndpoints.imageUrl +
                                                homeData.continueBooking!.imageUrl!,
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.cover,

                                            /// 🔥 First time loader only
                                            placeholder: (context, url) => const SizedBox(
                                              height: 80,
                                              width: 80,
                                              child: Center(
                                                child: AppLoader(),
                                              ),
                                            ),

                                            /// ❌ Error
                                            errorWidget: (context, url, error) => SvgPicture.asset(
                                              AppAssets.imagePlaceholder,
                                              height: 80,
                                              width: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                              : SvgPicture.asset(
                                            AppAssets.imagePlaceholder,
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),


                                        const SizedBox(width: 15),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                          homeData.continueBooking!.currentScreenLabel,
                          style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                                              ),

                                              const SizedBox(height: 4),

                                              Text(
                          "Step ${homeData.continueBooking!.currentScreenOrder} of ${homeData.continueBooking!.totalSteps}",
                          style: const TextStyle(
                            color: AppColors.black70,
                            fontSize: 13,
                          ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    /*/// PROGRESS
                                    LinearProgressIndicator(
                                      value: homeData!.continueBooking!.progress ?? 0.0,
                                    ),*/
                                    Row(
                                      children: List.generate(3, (index) {
                                        double progress =
                                            homeData.continueBooking?.progress ?? 0.0; // 0 to 1

                                        double segmentProgress = (progress * 3) - index;

                                        /// clamp between 0 to 1
                                        double value = segmentProgress.clamp(0.0, 1.0);

                                        return Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: AppColors.black.withValues(alpha: 0.2), // background (light)
                                              borderRadius: BorderRadius.circular(AppRadii.mld),
                                            ),
                                            child: FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: value, // 🔥 main logic
                                              child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.black, // filled part
                            borderRadius: BorderRadius.circular(AppRadii.mld),
                          ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 20),

                                    /// 🔥 RESUME BUTTON
                                    GestureDetector(
                                      onTap: () {
                                        handleResume(homeData.continueBooking!);
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppColors.textHeading, //
                                          borderRadius: BorderRadius.circular(AppRadii.massive),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                          Text(
                                          "Resume",
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: AppAssets.fontUnbounded,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Icon(
                                          Icons.arrow_forward,
                                          color: AppColors.primary,
                                          size: 24,
                                        ),]),)
                                    ),
                                  ],
                                ),
                              ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.smd),
                            child: Container(
                              height: 1,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.white.withValues(alpha: 0.09), // left
                                    AppColors.white24,
                                    AppColors.white.withValues(alpha: 0.09), // right
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
        : const SizedBox(),
                        ],
                      ),
                      // const SizedBox(height: 10),

                      const SizedBox(height: 10),
                      Padding(
                        key: featuredKey,
                        padding: const AppSpacing.insetsHXl,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Featured Creatives",
                              style: AppTextStyles.labelLarge.copyWith(
                                fontFamily: AppAssets.fontUnbounded,
                                color: AppColors.white,
                                height: 1.2,
                              ),

                            ),

                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        // color: AppColors.error,
                        child: SizedBox(
                          height: 280,
                          child: AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, child) {
                              return PageView.builder(
                                controller: _pageController,
                                clipBehavior: Clip.none,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final int actualIndex = index %
                                      featuredImages.length;

                                  double page = _pageController.hasClients
                                      ? _pageController.page ??
                                      _initialPage.toDouble()
                                      : _initialPage.toDouble();

                                  double difference = (index - page);


                                  double perspective = 0.0022;

                                  double rotation = difference *
                                      0.8; //
                                  rotation = rotation.clamp(-0.8, 0.9);

                                  // 3. Scale & Opacity
                                  double scale = (1 - (difference.abs() * 0.10))
                                      .clamp(0.0, 1.0);
                                  double opacity = (1 - (difference.abs() * 0.10))
                                      .clamp(0.6, 2.0);

                                  double translateX = difference * -100;

                                  return Opacity(
                                    opacity: opacity,
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, perspective) // 3D depth
                                        ..translate(translateX) // Paas lane ke liye
                                        ..rotateY(
                                            rotation) //
                                        ..scale(scale), // Chota karne ke liye
                                      child: teamCard(
                                        image: featuredImages[actualIndex],
                                        name: featuredNames[actualIndex],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },

                          ),
                        ),
                      ),

                      Stack(
                        alignment: Alignment.center,

                        children: [
                          CustomPaint(
                            size: Size(MediaQuery
                                .of(context)
                                .size
                                .width, 70),
                            painter: BeveledTrayPainter(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.md), // Bevel height jitna ya thoda zyada

                            child: AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                // Current page calculate karne ke liye (Looping ke liye modulo use kiya hai)
                                double page = 0;
                                if (_pageController.hasClients) {
                                  page =
                                      _pageController.page ?? _initialPage.toDouble();
                                } else {
                                  page = _initialPage.toDouble();
                                }
                                int activeIndex = page.round() %
                                    featuredImages.length;

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(featuredImages.length, (
                                      index) {
                                    bool isActive = index == activeIndex;
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 400),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      height: 7,
                                      width: 7,
                                      // Round dots ke liye height/width same rakhi hai
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        // Active dot beige hai, baki dark grey
                                        color: isActive
                                            ? AppColors.primary
                                            : AppColors.white.withValues(alpha: 0.2),
                                        boxShadow: isActive ? [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.4),
                                            blurRadius: 4,
                                          )
                                        ] : [],
                                      ),
                                    );
                                  }),
                                );
                              },
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
                                AppColors.white24,
                                AppColors.white.withValues(alpha: 0.09), // right
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: BorderAnimationPainter(_controller.value),
                            child: child,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: 69, left: AppSpacing.base, right: AppSpacing.base),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              // Stops ko correct kiya hai smooth look ke liye
                              stops: const [0.0, 0.7],
                              colors: [
                                AppColors.primary,
                                AppColors.surfaceDark,
                              ],
                            ),
                            borderRadius: AppRadii.pillAll,
                          ),
                          child: Column(
                            children: [

                              Transform.translate(
                                offset: Offset(0, 10),
                                child: const Text(
                                  "Beige Studios",

                                  style: TextStyle(
                                    color: AppColors.black16,
                                    fontSize: 35,
                                    fontWeight: FontWeight.w500, // Extra Bold look
                                    fontFamily: AppAssets.fontUnbounded,
                                  ),),
                              ),


                              // Carousel Section
                              Align(
                                alignment: Alignment.topCenter,
                                child: SizedBox(
                                  height: 330,
                                  child: PageView.builder(
                                    controller: _studioController, //
                                    clipBehavior: Clip.none,
                                    onPageChanged: (i) => setState(() => _activeStudioIndex = i % studioList.length),
                                    itemBuilder: (context, index) {
                                      final int actualIndex = index % studioList.length;
                                      return AnimatedBuilder(
                                        animation: _studioController,
                                        builder: (context, child) {
                                          double scale = 1.0;
                                          double translate = 0;

                                          if (_studioController.position.haveDimensions) {
                                            double page = _studioController.page!;
                                            double diff = (index - page);
                                            // Scale logic for smooth effect
                                            scale = (1 - (diff.abs() * 0.15)).clamp(0.8, 1.0);
                                            translate = diff.abs() * 10;
                                          } else {
                                            // Initial state for first build
                                            if(index != 0) scale = 0.85;
                                          }

                                          return Center(
                                            child: Transform.translate(
                                              offset: Offset(0, translate),
                                              child: Transform.scale(
                                                scale: scale,
                                                child: _buildStudioCard(studioList[actualIndex]),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Studio Info
                              Text(
                                studioList[_activeStudioIndex]['name']!,
                                style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                ),
                              ),

                              // Agar address ya description hai to:
                              if(studioList[_activeStudioIndex]['desc'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                                  child: Text(
                                    studioList[_activeStudioIndex]['desc']!,
                                    style: TextStyle(color: AppColors.white.withValues(alpha: 0.7), fontSize: 13),
                                  ),
                                ),

                              const SizedBox(height: 25),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.smd),
                                child: Container(
                                  height: 1,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.white.withValues(alpha: 0.09), // left
                                        AppColors.white24,
                                        AppColors.white.withValues(alpha: 0.09), // right
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Custom Page Indicator
                              Center(
                                child: Container(
                                  width: 60,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppRadii.mld),
                                  ),
                                  child: Stack(
                                    children: [
                                      AnimatedPositioned(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        // Indicator smooth move hoga
                                        left: (_activeStudioIndex * (60 / studioList.length)),
                                        child: Container(
                                          width: 60 / studioList.length,
                                          height: 9,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(AppRadii.mld),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.smd),
                        child: Container(
                          height: 1,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.white.withValues(alpha: 0.09), // left
                                AppColors.white24,
                                AppColors.white.withValues(alpha: 0.09), // right
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // --- YOUR BOOKINGS SECTION (STACK SWIPE UI) ---
                      Padding(
                        padding: const AppSpacing.insetsHXl,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Your Bookings",
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppAssets.fontUnbounded,
                              ),
                            ),
                            /*SvgPicture.asset(
                              AppAssets.chevronRight,
                            ),*/
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

          /*            GestureDetector(
                        onTap: () {
                          if (!_bookingSwipeController.isAnimating) {
                            _bookingSwipeController.forward().then((_) {
                              setState(() {
                                _currentBookingIndex = (_currentBookingIndex + 1) % bookingList.length;
                                _bookingSwipeController.reset();
                              });
                            });
                          }
                        },
                        onHorizontalDragEnd: (details) {
                          if (_bookingSwipeController.isAnimating) return;
                          if (details.primaryVelocity! < 0) { // Left Swipe
                            _bookingSwipeController.forward().then((_) {
                              setState(() {
                                _currentBookingIndex = (_currentBookingIndex + 1) % bookingList.length;
                                _bookingSwipeController.reset();
                              });
                            });
                          }
                        },
                        child: SizedBox(
                          height: 408,
                          child: AnimatedBuilder(
                            animation: _bookingSwipeController,
                            builder: (context, child) {
                              double val = _bookingSwipeController.value;

                              // Front Card Animations
                              double frontSlide = val * 300; // Niche ki taraf jayega
                              double frontOpacity = 1 - val;

                              // Back Card Animations (Ye piche se aage aayega)
                              double backOffsetX = 20 * (1 - val);  // 20 se 0 tak
                              double backOffsetY = -20 * (1 - val); // -20 se 0 tak
                              double backScale = 0.96 + (0.04 * val); // 0.96 se 1.0 tak
                              double backRotate = 0.08 * (1 - val); // 0.08 se 0 tak

                              return Stack(
                                clipBehavior:  Clip.antiAlias,
                                alignment: Alignment.center,
                                children: [
                                  /// 🔹 BACK CARD (Jo ab aage aa raha hai)
                                  Transform.translate(
                                    offset: Offset(backOffsetX, backOffsetY),
                                    child: Transform.rotate(
                                      angle: backRotate,
                                      child: Transform.scale(
                                        scale: backScale,
                                        child: Opacity(
                                          // Back card ki opacity transition ke waqt badh jayegi
                                          opacity: 0.5 + (0.5 * val),
                                          child: _buildBookingCard(
                                            (_currentBookingIndex + 1) % bookingList.length,
                                            isBackCard: val < 0.5, // Jab tak aadha transition na ho, details chhupao
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  /// 🔥 MAIN CARD (Jo slide hokar ja raha hai)
                                  Transform.translate(
                                    offset: Offset(0, frontSlide),
                                    child: Opacity(
                                      opacity: frontOpacity,
                                      child: _buildBookingCard(
                                        _currentBookingIndex % bookingList.length,
                                        isBackCard: false,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),*/


    Column(
      children: [
        bookingList.isEmpty

            ?
        SizedBox(
      height: 160,
      child: _buildEmptyBookingCard(),
    )
            :
        GestureDetector(
          onTap: () {
            if (!_bookingSwipeController.isAnimating && bookingList.isNotEmpty) {
              _bookingSwipeController.forward().then((_) {
                setState(() {
                  _currentBookingIndex =
                      (_currentBookingIndex + 1) % bookingList.length;
                  _bookingSwipeController.reset();
                });
              });
            }
          },

          onHorizontalDragEnd: (details) {
            if (_bookingSwipeController.isAnimating || bookingList.isEmpty) return;

            if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
              _bookingSwipeController.forward().then((_) {
                setState(() {
                  _currentBookingIndex =
                      (_currentBookingIndex + 1) % bookingList.length;
                  _bookingSwipeController.reset();
                });
              });
            }
          },

          child: SizedBox(
            height: 408,
            child: AnimatedBuilder(
              animation: _bookingSwipeController,
              builder: (context, child) {

                /// 🔥 SAFE VALUE (NaN avoid)
                double val = _bookingSwipeController.value;
                if (val.isNaN) val = 0.0;

                // Front Card
                double frontSlide = val * 300;
                double frontOpacity = 1 - val;

                // Back Card
                double backOffsetX = 20 * (1 - val);
                double backOffsetY = -20 * (1 - val);
                double backScale = 0.96 + (0.04 * val);
                double backRotate = 0.08 * (1 - val);

                /// 🔥 SAFE INDEX
                int currentIndex =
                    _currentBookingIndex % bookingList.length;

                int nextIndex =
                    (_currentBookingIndex + 1) % bookingList.length;

                return Stack(
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  children: [

                    /// 🔹 BACK CARD
                    Transform.translate(
                      offset: Offset(backOffsetX, backOffsetY),
                      child: Transform.rotate(
                        angle: backRotate,
                        child: Transform.scale(
                          scale: backScale,
                          child: Opacity(
                            opacity: 0.5 + (0.5 * val),
                            child: _buildBookingCard(
                              nextIndex,
                              isBackCard: val < 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// 🔥 FRONT CARD
                    Transform.translate(
                      offset: Offset(0, frontSlide),
                      child: Opacity(
                        opacity: frontOpacity,
                        child: _buildBookingCard(
                          currentIndex,
                          isBackCard: false,
                        ),
                      ),
                    ),
                  ],
                );
              },
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
                      const SizedBox(height: 20),
                      Padding(
                        padding: const AppSpacing.insetsHXl,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "We Think You’ll Love These ",
                              style: AppTextStyles.titleSmall.copyWith(color: AppColors.white, height: 1.2),)


                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      (homeData?.featuredCreatives ?? []).isEmpty
                          ? SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            "No Data Found",
                              style:
                              AppTextStyles.titleSmall.copyWith(color: AppColors.primary)
                          ),
                        ),
                      )
                          :  SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: homeData?.featuredCreatives.length ?? 0,
                          itemBuilder: (context, index) {
                            final data = homeData!.featuredCreatives[index];
                            /*  final item = featuredCreatives[index];
                        final int userId = item["id"];
                        bool isFavourite = favouriteUsers.contains(userId);*/
                            return Padding(
                              padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.xxs),
                              child: Container(
                                width: 210,
                                height: 280,
                                clipBehavior: Clip.none, // Ensures child contents don't bleed out of corners
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppRadii.massive),
                                ),
                                child: Stack(
                                  children: [
                                    /// 1. FULL BACKGROUND IMAGE
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(AppRadii.massive),
                                        child: data.profileImage.isNotEmpty
                                            ? Image.network(
                                          ApiEndpoints.imageUrl + data.profileImage,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Center(
                                              child: Container(

                                                child: Center(child: SvgPicture.asset(AppAssets.imagePlaceholder, fit: BoxFit.cover,)),
                                              ),
                                            );
                                          },
                                        )
                                            : SvgPicture.asset(AppAssets.imagePlaceholder, fit: BoxFit.cover),
                                      ),
                                    ),

                                    /// 2. BOTTOM GRADIENT (The "Black Blur" effect for text readability)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(AppRadii.massive),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            stops: const [0.4, 1.0], // Starts getting dark near the middle/bottom
                                            colors: [
                                              AppColors.transparent,
                                              AppColors.black
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),



                                    /// 5. BOTTOM CONTENT (Text & Buttons)
                                    Positioned(
                                      bottom: 15,
                                      left: 12,
                                      right: 12,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            data.name,
                                            style: const TextStyle(
                                              color: AppColors.white,
                                              fontSize: 12,
                                              fontFamily: AppAssets.fontHelveticaNeue,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            data.title ?? "Creative Professional",
                                            style: const TextStyle(
                                              color: AppColors.white70,
                                              fontSize: 10,
                                              fontFamily: AppAssets.fontHelveticaNeue,
                                              fontWeight: FontWeight.w400,

                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [

                                              /// 🔥 VIEW PROFILE BUTTON (FULL WIDTH)
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    context.pushNamed(
                                                      RouteNames.recommendedDetails,
                                                      pathParameters: {'id': data.id.toString()},
                                                      queryParameters: {'bookingId': '121'},
                                                    );
                                                  },
                                                  child: Container(
                                                    height: 35,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary,
                                                      borderRadius: AppRadii.pillSmAll,
                                                    ),
                                                    child: const Text(
                                                      "View Profile",
                                                      style: TextStyle(
                                                        color: AppColors.black,
                                                        fontFamily: AppAssets.fontHelveticaNeue,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(width: 10),

                                              /// 🔥 ICON BUTTON (PERFECT CIRCLE)
                                              SizedBox(
                                                height: 38,
                                                width: 38,

                                                child: Center(
                                                  child: SvgPicture.asset(
                                                    AppAssets.homeViewProfile,
                                                    height: 36,
                                                    color: AppColors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
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
                      const SizedBox(height: 10),
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
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
                                                      // Aapka beige color
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
                      // --- RECENT PROJECT SECTION ---
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.smd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "How It Works",
                              style: AppTextStyles.titleSmall.copyWith(color: AppColors.white, height: 1.2),
                            ),
                            const SizedBox(height: 15),

                            /// 🔥 MAIN CARD
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                              decoration: BoxDecoration(
                                color: AppColors.primary, // updated beige color
                                borderRadius: BorderRadius.circular(AppRadii.massive),
                              ),
                              child: Stack(
                                children: [
                                  /// 🔥 Vertical Line
                                  Positioned(
                                    left: 40,
                                    top: 20,
                                    bottom: 20,
                                    child: Container(
                                      width: 1,
                                      color: AppColors.black26,
                                    ),
                                  ),

                                  /// 🔥 Timeline Items
                                  Column(
                                    children: [
                                      _buildItem(
                                        AppAssets.aiMatchmaking,
                                        "AI Matchmaking",
                                        "The right creative. Every time.",
                                      ),
                                      _buildItem(
                                        AppAssets.aiMatchmakingAlt,
                                        "Pre-Production",
                                        "Zero back-and-forth. Full clarity.",
                                      ),
                                      _buildItem(
                                        AppAssets.production,
                                        "Production",
                                        "Show up. Shoot. Done.",
                                      ),
                                      _buildItem(
                                        AppAssets.aiPostProduction,
                                        "AI-Powered Post-Production",
                                        "Edited, optimized, and ready to ship.",
                                      ),
                                    ],
                                  ),

                                  /// 🔥 Left side dots
                                  Positioned(
                                    left: -10,
                                    top: 60,
                                    child: _sideDot(),
                                  ),
                                  Positioned(
                                    left: -10,
                                    top: 140,
                                    child: _sideDot(),
                                  ),
                                  Positioned(
                                    left: -10,
                                    top: 220,
                                    child: _sideDot(),
                                  ),

                                  /// 🔥 Right side dots
                                  Positioned(
                                    right: -10,
                                    top: 60,
                                    child: _sideDot(),
                                  ),
                                  Positioned(
                                    right: -10,
                                    top: 140,
                                    child: _sideDot(),
                                  ),
                                  Positioned(
                                    right: -10,
                                    top: 220,
                                    child: _sideDot(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Top ",
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppAssets.fontUnbounded,
                                  ),
                                ),

                       /*         Expanded(
                                  child: Container(
                                    color: AppColors.success,
                                    child: AnimatedBuilder(
                                      animation: _controller,
                                      builder: (context, child) {
                                        double value = _controller.value;

                                        int currentIndex =
                                            (value * words.length).floor() % words.length;

                                        int nextIndex = (currentIndex + 1) % words.length;

                                        double transition = (value * words.length) % 1;

                                        const double textHeight = 36;

                                        return SizedBox(
                                          height: textHeight, // ✅ FIX
                                          child: ClipRect(
                                            child: Transform.translate(
                                              offset: Offset(0, -transition * textHeight),
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: textHeight,
                                                    child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text(
                                                        words[currentIndex],
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          color: AppColors.white,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w500,
                                                          fontFamily: AppAssets.fontUnbounded,
                                                          height: 1.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: textHeight,
                                                    child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text(
                                                        words[nextIndex],
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          color: AppColors.white,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w500,
                                                          fontFamily: AppAssets.fontUnbounded,
                                                          height: 1.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )*/

                                AnimatedBuilder(
                                  animation: _controller,
                                  builder: (context, child) {
                                    double value = _controller.value; // ✅ FIX: value define kiya

                                    int index = (value * words.length).floor() % words.length;

                                    return AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 500), // thoda smooth
                                      transitionBuilder: (child, animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, 0.3),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        words[index],
                                        key: ValueKey<int>(index), // ✅ important for animation
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: AppAssets.fontUnbounded,
                                          height: 1.0,
                                        ),),
                                    );
                                  },
                                )
                              ],
                            ),
                            const SizedBox(height: 15),


                            SizedBox(
                              height: 340,
                              child: PageView.builder(
                                controller: _featuredController,
                                itemCount: 10000,
                                clipBehavior: Clip.none,
                                itemBuilder: (context, index) {

                                  final realIndex = index % Topwords.length;

                                  return AnimatedBuilder(
                                    animation: _featuredController,
                                    builder: (context, child) {

                                      double value = 0;
                                      if (_featuredController.position.haveDimensions) {
                                        value = index - (_featuredController.page ?? 0);
                                      }

                                      final double perspective = 0.0015;

                                      double rotationValue = value.clamp(-1.0, 1.0);
                                      double angle = rotationValue * -0.6;

                                      double scale = (1 - (value.abs() * 0.15)).clamp(0.8, 1.0);

                                      return Transform(
                                        alignment: value < 0
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        transform: Matrix4.identity()
                                          ..setEntry(3, 2, perspective)
                                          ..rotateY(angle)
                                          ..scale(scale),
                                        child: Opacity(
                                          opacity: (1 - (value.abs() * 0.7)).clamp(0.4, 1.0),

                                          child: Center(
                                            child: SizedBox(
                                              width: 280, // 🔥 IMPORTANT
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min, // 🔥 FIX 1

                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [

                                                  /// IMAGE
                                                  Container(
                                                    height: 240,
                                                    width: 230,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(AppRadii.massive),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: AppColors.black.withValues(alpha: 0.4),
                                                          blurRadius: 15,
                                                          offset: const Offset(0, 10),
                                                        ),
                                                      ],
                                                      image: DecorationImage(
                                                        image: AssetImage(Topwords[realIndex]),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(height: 8),

                                                  /// NAME
                                                  Column(
                                                    children: [
                                                      Text(
                                                        Topname[realIndex],
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(
                                                          color: AppColors.white,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                          fontFamily: AppAssets.fontOutfit,
                                                        ),
                                                      ),

                                                      const SizedBox(height: 8),

                                                      /// SOCIAL ICONS
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [

                                                          /// INSTAGRAM
                                                          if (Topinstagram[realIndex].isNotEmpty &&
                                                              instaFollowers[realIndex] != "-")
                                                            GestureDetector(
                                                              onTap: () => openLink(Topinstagram[realIndex]),
                                                              child: Row(
                                                                children: [
                                                                  SvgPicture.asset(AppAssets.instagram),
                                                                  const SizedBox(width: 4),
                                                                  Text(
                                                                    instaFollowers[realIndex],
                                                                    style: const TextStyle(
                                                                      color: AppColors.white,
                                                                      fontSize: 13,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                          /// spacing only if visible
                                                          if (Topinstagram[realIndex].isNotEmpty &&
                                                              instaFollowers[realIndex] != "-")
                                                            const SizedBox(width: 18),

                                                          /// YOUTUBE
                                                          if (Topyoutube[realIndex].isNotEmpty &&
                                                              youtubeFollowers[realIndex] != "-")
                                                            GestureDetector(
                                                              onTap: () => openLink(Topyoutube[realIndex]),
                                                              child: Row(
                                                                children: [
                                                                  SvgPicture.asset(AppAssets.youtube),
                                                                  const SizedBox(width: 4),
                                                                  Text(
                                                                    youtubeFollowers[realIndex],
                                                                    style: const TextStyle(
                                                                      color: AppColors.white,
                                                                      fontSize: 13,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                          if (Topyoutube[realIndex].isNotEmpty &&
                                                              youtubeFollowers[realIndex] != "-")
                                                            const SizedBox(width: 18),

                                                          /// TIKTOK
                                                          if (Toptiktok[realIndex].isNotEmpty &&
                                                              tiktokFollowers[realIndex] != "-")
                                                            GestureDetector(
                                                              onTap: () => openLink(Toptiktok[realIndex]),
                                                              child: Row(
                                                                children: [
                                                                  SvgPicture.asset(AppAssets.tiktok),
                                                                  const SizedBox(width: 4),
                                                                  Text(
                                                                    tiktokFollowers[realIndex],
                                                                    style: const TextStyle(
                                                                      color: AppColors.white,
                                                                      fontSize: 13,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                        ],
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

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
                      const SizedBox(height: 20),

                      // --- Top Creatives Section ---
                      Padding(
                        key: topCreativeKey,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Top Creatives Near you",
                              style: AppTextStyles.titleSmall.copyWith(color: AppColors.white, height: 1.2),
                            ),
                            const SizedBox(height: 10),
                            // AB YE CALL KAREIN:
                            _buildTopCreativesStack(context),

                          ],
                        ),
                      ),

                    ]
                )
              ],
            ),


          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
    );
  }
  Widget _buildEmptyBookingCard() {
    return Container(
      height: 180,
      margin: const AppSpacing.insetsHXl,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.massive),
         border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [

          /// 🔥 BACKGROUND IMAGE
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.massive),
              child: Image.asset(
                AppAssets.homeCardBg, // 👈 BG IMAGE
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// 🔥 DARK OVERLAY (for text visibility)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppRadii.hugeAll,
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.black.withValues(alpha: 0.7),
                    AppColors.black.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          ),

          /// 🔹 TEXT CONTENT
          Positioned(
            left: 16,
            top: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Text(
                  "No Shoots Yet",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontFamily: AppAssets.fontHelveticaNeue,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Book Your First Shoot To\nGet Started.",
                  style: TextStyle(
                    fontFamily: AppAssets.fontHelveticaNeue,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),

SizedBox(height: 10,),
                /// 🔥 BUTTON
                GestureDetector(
                  onTap: () {
                    context.pushNamed(RouteNames.contentType, extra: {'fromHome': true});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadii.smAll,
                    ),
                    child: const Text(
                      "Book a Shoot",
                      style: TextStyle(
                        fontFamily: AppAssets.fontUnbounded,
                        color: AppColors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 🔥 RIGHT IMAGE (FLOATING 🔥)
          Positioned(
            right: 8,   // 👈 thoda bahar nikle
            bottom: 6,
            // 👈 niche se thoda cut
            child: Image.asset(
              AppAssets.yourBookings,
              height: 170, // 👈 bigger = premium look
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCardbook(Map<String, String> data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),

      decoration: BoxDecoration(
        borderRadius: AppRadii.roundAll,

        /// ✅ FIGMA BORDER
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.05), // 🔥 5% white
          width: 0.5, // 🔥 exact figma
        ),


      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.massive),
        child: Stack(
          children: [

            /// BACKGROUND
            Image.asset(
              data["bg"]!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),



            /// RIGHT IMAGE
            Positioned(
              right: -7,
              bottom: 0,
              top: 0,
              child: Image.asset(
                data["image"]!,
                fit: BoxFit.fill,

              ),
            ),

            /// TEXT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.base), // 🔥 increased
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data["title"]!,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppAssets.fontHelveticaNeue,
                    ),
                  ),
                  const SizedBox(height: 14),

                  /// BUTTON
                  GestureDetector(
                    onTap: () {
                      if (data["button"] == "Book a Shoot") {
                        context.pushNamed(RouteNames.contentType, extra: {'fromHome': true});
                      } else if (data["button"] == " Explore Creatives") {
                        scrollTo(featuredKey);
                      } else if (data["button"] == "Find Your Creative") {
                        scrollTo(topCreativeKey);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mld, vertical: AppSpacing.smd), // 🔥 better button size
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadii.mdAll,
                      ),
                      child: Text(
                        data["button"]!,
                        style: TextStyle(
                          color: AppColors.textHeading,
                          fontFamily: AppAssets.fontUnbounded,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildBookingCard(int index, {bool isBackCard = false}) {
    final booking = bookingList[index % bookingList.length];

    return Container(
      height: 360, // 🔥 fix height (important)
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.huge),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadii.roundAll,
        border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 IMAGE
          ClipRRect(
            borderRadius: AppRadii.hugeAll,
            child: booking.imageUrl != null && booking.imageUrl!.isNotEmpty
                ? Image.network(
              ApiEndpoints.imageUrl + booking.imageUrl!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Container(
              height: 160,
              width: double.infinity,
              color: AppColors.surfaceVariant,
            ),
          ),

          /// 🔹 DETAILS
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isBackCard ? 0.0 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                Text(
                  booking.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontFamily: AppAssets.fontHelveticaNeue,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                /// 🔸 Divider
                Container(
                  height: 1,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.white.withValues(alpha: 0.05),
                        AppColors.white24,
                        AppColors.white.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                /// 🔸 Date
                Row(
                  children: [
                    SvgPicture.asset(
                      AppAssets.calendarDate,
                      color: AppColors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatDate(booking.eventDate),

                      style: const TextStyle(color: AppColors.white, fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                /// 🔸 Time
                Row(
                  children: [
                    SvgPicture.asset(
                      AppAssets.clock,
                      color: AppColors.white,

                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${formatTime(booking.startTime)} - ${formatTime(booking.endTime)}",

                      style: const TextStyle(color: AppColors.white, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 1,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.white.withValues(alpha: 0.05),
                        AppColors.white24,
                        AppColors.white.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 🔥 PUSH BUTTON DOWN
          const Spacer(),

          /// 🔥 BUTTON
          if (!isBackCard)
            Row(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final statusColor =
                      getStatusColorFromLabel(booking.statusLabel);

                      return Container(
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadii.massive),
                          border: Border.all(color: statusColor),
                          color: statusColor.withValues(alpha: 0.15),
                        ),
                        child: Center(
                          child: Text(
                            booking.statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),

                /// 🔹 ICON BUTTON
          /*      SvgPicture.asset(
                  AppAssets.homeViewProfile,
                  height: 36,
                  color: AppColors.white,
                ),*/
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSmallCircleBtn(String svgPath) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        svgPath,
        height: 18,
        width: 18,
        color: AppColors.white, // optional (remove if original color chahiye)
      ),
    );
  }


  Widget _buildServiceCard(
      int index, String title, String imagePath) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });

        playBorderAnimationOnce();

        if (title == "Photo") {
          _continueBooking(2);
        } else if (title == "Video") {
          _continueBooking(1);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$title Coming Soon"),
              duration: const Duration(seconds: 1), // ✅ 1 sec
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: isSelected ? 1.05 : 1.0,
              child: Container(
                width: 90,
                padding: const EdgeInsets.all(AppSpacing.hairline),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.xxl),

                  /// ✅ ONE TIME ROTATION FIXED
                  gradient: isSelected
                      ? SweepGradient(
                    transform: GradientRotation(
                      _controller.value * 2 * 3.1416, // 🔥 FIXED
                    ),
                    colors: [
                      AppColors.transparent,
                      AppColors.primary.withValues(alpha: 0.4),
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.4),
                      AppColors.transparent,
                    ],
                  )
                      : null,

                  border: isSelected
                      ? null
                      : Border.all(
                    color: AppColors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadii.xxl),
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        imagePath,
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.white.withValues(alpha: 0.6),
                          fontSize: 10,
                          fontFamily: AppAssets.fontOutfit,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  void playBorderAnimationOnce() {
    _controller.reset();
    _controller.forward(); // only once
  }
  Widget _buildStudioCard(Map<String, String> data) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        // color: AppColors.warning,
        // margin: const EdgeInsets.symmetric(horizontal: AppSpacing.smd),

        child: Stack(
          children: [
            // Background Image
            ClipRRect(
              borderRadius: AppRadii.roundAll,
              child: Image.asset(data['image']!, fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget teamCard({
    required String image,
    required String name,
  }) {
    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,

            height: 212,
            width: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.massive),
              /* boxShadow: [
                BoxShadow(
                  // color: AppColors.black.withOpacity(0.45),
                  blurRadius: 12,
                  // offset: const Offset(0, 10),
                ),
              ],*/
            ),
            child: ClipRRect(
              borderRadius: AppRadii.hugeAll,
              child: Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontFamily: AppAssets.fontOutfit,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCreativesStack(BuildContext context) {
    final list = homeData?.mainCreatives ?? [];

    /// ✅ 🔥 NO DATA HANDLE
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(height: 10),
            Text(
              "No Creatives Found",
                style:
                AppTextStyles.titleSmall.copyWith(color: AppColors.primary)
            ),
          ],
        ),
      );
    }

    return GestureDetector(
  /*    onTap: () {
        if (_swipeController.isAnimating) return;

        _swipeController.forward().then((_) {
          setState(() {
            _currentCreativeIndex =
                (_currentCreativeIndex + 1) % list.length;
            _swipeController.reset();
          });
        });
      },*/

      onHorizontalDragEnd: (details) {
        if (_swipeController.isAnimating) return;

        if (details.primaryVelocity == null) return;

        /// 👉 LEFT
        if (details.primaryVelocity! < 0) {
          _swipeController.forward().then((_) {
            setState(() {
              _currentCreativeIndex =
                  (_currentCreativeIndex + 1) % list.length;
              _swipeController.reset();
            });
          });
        }

        /// 👉 RIGHT
        else if (details.primaryVelocity! > 0) {
          _swipeController.forward().then((_) {
            setState(() {
              _currentCreativeIndex =
                  (_currentCreativeIndex - 1 + list.length) % list.length;
              _swipeController.reset();
            });
          });
        }
      },

      child: SizedBox(
        height: 480,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _swipeController,
          builder: (context, child) {
            double slide = _swipeController.value * MediaQuery.of(context).size.width;
            double rotate = _swipeController.value * 0.15;
            double opacity = 1 - _swipeController.value;

            return ClipRect(
              child: Stack(
                alignment: Alignment.center,
                children: [

                  /// 🔹 BACK CARD
                  Transform.translate(
                    offset: const Offset(0, -45),
                    child: Transform.rotate(
                      angle: 0.06,
                      child: Transform.scale(
                        scale: 0.88,
                        child: Opacity(
                          opacity: 0.3,
                          child: IgnorePointer(
                            child: _buildCreativeCard(
                              list.isEmpty
                                  ? 0
                                  : (_currentCreativeIndex + 2) % list.length,
                              isBackground: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// 🔹 MIDDLE CARD
                  Transform.translate(
                    offset: const Offset(0, -25),
                    child: Transform.rotate(
                      angle: -0.04,
                      child: Transform.scale(
                        scale: 0.94,
                        child: Opacity(
                          opacity: 0.6,
                          child: IgnorePointer(
                            child: _buildCreativeCard(
                              list.isEmpty
                                  ? 0
                                  : (_currentCreativeIndex + 1) % list.length,
                              isBackground: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// 🔹 FRONT CARD
                  Transform.translate(
                    offset: Offset(0, slide),
                    child: Transform.rotate(
                      angle: rotate,
                      child: Opacity(
                        opacity: opacity,
                        child: _buildCreativeCard(
                          list.isEmpty
                              ? 0
                              : _currentCreativeIndex % list.length,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _buildCreativeCard(int index, {bool isBackground = false}) {
    final item = homeData!.mainCreatives[index];
    final String imageUrl = item.profileImage;

    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.white36, width: 0.5),
        borderRadius: AppRadii.pillSmAll,
        image: (imageUrl.isNotEmpty)
            ? DecorationImage(
          image: NetworkImage(ApiEndpoints.imageUrl + imageUrl),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: ClipRRect(
        borderRadius: AppRadii.pillSmAll,
        child: Stack(
          children: [

            /// ❌ Background cards me placeholder bhi nahi
            if (!isBackground && (imageUrl.isEmpty))
              Center(
                child: SvgPicture.asset(
                  AppAssets.imagePlaceholder,
                  height: 80,
                  width: 80,
                ),
              ),

            /// Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomCenter,
                    stops: const [0.3, 0.9],
                    colors: [
                      AppColors.black.withValues(alpha: isBackground ? 0.4 : 0.1),
                      AppColors.black.withValues(alpha: isBackground ? 0.9 : 0.85),
                    ],
                  ),
                ),
              ),
            ),

            /// ❌ IMPORTANT: Background me text hide
            if (!isBackground)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppAssets.fontUnbounded,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title ?? "Creative Professional",
                      style: const TextStyle(
                        color: AppColors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 25),

                    GestureDetector(
                      onTap: () {
                        context.pushNamed(
                          RouteNames.recommendedDetails,
                          pathParameters: {'id': item.id.toString()},
                          queryParameters: {'bookingId': '121'},
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppRadii.pillAll,
                        ),
                        child: const Text(
                          "View Profile",
                          style: TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Widget _buildItem(String imagePath, String title, String subtitle) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.base),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔥 Circle Background
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(

          ),

          /// 🔥 Center + Padding like CSS
          child: Center(
            child: Container(


              child: SvgPicture.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        const SizedBox(width: 15),

        /// 🔥 Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                  fontFamily: AppAssets.fontHelveticaNeue,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  fontFamily: AppAssets.fontHelveticaNeue,
                  color: AppColors.backgroundOpacity70,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
Widget _sideDot() {
  return Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: AppRadii.pillAll,
    ),
  );
}


class BeveledTrayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;

    // Dimensions (Aap inhe adjust kar sakte hain)
    double bevelHeight = 12; // Kitna neeche jayega
    double slopeWidth = 15;  // Tirchi line ki width
    double shoulderWidth = w * 0.18; // Side ki strips ki width

    // Main Path define karna
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(shoulderWidth, 0);
    path.lineTo(shoulderWidth + slopeWidth, bevelHeight);
    path.lineTo(w - shoulderWidth - slopeWidth, bevelHeight);
    path.lineTo(w - shoulderWidth, 0);
    path.lineTo(w, 0);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    // 1. Background Base Color (Dark Gradient)
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.background, AppColors.surfaceGradientDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, paint);

    // 2. Vertical Side Shadows (Depth create karne ke liye)
    // Left Wall Shadow
    final leftWallPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.black.withValues(alpha: 0.6), AppColors.transparent],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(shoulderWidth, 0, slopeWidth, h));

    Path leftWallPath = Path()
      ..moveTo(shoulderWidth, 0)
      ..lineTo(shoulderWidth + slopeWidth, bevelHeight)
      ..lineTo(shoulderWidth + slopeWidth, h)
      ..lineTo(shoulderWidth, h)
      ..close();
    canvas.drawPath(leftWallPath, leftWallPaint);

    // Right Wall Shadow
    final rightWallPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.transparent, AppColors.black.withValues(alpha: 0.6)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(w - shoulderWidth - slopeWidth, 0, slopeWidth, h));

    Path rightWallPath = Path()
      ..moveTo(w - shoulderWidth, 0)
      ..lineTo(w - shoulderWidth - slopeWidth, bevelHeight)
      ..lineTo(w - shoulderWidth - slopeWidth, h)
      ..lineTo(w - shoulderWidth, h)
      ..close();
    canvas.drawPath(rightWallPath, rightWallPaint);

    // 3. Inner Top Shadow (Sunken area ko gehra dikhane ke liye)
    final topInnerShadow = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.black.withValues(alpha: 0.4), AppColors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, bevelHeight, w, 20));

    canvas.drawRect(
        Rect.fromLTWH(shoulderWidth + slopeWidth, bevelHeight,
            w - 2 * (shoulderWidth + slopeWidth), 15),
        topInnerShadow
    );

    // 4. Sharp Highlights (Border lines)
    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Top horizontal edges
    highlightPaint.color = AppColors.white.withValues(alpha: 0.12);
    canvas.drawLine(Offset(0, 0), Offset(shoulderWidth, 0), highlightPaint);
    canvas.drawLine(Offset(w - shoulderWidth, 0), Offset(w, 0), highlightPaint);

    // Bottom "sunken" edge highlight
    highlightPaint.color = AppColors.white.withValues(alpha: 0.05);
    canvas.drawLine(
        Offset(shoulderWidth + slopeWidth, bevelHeight),
        Offset(w - (shoulderWidth + slopeWidth), bevelHeight),
        highlightPaint
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
// --- BORDER PAINTER (LEFT-TO-RIGHT) ---
class BorderAnimationPainter extends CustomPainter {
  final double animationValue;
  BorderAnimationPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final Color mainColor = AppColors.primary; // Beige theme color
    final double radiusValue = 45.0;

    // 1. DYNAMIC PATH (U-Shape: Side and Bottom)
    final Path bottomPath = Path()
      ..moveTo(0, size.height * 0.5)
      ..lineTo(0, size.height - radiusValue)
      ..arcToPoint(
          Offset(radiusValue, size.height),
          radius: Radius.circular(radiusValue),
          clockwise: false
      )
      ..lineTo(size.width - radiusValue, size.height)
      ..arcToPoint(
          Offset(size.width, size.height - radiusValue),
          radius: Radius.circular(radiusValue),
          clockwise: false
      )
      ..lineTo(size.width, size.height * 0.5);

    // 2. FIXED BORDER LINE (Jo hamesha dikhegi)
    // Maine opacity 0.3 rakhi hai taaki ek "Fixed Line" ka effect aaye
    canvas.drawPath(
      bottomPath,
      Paint()
        ..color = mainColor.withValues(alpha: 0.3)
        ..strokeWidth = 1.0 // Patli fixed line
        ..style = PaintingStyle.stroke,
    );

    // 3. ANIMATED GLOW (Jo line ke upar ghoomega)
    final pathMetrics = bottomPath.computeMetrics();
    for (final metric in pathMetrics) {
      final length = metric.length;
      double segmentLength = length * 0.25; // Glow ka size

      double start = length * animationValue;
      double end = start + segmentLength;

      final glowPaint = Paint()
        ..color = mainColor
        ..strokeWidth = 2.0 // Glow thoda mota fixed line se
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2.5); // Glow effect

      if (end < length) {
        canvas.drawPath(metric.extractPath(start, end), glowPaint);
      } else {
        canvas.drawPath(metric.extractPath(start, length), glowPaint);
        canvas.drawPath(metric.extractPath(0, end - length), glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(BorderAnimationPainter oldDelegate) => true;
}


