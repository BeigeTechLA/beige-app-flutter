import 'dart:ui';
import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../Model/HomeModel.dart';
import '../../MyProfile/my_profile.dart';
import '../../service/api_service.dart';
import '../HomeSekect/Home_view_profile.dart';
import '../HomeSekect/change_location_screen.dart';
import '../NewBookingFlow/CreateProjectStep1/Content_Type_screen.dart';
import '../NewBookingFlow/CreateProjectStep1/Video_Shoot_Type.dart';
import 'home_controller .dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> with TickerProviderStateMixin {

  final HomeController controller = HomeController();
  final GlobalKey featuredKey = GlobalKey();
  final GlobalKey topCreativeKey = GlobalKey();
  List<Your_Booking> get bookingList => homeData?.yourBookings ?? [];

  HomeModel? homeData;
  bool isLoading = true;
  int? bookingId;
  int _currentCard = 0;
  late AnimationController _controller;
  final PageController _featuredController = PageController(
    viewportFraction: 0.75);

  final PageController _creativesController = PageController();
  late PageController _bookingController;
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

  Future<void> fetchData() async {
    final data = await controller.fetchHomeData();

    if (data != null) {
      setState(() {
        homeData = data;

        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }


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
      "I want a Wedding Vidoegrapher",
  ];

  final List<Map<String, String>> cardData = [
    {
      "bg": "assets/new_home/Group 2087329746.png",
      "image": "assets/new_home/home_book1.png",
      "title": "Find Your Perfect Creator\nAnywhere, Anytime.",
      "button": "Book a Shoot",
    },
    {
      "bg": "assets/new_home/homebackground_new.png",
      "image": "assets/new_home/home_book_2.png",
      "title": "Trusted by Leading\nBrands.",
      "button": " Explore Creatives",
    },
    {
      "bg": "assets/new_home/homebackground_new.png",
      "image": "assets/new_home/home_book3.png",
      "title": "Instant Pricing &\nIntelligent Matchmaking.",
      "button": "Find Your Creative",
    },
  ];
  final List<String> featuredNames = [
    "Alec H",
    "Benson F",
    "Christopher R",
    "Corey B",
    "Cornelius M",
    "Daniel A",
    "Daniel C",
    "Gary Ahmed",
    "Jesse S.",
    "Mikey D",
    "Nathan Grant"
  ];

  final List<String> featuredImages = [
    "assets/images/Alec+H.png",
    "assets/images/Benson+F.png",
    "assets/images/Christopher+R.png",
    "assets/images/Corey+B.png",
    "assets/images/Cornelius+M. (1).png",
    "assets/images/Daniel+A.png",
    "assets/images/Daniel+C.png",
    "assets/images/Gary+Ahmed.png",
    "assets/images/Jesse+S.png",
    "assets/images/Mikey+D (1).jpg",
    "assets/images/Nathan+Grant.png"
  ];


  final List<String> images = [
    "assets/images/Alec+H.png",
    "assets/images/Benson+F.png",
    "assets/images/Christopher+R.png",
    "assets/images/Corey+B.png",
    "assets/images/Cornelius+M. (1).png",
    "assets/images/Daniel+A.png",
    "assets/images/Daniel+C.png",

  ];
  final List<Map<String, String>> studioList = [
    {
      "image": "assets/new_home/4ce6dbc682ece0f18c3f89046020d5e78a3fcf13.png",
      // Apni studio images dalein
      "name": "Beige Media",
      "desc": "(Modern Resort Villa with Jacuzzi)",
      "location": "Woodland Hills, Los Angeles,",
      "price": "\$150/Hr",
      "rating": "4.5 (120)"
    },
    {
      "image": "assets/new_home/77443dc57b82c5fe2896ea6b85cab505f8682dff.png",
      "name": "Creative Zone",
      "desc": "(Professional Photo Studio & Lights)",
      "location": "Santa Ana, Illinois,",
      "price": "\$120/Hr",
      "rating": "4.8 (95)"
    },
    {
      "image": "assets/new_home/baab5672af97f5f157ca09ab0e02230f6e29b353.png",
      // Apni studio images dalein
      "name": "Beige Media",
      "desc": "(Modern Resort Villa with Jacuzzi)",
      "location": "Woodland Hills, Los Angeles,",
      "price": "\$150/Hr",
      "rating": "4.5 (120)"
    },
  ];

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "completed":
        return Colors.green;   // ✅ Completed → GREEN
      case "pending":
      case "draft":
      case "matching":
        return Colors.red;     // 🔴 Sab pending type → RED
      default:
        return Colors.red;     // Default bhi pending maan lo
    }
  }


  Color getStatusColorFromLabel(String label) {
    switch (label.toLowerCase()) {
      case "completed":
        return Colors.green;   // ✅ Green
      case "pending":
        return Colors.red;     // 🔴 Red
      default:
        return Colors.red;
    }
  }
  final PageController _studioController = PageController(
      viewportFraction: 0.75);
  int _activeStudioIndex = 0;


  final PageController _pageController = PageController(
    initialPage: 1000,
    viewportFraction: 0.65, // Isse side ke cards screen ke paas aayenge

  );


  final List<Color> _textColors = [
    Colors.white.withOpacity(0.5), // Wedding ke liye normal white
    const Color(0xFFE8D1AB), // Corporate ke liye aapka golden color
    ColorCode.kWhiteOpacity70
  ];
  Future<void> _continueBooking(int contentType) async {

    setState(() => isLoading = true);

    try {
      final response =
      await controller.createBooking(contentType, bookingId);

      if (response != null && response['error'] == false) {

        bookingId = response['data']?['booking_id'];

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoShootType(
              contentTypeId: contentType,
              bookingId: bookingId!,
            ),
          ),
        );

        if (result != null && result is int) {
          bookingId = result;
        }
      }
    } catch (e) {
      print("Error → $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
  @override
  void initState() {
    super.initState();
    fetchData();
    _controller = AnimationController(
      vsync: this,

      duration: const Duration(seconds: 10),
    )
      ..repeat();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(); // 🔥 continuous animation

    _swipeController = AnimationController( // ✅ ADD THIS
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bookingController = PageController(
      viewportFraction: 0.82, // 👈 right side card visible
    );

    _cardController = PageController(viewportFraction: 0.88);
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
    return Scaffold(

      body: SingleChildScrollView(
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
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 80),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),

                      // ✅ IMAGE ADDED HERE
                      image: DecorationImage(
                        image: AssetImage("assets/images/mappp.png"), // Aapki image ka path
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
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontFamily: "Outfit",
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const ChangeLocationScreen(),
                                        ),
                                      );

                                      if (result != null && result is Map<String, dynamic>) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        fetchData();
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
                                                    color: Colors.white.withOpacity(0.6),
                                                    fontSize: 15,
                                                    fontFamily: "Outfit"))),
                                        const Icon(Icons.expand_more,
                                            color: Colors.white, size: 20),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            // Profile Pill
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.white.withOpacity(0.08),
                                border: Border.all(
                                    color: const Color(0xFFE8D1AB).withOpacity(0.3),
                                    width: 0.5),
                              ),
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Icon(Icons.notifications_none_rounded,
                                        color: Colors.white, size: 26),
                                  ),
                                   GestureDetector(
                                     onTap: () async{
                                       await Navigator.push(
                                         context,
                                         MaterialPageRoute(
                                           builder: (context) => const MyProfile(),
                                         ),
                                       );
                                       fetchData();
                                     },

                                     child: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.transparent,
                                      child: ClipOval(
                                        child: homeData != null &&
                                            homeData!.profileImageUrl.isNotEmpty
                                            ? Image.network(
                                          ApiService.imageURL + homeData!.profileImageUrl,
                                         /* width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,*/
                                        )
                                            : SvgPicture.asset(
                                          "assets/svg/persone.svg",
                                         /* width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,*/
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
                      color: const Color(0xFF282828),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: const Color(0xFFE8D1AB).withOpacity(0.4),
                          width: 0.5),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.4),
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
                              fontFamily: "Outfit",
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              height: 1,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.09), // left
                    Colors.white24,
                    Colors.white.withOpacity(0.09), // right
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
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
                      itemCount: 1000, // 🔥 infinite feel
                      onPageChanged: (index) {
                        setState(() {
                          _currentCard = index % cardData.length; // 👈 loop indicator
                        });
                      },
                      itemBuilder: (context, index) {
                        final data = cardData[index % cardData.length]; // 👈 loop data
                        return _buildCardbook(data);
                      },
                    ),
                  ),
                  // Banner Dots Indicator
                  Transform.translate(
                    offset: const Offset(0, -7), // 🔥 thoda aur upar (perfect alignment)
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F1F1F),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
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

                                margin: const EdgeInsets.symmetric(horizontal: 5),

                                height: 6, // 🔥 thoda better thickness
                                width: isActive ? 26 : 14, // 🔥 smooth pill effect

                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFFE8D1AB)
                                      : Colors.white.withOpacity(0.25),

                                  borderRadius: BorderRadius.circular(20),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      height: 1,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.09), // left
                            Colors.white24,
                            Colors.white.withOpacity(0.09), // right
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // --- 2. EXPLORE SERVICES SECTION ---
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          "Explore Services",
                          style: TextStyle(color: ColorCode.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Unbounded",
                            height: 1.2,
                          ),

                        ),
                        SvgPicture.asset(
                          "assets/svg/home_vecto.svg",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Services Horizontal List
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        _buildServiceCard(0, "Photo", "assets/new_home/photo_new.png"),
                        _buildServiceCard(1, "Video", "assets/new_home/Image_fx (5) 1.png"),
                        _buildServiceCard(2, "Editing", "assets/new_home/edit_new.png"),
                        _buildServiceCard(3, "Livestream", "assets/new_home/Livestream_new.png"),
                        _buildServiceCard(4, "Studio", "assets/new_home/stuido_new.png"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      height: 1,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.09), // left
                            Colors.white24,
                            Colors.white.withOpacity(0.09), // right
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Continue Your Booking",
                          style: TextStyle(color: ColorCode.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Unbounded",
                            height: 1.2,
                          ),


                        ),

                      ],
                    ),
                  ),


                  // Main Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8D1AB), // Tan/Beige background
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        // Top Row: Image and Text Info
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                "assets/new_home/e5843d2072dc20c350afa27e2260f0c1bb588db3.png",
                                // Replace with your image
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Wedding Photography",
                                    style: TextStyle(
                                      color: ColorCode.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "HelveticaNeue",
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Step 2 of 3: Select Creative",
                                    style: TextStyle(
                                      color: ColorCode.kBlackOpacity70,
                                      fontSize: 15,
                                      fontFamily: "Outfit",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // Progress Indicators
                        Row(
                          children: [
                            _buildProgressBar(isActive: true),
                            const SizedBox(width: 8),
                            _buildProgressBar(isActive: false),
                            const SizedBox(width: 8),
                            _buildProgressBar(isActive: false),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // Resume Button
                        Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: ColorCode.kHeadingColor, // Dark background
                            borderRadius: BorderRadius.circular(23),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Resume",
                                style: TextStyle(
                                  color: ColorCode.kButtonColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Unbounded",
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.arrow_forward,
                                color: ColorCode.kButtonColor,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      height: 1,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.09), // left
                            Colors.white24,
                            Colors.white.withOpacity(0.09), // right
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    key: featuredKey,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Featured Creatives",
                          style: TextStyle(color: ColorCode.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Unbounded",
                            height: 1.2,
                          ),

                        ),

                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    // color: ColorCode.red,
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
                                  0.8; // Is value ko 0.4 se 0.7 tak change karke dekhein
                              rotation = rotation.clamp(-0.8, 0.9);

                              // 3. Scale & Opacity
                              double scale = (1 - (difference.abs() * 0.10))
                                  .clamp(0.0, 1.0);
                              double opacity = (1 - (difference.abs() * 0.10))
                                  .clamp(0.6, 2.0);

                              // 4. Translate (Cards ko center ke paas laane ke liye)
                              // Agar cards ke beech zyada gap hai to is -50 ko badha kar -70 kar dena
                              double translateX = difference * -100;

                              return Opacity(
                                opacity: opacity,
                                child: Transform(
                                  // Alignment center se hi 3D look sabse acha aata hai
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, perspective) // 3D depth
                                    ..translate(translateX) // Paas lane ke liye
                                    ..rotateY(
                                        rotation) // Aapke blue box jaisa fold karne ke liye
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
                        padding: const EdgeInsets.only(top: 12), // Bevel height jitna ya thoda zyada

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
                                        ? const Color(0xFFE8D1AB)
                                        : Colors.white.withOpacity(0.2),
                                    boxShadow: isActive ? [
                                      BoxShadow(
                                        color: const Color(0xFFE8D1AB)
                                            .withOpacity(0.4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      height: 1,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.09), // left
                            Colors.white24,
                            Colors.white.withOpacity(0.09), // right
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
              padding: const EdgeInsets.only(top: 20, bottom: 69, left: 15, right: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // Stops ko correct kiya hai smooth look ke liye
                  stops: const [0.0, 0.7],
                  colors: [
                    const Color(0xFFE8D1AB),
                    const Color(0xFF0D0D0D),
                  ],
                ),
                borderRadius: BorderRadius.circular(45),
              ),
              child: Column(
                children: [
                  const Text(
                    "Beige Studios",

                    style: TextStyle(
                      color: Color(0x29000000),
                      fontSize: 35,
                      fontWeight: FontWeight.w900, // Extra Bold look
                      fontFamily: "Unbounded",
                    ),),


                  // Carousel Section
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      height: 350,
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
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),

                  // Agar address ya description hai to:
                  if(studioList[_activeStudioIndex]['desc'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        studioList[_activeStudioIndex]['desc']!,
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                      ),
                    ),

                  const SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      height: 1,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.09), // left
                            Colors.white24,
                            Colors.white.withOpacity(0.09), // right
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
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
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
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8D1AB),
                                borderRadius: BorderRadius.circular(10),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      height: 1,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.09), // left
                            Colors.white24,
                            Colors.white.withOpacity(0.09), // right
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Your Bookings",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Unbounded",
                          ),
                        ),
                        SvgPicture.asset(
                          "assets/svg/home_vecto.svg",

                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30), // Thoda space stack look ke liye

                  GestureDetector(
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
                      height: 380,
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
                            clipBehavior: Clip.none,
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
                  ),




                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      height: 1,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.09), // left
                            Colors.white.withOpacity(0.09), // center
                            Colors.white.withOpacity(0.09), // right
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "We Think You’ll Love These ",
                      style: TextStyle(color: ColorCode.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Unbounded",
                        height: 1.2,
                      ),)


                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
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
                          padding: const EdgeInsets.only(left: 12, right: 4),
                          child: Container(
                            width: 210,
                            height: 280,
                            clipBehavior: Clip.none, // Ensures child contents don't bleed out of corners
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Stack(
                              children: [
                                /// 1. FULL BACKGROUND IMAGE
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: data.profileImage.isNotEmpty
                                        ? Image.network(
                                      ApiService.imageURL + data.profileImage,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Container(

                                            child: Center(child: SvgPicture.asset("assets/svg/imag_placeholder.svg", fit: BoxFit.cover,)),
                                          ),
                                        );
                                      },
                                    )
                                        : SvgPicture.asset("assets/svg/imag_placeholder.svg", fit: BoxFit.cover),
                                  ),
                                ),

                                /// 2. BOTTOM GRADIENT (The "Black Blur" effect for text readability)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        stops: const [0.4, 1.0], // Starts getting dark near the middle/bottom
                                        colors: [
                                          Colors.transparent,
                                          Colors.black
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
                                          color: ColorCode.white,
                                          fontSize: 12,
                                          fontFamily: "Helvetica Neue",
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        data.title ?? "Creative Professional",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                          fontFamily: "Helvetica Neue",
                                          fontWeight: FontWeight.w400,

                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [

                                          /// 🔥 VIEW PROFILE BUTTON
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        HomeViewProfile(
                                                            id:data.id
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: 35,
                                                // 👈 FIX (important)
                                                alignment: Alignment.center,
                                                // 👈 center text
                                                decoration: BoxDecoration(
                                                  color: ColorCode.kButtonColor,
                                                  borderRadius: BorderRadius
                                                      .circular(
                                                      40), // 👈 pill shape
                                                ),
                                                child: const Text(
                                                  "View Profile",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: ColorCode.black,
                                                    fontFamily: "Outfit",
                                                    fontSize: 14, //
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 10),

                                          /// 🔥 ICON BUTTON (CIRCLE)
                                          Container(

                                            child: Center(
                                              child: SvgPicture.asset(
                                                "assets/svg/home_view_profile.svg",
                                                height: 20,
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      height: 1,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.09), // left
                            Colors.white.withOpacity(0.09), // center
                            Colors.white.withOpacity(0.09), // right
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Rebook Your Shoots",
                          style: TextStyle(color: ColorCode.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Unbounded",
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Container(
                          height: 280,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
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
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.asset(
                                    "assets/new_home/RebookYourShoots_img.jpg",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              // 2. BLACK GRADIENT (Bottom to Top)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.9),
                                        Colors.black.withOpacity(0.4),
                                        Colors.transparent,
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
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                                0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.music_note,
                                              color: Colors.white, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: const [
                                            Text(
                                              "Music Video",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Outfit",
                                              ),
                                            ),
                                            Text(
                                              "March 18, 2026 • Las Vegas, USA",
                                              style: TextStyle(
                                                color: Colors.white60,
                                                fontSize: 12,
                                                fontFamily: "Outfit",
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
                                              color: ColorCode.kButtonColor,
                                              // Aapka beige color
                                              borderRadius: BorderRadius
                                                  .circular(30),
                                            ),
                                            child: const Text(
                                              "Book Again",
                                              style: TextStyle(
                                                color: ColorCode.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: "Helvetica Neue",
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Circular Arrow Button
                                        SvgPicture.asset(
                                          "assets/svg/home_view_profile.svg",

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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      height: 1,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.09), // left
                            Colors.white.withOpacity(0.09), // center
                            Colors.white.withOpacity(0.09), // right
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // --- RECENT PROJECT SECTION ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Recent Project",
                          style: TextStyle(color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Unbounded"),
                        ),
                        const SizedBox(height: 15),

                        // Card 1 with "D" Badge
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _buildProjectCard(
                                "Private Event", "Mar 10, 2025", "136 Files",
                                "assets/new_home/e5843d2072dc20c350afa27e2260f0c1bb588db3.png"),

                          ],
                        ),

                        const SizedBox(height: 12),

                        // Card 2
                        _buildProjectCard(
                            "Wedding Photography", "Feb 15, 2025", "150 Files",
                            "assets/new_home/e5843d2072dc20c350afa27e2260f0c1bb588db3.png"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      height: 1,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.09), // left
                            Colors.white.withOpacity(0.09), // center
                            Colors.white.withOpacity(0.09), // right
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "How It Works",
                  style: TextStyle(color: ColorCode.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Unbounded",
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 15),

                /// 🔥 MAIN CARD
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D1AB), // updated beige color
                    borderRadius: BorderRadius.circular(25),
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
                          color: Colors.black26,
                        ),
                      ),

                      /// 🔥 Timeline Items
                      Column(
                        children: [
                          _buildItem(
                         "assets/svg/AI_Matchmaking.svg",
                            "AI Matchmaking",
                            "The right creative. Every time.",
                          ),
                          _buildItem(
                            "assets/svg/AI Matchmaking-1.svg",
                            "Pre-Production",
                            "Zero back-and-forth. Full clarity.",
                          ),
                          _buildItem(
                            "assets/svg/Production.svg",
                            "Production",
                            "Show up. Shoot. Done.",
                          ),
                          _buildItem(
                            "assets/svg/AI-Powered Post-Production.svg",
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      height: 1,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.09), // left
                            Colors.white.withOpacity(0.09), // center
                            Colors.white.withOpacity(0.09), // right
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
                        const Text(
                          "Get Inspired",
                          style: TextStyle(color: ColorCode.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Unbounded",
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 15),

                        SizedBox(
                          height: 320, // Height thodi badha di hai shadows ke liye
                          child: PageView.builder(
                            controller: _featuredController,
                            itemCount: 10000,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final actualIndex = index % featuredImages.length;

                              return AnimatedBuilder(
                                animation: _featuredController,
                                builder: (context, child) {
                                  double page = 0;
                                  if (_featuredController.hasClients &&
                                      _featuredController.position.haveDimensions) {
                                    page = _featuredController.page!;
                                  }

                                  double diff = index - page;
                                  double translationY = diff.abs() * 40;

                                  // 3. Opacity: Side images halki dikhengi
                                  double opacity = (1 - (diff.abs() * 0.4)).clamp(0.5, 1.0);
                                  // 🔥 Smooth Scaling logic for Image 2 look
                                  // Center wali image scale 1.0 rahegi, side wali 0.8
                                  double scale = (1 - (diff.abs() * 0.2)).clamp(0.8, 1.0);



                                  return Transform.scale(
                                    scale: scale,
                                    child: Opacity(
                                      opacity: opacity,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30),
                                          image: DecorationImage(
                                            image: AssetImage(featuredImages[actualIndex]),
                                            fit: BoxFit.cover,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 15,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      height: 1,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.09), // left
                            Colors.white.withOpacity(0.09), // center
                            Colors.white.withOpacity(0.09), // right
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
                        const Text(
                          "Top Creatives Near you",
                          style: TextStyle(color: ColorCode.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Unbounded",
                            height: 1.2,
                          ),
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
    );
  }
  Widget _buildCardbook(Map<String, String> data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),

        /// ✅ FIGMA BORDER
        border: Border.all(
          color: Colors.white.withOpacity(0.05), // 🔥 5% white
          width: 0.5, // 🔥 exact figma
        ),


      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
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
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    data["title"]!,
                    style: TextStyle(
                      color: ColorCode.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Helvetica Neue"
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      if (data["button"] == "Book a Shoot") {
                        // 🔥 New Screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContentTypeScreen(), //
                          ),
                        );
                      } else if (data["button"] == " Explore Creatives") {
                        // 🔥 Scroll to Featured
                        scrollTo(featuredKey);
                      } else if (data["button"] == "Find Your Creative") {
                        // 🔥 Scroll to Top Creatives
                        scrollTo(topCreativeKey);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8D1AB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data["button"]!,
                        style: TextStyle(
                          color: ColorCode.kHeadingColor,
                          fontFamily: "Unbounded",
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  )
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
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
     /*   boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 25,
            offset: const Offset(0, 15),
          )
        ],*/
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: booking.imageUrl != null && booking.imageUrl!.isNotEmpty
                ? Image.network(
              ApiService.imageURL + booking.imageUrl!,
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Container(
              height: 170,
              width: double.infinity,
              color: const Color(0xFF2A2A2A),
              child: Center(
                child: SvgPicture.asset(
                  "assets/svg/imag_placeholder.svg",
                  color: ColorCode.white
                ),
              ),
            ),
          ),

          // Agar back card hai toh niche ka content fade out kar do
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isBackCard ? 0.0 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Text(
                  booking.title?? "-",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ColorCode.white,
                    fontFamily: "Helvetica Neue",
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 1,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.09), // left
                          Colors.white24,
                          Colors.white.withOpacity(0.09), // right
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      "assets/svg/Frame.svg",
                      color: ColorCode.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      booking.eventDate ?? "-",
                      style: TextStyle(
                        color:ColorCode.white,
                        fontFamily: "Helvetica Neue",
                        fontSize: 12,

                        fontWeight: FontWeight.w400,
                      ),),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SvgPicture.asset(
                      "assets/svg/Group 2087328870.svg",
                      color: ColorCode.white,

                    ),
                    const SizedBox(width: 8),
                    Text("${booking.startTime ?? ""} - ${booking.endTime ?? ""}",
                      style: TextStyle(
                        color:ColorCode.white,
                        fontFamily: "Helvetica Neue",
                        fontSize: 12,

                        fontWeight: FontWeight.w400,
                      ),),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 1,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.09), // left
                    Colors.white24,
                    Colors.white.withOpacity(0.09), // right
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),

          /// BUTTON (Ye bhi back card par hide hoga)
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
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: statusColor),
                          color: statusColor.withOpacity(0.15),
                        ),
                        child: Center(
                          child: Text(
                            booking.statusLabel ?? "",
                            style: TextStyle(
                              color: statusColor,
                              fontFamily: "Helvetica Neue",
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
                SvgPicture.asset(
                  "assets/svg/home_view_profile.svg",
                height: 40,
                )
              ],
            )
        ],
      ),
    );
  }
  Widget _buildProjectCard(String title, String date, String files,
      String img) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF222222), // 👈 Figma background
        borderRadius: BorderRadius.circular(22),

        // 👇 Gradient Border Trick
        border: Border.all(
          width: 0.5,
          color: Colors.white.withOpacity(0.10), // fallback
        ),

        // 👇 Shadow for premium look (optional)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      // 👇 Gradient Border Overlay
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              img,
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
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                Text(date,
                    style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12)),
                const SizedBox(height: 8),
                Text(files,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12)),
              ],
            ),
          ),

          Column(
            children: [
              _buildSmallCircleBtn("assets/svg/eyes1.svg"),
              const SizedBox(height: 8),
              _buildSmallCircleBtn("assets/svg/install.svg"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSmallCircleBtn(String svgPath) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        svgPath,
        height: 18,
        width: 18,
        color: Colors.white, // optional (remove if original color chahiye)
      ),
    );
  }


  Widget _buildProgressBar({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 5,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.black
              : Colors.black.withOpacity(0.15), // Faded for inactive
          borderRadius: BorderRadius.circular(10),
        ),
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
        playBorderAnimationOnce(); // 🔥 animation ek baar

        if (title == "Photo") {
          _continueBooking(2);
        } else if (title == "Video") {
          _continueBooking(1);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$title Coming Soon")),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: isSelected ? 1.05 : 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),

                      /// 🔥 ONLY animate when selected
                      gradient: isSelected
                          ? SweepGradient(
                        transform:
                        GradientRotation(_controller.value * 5.0),
                        colors: [
                          Colors.transparent,
                          const Color(0xFFE8D1AB).withOpacity(0.4),
                          const Color(0xFFE8D1AB),
                          const Color(0xFFE8D1AB).withOpacity(0.4),
                          Colors.transparent,
                        ],
                      )
                          : null,

                      /// 🔥 Simple border when NOT selected
                      border: isSelected
                          ? null
                          : Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,

                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Container(
                      height: 85,
                      width: 85,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F1F1F),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFFE8D1AB)
                    : Colors.white.withOpacity(0.6),
                fontSize: 14,
                fontFamily: "Outfit",
                fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
  void playBorderAnimationOnce() {
    _controller.forward(from: 0).then((_) {
      _controller.stop(); // 🔥 stop after one round
    });
  }
  Widget _buildStudioCard(Map<String, String> data) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        // color: ColorCode.orange,
        // margin: const EdgeInsets.symmetric(horizontal: 10),

        child: Stack(
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
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
      // margin: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,

            height: 212,
            width: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              /* boxShadow: [
                BoxShadow(
                  // color: Colors.black.withOpacity(0.45),
                  blurRadius: 12,
                  // offset: const Offset(0, 10),
                ),
              ],*/
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
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
              color: ColorCode.white,
              fontFamily: "Outfit",
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
    // if (list.isEmpty) return const SizedBox();

    return GestureDetector(
      onTap: () {
        if (_swipeController.isAnimating) return;

        _swipeController.forward().then((_) {
          setState(() {
            _currentCreativeIndex =
                (_currentCreativeIndex + 1) % list.length;
            _swipeController.reset();
          });
        });
      },

      onHorizontalDragEnd: (details) {
        if (_swipeController.isAnimating) return;

        // 👉 LEFT
        if (details.primaryVelocity! < 0) {
          _swipeController.forward().then((_) {
            setState(() {
              _currentCreativeIndex =
                  (_currentCreativeIndex + 1) % list.length;
              _swipeController.reset();
            });
          });
        }

        // 👉 RIGHT
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
        height: 480, // 👈 Height badhayi hai taaki tilt effect properly dikhe
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _swipeController,
          builder: (context, child) {
            double slide = _swipeController.value * 700;
            double rotate = _swipeController.value * 0.4;
            double opacity = 1 - _swipeController.value;

            return Stack(
              alignment: Alignment.center,
              children: [
                // --- 3. BACK CARD (Slightly more tilt to the right) ---
                Transform.translate(
                  offset: const Offset(0, -45),
                  child: Transform.rotate(
                    angle: 0.06,
                    child: Transform.scale(
                      scale: 0.88,
                      child: Opacity(
                        opacity: 0.3,
                        child: _buildCreativeCard((_currentCreativeIndex + 2) % list.length),
                      ),
                    ),
                  ),
                ),

                // --- 2. MIDDLE CARD (Slight tilt to the left) ---
                Transform.translate(
                  offset: const Offset(0, -25),
                  child: Transform.rotate(
                    angle: -0.04,
                    child: Transform.scale(
                      scale: 0.94,
                      child: Opacity(
                        opacity: 0.6,
                        child: _buildCreativeCard((_currentCreativeIndex + 1) % list.length),
                      ),
                    ),
                  ),
                ),

                // --- 1. FRONT INTERACTIVE CARD ---
                Transform.translate(
                  offset: Offset(0, slide),
                  child: Transform.rotate(
                    angle: rotate,
                    child: Opacity(
                      opacity: opacity,
                      child: _buildCreativeCard(_currentCreativeIndex % list.length),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  Widget _buildCreativeCard(int index) {
    final item = homeData!.mainCreatives[index];


    return Container(
      height: 400, // Card ki apni height
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: ColorCode.kGoldBorder50,width: 0.5),
        borderRadius: BorderRadius.circular(40),
        image: DecorationImage(
          image: NetworkImage(
            ApiService.imageURL + item.profileImage,
          ),
          fit: BoxFit.cover,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          children: [
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomCenter,
                    stops: const [0.3, 0.9],
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ),

            // Content Layer
            Padding(
              padding: const EdgeInsets.all(25.0), // Padding thodi badhayi hai
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Status Row (Dot + Rating)


                  // Name & Bio
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: ColorCode.white,
                      fontSize: 22, // Headline size
                      fontWeight: FontWeight.w700,
                      fontFamily: "Unbounded",
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title ?? "Creative Professional",
                    style: const TextStyle(
                      color: ColorCode.kWhiteOpacity70,
                      fontSize: 14,
                      fontFamily: "Helvetica Neue",


                    ),
                  ),

                  const SizedBox(height: 25),

                  // View Profile Button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HomeViewProfile(
                                  id:item.id
                              ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
                      decoration: BoxDecoration(
                        color: ColorCode.kButtonColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text(
                        "View Profile",
                        style: TextStyle(
                          color: ColorCode.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          fontFamily: "Helvetica Neue",

                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget _buildItem(String imagePath, String title, String subtitle) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
                  color: ColorCode.black,
                  fontFamily: "Helvetica Neue",
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Helvetica Neue",
                  color: ColorCode.k1D1D1B_Opacity70,
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
      color: ColorCode.bcakgroundcolor,
      borderRadius: BorderRadius.circular(50),
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
        colors: [Color(0xFF1A1A1A), Color(0xFF121212)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, paint);

    // 2. Vertical Side Shadows (Depth create karne ke liye)
    // Left Wall Shadow
    final leftWallPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.black.withOpacity(0.6), Colors.transparent],
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
        colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
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
        colors: [Colors.black.withOpacity(0.4), Colors.transparent],
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
    highlightPaint.color = Colors.white.withOpacity(0.12);
    canvas.drawLine(Offset(0, 0), Offset(shoulderWidth, 0), highlightPaint);
    canvas.drawLine(Offset(w - shoulderWidth, 0), Offset(w, 0), highlightPaint);

    // Bottom "sunken" edge highlight
    highlightPaint.color = Colors.white.withOpacity(0.05);
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
    const double strokeWidth = 1.5;
    final Color mainColor = const Color(0xFFE8D1AB); // Beige theme color
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
        ..color = mainColor.withOpacity(0.3)
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


