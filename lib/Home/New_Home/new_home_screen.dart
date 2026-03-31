import 'dart:ui';
import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../HomeSekect/Home_view_profile.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> with TickerProviderStateMixin {
  int _currentCard = 0;
  late AnimationController _controller;
  final PageController _featuredController = PageController(
      initialPage: 1000, viewportFraction: 0.65);
  final PageController _creativesController = PageController();
  late PageController _bookingController;
  late PageController _cardController;


  final PageController _inspiredController = PageController(
    initialPage: 1000,

    viewportFraction: 0.65,
  );

  late AnimationController _swipeController;
  int _currentCreativeIndex = 0;

  final int _initialPage = 1000;

  // --- DATA LISTS FOR TEXT & COLORS ---
  final List<String> _searchTexts = [
    "I want a Wedding Photographer",
    "Corporate Event Photos",
    "Birthday Party Shoot",
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

  final List<Map<String, String>> bookingList = [
    {
      "image": "assets/new_home/photo.png", // Apni booking image dalein
      "title": "Wedding Photography",
      "date": "16 Jun, 2024",
      "time": "10:00 PM to 13:00 PM",
      "status": "Completed"
    },
    {
      "image": "assets/new_home/Editing.png",
      "title": "Corporate Shoot",
      "date": "20 Jun, 2024",
      "time": "11:00 AM to 02:00 PM",
      "status": "Pending"
    },
  ];

  List<Map<String, String>> creatives = [
    {
      "name": "Ethan Cole",
      "bio": "Model, Entrepreneur & Media Personality.",
      "img": "assets/images/home1.png"
    },
    {
      "name": "Angela Kia",
      "bio": "Professional Photographer & Director.",
      "img": "assets/new_home/photo.png"
    },
    {
      "name": "Nathan Grant",
      "bio": "Creative Designer & Visual Artist.",
      "img": "assets/images/Nathan+Grant.png"
    },
  ];


  int _currentPage = 0;
  final PageController _studioController = PageController(
      viewportFraction: 0.75);
  int _activeStudioIndex = 0;


  final PageController _pageController = PageController(
    initialPage: 1000,
    viewportFraction: 0.65, // Isse side ke cards screen ke paas aayenge

  );
  int _activeStudio = 0;


  final List<Color> _textColors = [
    Colors.white.withOpacity(0.5), // Wedding ke liye normal white
    const Color(0xFFE8D1AB), // Corporate ke liye aapka golden color
    ColorCode.kWhiteOpacity70
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,

      duration: const Duration(seconds: 10),
    )
      ..repeat();

    _swipeController = AnimationController( // ✅ ADD THIS
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bookingController = PageController(
      viewportFraction: 0.82, // 👈 right side card visible
    );

    _cardController = PageController(viewportFraction: 0.8);


  }

  @override
  void dispose() {
    _controller.dispose();
    _swipeController.dispose(); // ✅ MUST
    _inspiredController.dispose(); // ✅ ADD THIS

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
                // --- 1. ANIMATED BORDER ---
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
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 95),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),

                      // ✅ IMAGE ADDED HERE
                      image: DecorationImage(
                        image: AssetImage("assets/images/mappp.png"), // Aapki image ka path
                         // opacity: 0.2, // Subtle look ke liye opacity kam rakhi hai
                        fit: BoxFit.none,
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
                                  const Text("Hello Divaish 👋,",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontFamily: "Outfit",
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Flexible(
                                          child: Text("Westheimer Santa Ana, Illinois",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.white.withOpacity(0.6),
                                                  fontSize: 15,
                                                  fontFamily: "Outfit"))),
                                      const Icon(Icons.expand_more,
                                          color: Colors.white, size: 20),
                                    ],
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
                                  const CircleAvatar(
                                      radius: 20,
                                      backgroundImage: AssetImage("assets/images/home2.png"))
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
                  bottom: -25,
                  child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.85,
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
                    Colors.white.withOpacity(0.09), // center
                    Colors.white.withOpacity(0.09), // right
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),

            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  // --- 1. PROMO BANNER ---
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      controller: _cardController,
                      itemCount: 1000, // 🔥 infinite feel
                      onPageChanged: (index) {
                        setState(() {
                          _currentCard = index % 3; // 🔥 loop fix
                        });
                      },
                      itemBuilder: (context, index) {
                        final actualIndex = index % 3; // 🔥 repeat 3 items

                        return AnimatedBuilder(
                          animation: _cardController,
                          builder: (context, child) {
                            double value = 1.0;

                            if (_cardController.position.haveDimensions) {
                              value = _cardController.page! - index;
                              value = (1 - (value.abs() * 0.2)).clamp(0.85, 1.0);
                            }

                            return Center(
                              child: Transform.scale(
                                scale: value,
                                child: _buildCardbook(), // 🔥 same card repeat
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Banner Dots Indicator
                  Transform.translate(
                    offset: const Offset(0, -20), // 🔥 thoda upar float
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF212121),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
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
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                height: 4, // 🔥 slim
                                width: isActive ? 18 : 6,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFFE8D1AB)
                                      : Colors.white24,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Unbounded",
                            height: 1.2,
                          ),


                        ),
                        Icon(Icons.arrow_forward_ios,
                            color: Colors.white.withOpacity(0.5), size: 18),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Services Horizontal List
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      children: [

                        _buildServiceCard(
                            "Photo", "assets/new_home/photo.png", false),
                        // Isme purple badge aayega
                        _buildServiceCard(
                            "Video", "assets/new_home/Image_fx (5) 1.png", false),
                        _buildServiceCard(
                            "Editing", "assets/new_home/Editing.png", false),
                        _buildServiceCard(
                            "Livestream", "assets/new_home/live.png", false),
                        _buildServiceCard(
                            "stuido", "assets/new_home/stuido.png", false),
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


                  const SizedBox(height: 10),
                  // Main Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: EdgeInsets.all(15),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Featured Creatives",
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
                  const SizedBox(height: 20),
                  Container(
                    // color: ColorCode.red,
                    child: SizedBox(
                      height: 260,
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

                              // 1. Perspective (3D depth) - 0.001 se 0.002 best rehta hai
                              double perspective = 0.0025;

                              // 2. Rotation Logic (Blue box jaisa effect):
                              // Right waali image (difference > 0) ke liye positive rotation
                              // jisse uska right side peeche jaye.
                              double rotation = difference *
                                  0.8; // Is value ko 0.4 se 0.7 tak change karke dekhein
                              rotation = rotation.clamp(-0.8, 0.8);

                              // 3. Scale & Opacity
                              double scale = (1 - (difference.abs() * 0.10))
                                  .clamp(0.0, 1.0);
                              double opacity = (1 - (difference.abs() * 0.40))
                                  .clamp(0.6, 2.0);

                              // 4. Translate (Cards ko center ke paas laane ke liye)
                              // Agar cards ke beech zyada gap hai to is -50 ko badha kar -70 kar dena
                              double translateX = difference * -90;

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
                      AnimatedBuilder(
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
                                duration: const Duration(milliseconds: 300),
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
                    ],

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
                      padding: const EdgeInsets.only(top: 45, bottom: 29),
                      decoration: BoxDecoration(
                        // 🔥 Exact Figma Gradient
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 2.0],
                          colors: [
                            const Color(0xFFE8D1AB),
                            const Color(0xFF0D0D0D),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(45),

                      ),
                      child: Column(
                        children: [
                          // Title Text
                          const Text(
                            "Beige Studios",
                            style: TextStyle(
                              color: Color(0x29000000), // Figma 16% Opacity Black
                              fontSize: 38,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Unbounded",

                            ),
                          ),



                          // Carousel Section
                          SizedBox(
                            height: 330,
                            child: PageView.builder(
                              controller: _studioController,
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
                                      scale = (1 - (diff.abs() * 0.22)).clamp(0.89, 2.0);
                                      translate = diff.abs() * 30;
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

                          const SizedBox(height: 25),

                          // Studio Info & Dots
                          Text(
                            studioList[_activeStudioIndex]['name']!,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 30),

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
                          Center(
                            child: Container(
                              width: 60, // Track ki poori width
                              height: 8, // Track ki height
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1), // Background track ka color
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Stack(
                                children: [
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    // Calculation: Active index ke hisaab se position change hogi
                                    left: (_activeStudioIndex * (80 / studioList.length)),
                                    child: Container(
                                      width: 60 / studioList.length, // Indicator ki width
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8D1AB), // Aapka beige color
                                        borderRadius: BorderRadius.circular(40),
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
                        Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.5), size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30), // Thoda space stack look ke liye

          SizedBox(
            height: 400,
            child: PageView.builder(
              controller: _bookingController,
              itemCount: bookingList.length,
              clipBehavior: Clip.none,
              physics: const BouncingScrollPhysics(),


              itemBuilder: (context, index) {
                double slide = _swipeController.value * -600;
                double rotate = _swipeController.value * 0.4;
                double opacity = 1 - _swipeController.value;


                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // --- 3. SABSE PICHE WALA CARD (Back Card) ---
                    Transform.translate(
                      offset: const Offset(0, -40), // 👈 Thoda aur upar
                      child: Transform.rotate(
                        angle: 0.08, // Right Tilt
                        child: Transform.scale(
                          scale: 0.85, // 👈 Sabse chota scale
                          child: Opacity(
                            opacity: 0.3,
                            child: _buildBookingCard((_currentCreativeIndex + 2) % creatives.length),
                          ),
                        ),
                      ),
                    ),

                    // --- 2. BEECH WALA CARD (Middle Card) ---
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Transform.rotate(
                        angle: -0.06, // Left Tilt
                        child: Transform.scale(
                          scale: 0.92, // 👈 Medium scale
                          child: Opacity(
                            opacity: 0.6,
                            child: _buildBookingCard((_currentCreativeIndex + 1) % creatives.length),
                          ),
                        ),
                      ),
                    ),

                    // --- 1. MAIN TOP INTERACTIVE CARD ---
                    Transform.translate(
                      offset: Offset(0, slide),
                      child: Transform.rotate(
                        angle: rotate,
                        child: Opacity(
                          opacity: opacity,
                          child: _buildBookingCard(_currentCreativeIndex),
                        ),
                      ),
                    ),
                  ],
                );
              },
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
                      itemCount: 3,
                      itemBuilder: (context, index) {

                        /*  final item = featuredCreatives[index];
                      final int userId = item["id"];
                      bool isFavourite = favouriteUsers.contains(userId);*/
                        return Padding(
                          padding: const EdgeInsets.only(left: 12, right: 4),
                          child: Container(
                            width: 210,
                            height: 280,
                            child: Stack(
                              children: [

                                /// IMAGE
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child
                                      : Image.asset(
                                    "assets/images/home1.png",
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                /// BLACK GRADIENT
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    height: 110,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                          bottom: Radius.circular(18)),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.8)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                /*     /// ONLINE DOT
                                const Positioned(
                                  top: 10,
                                  left: 10,
                                  child: CircleAvatar(
                                    radius: 6,
                                    backgroundColor: Colors.green,
                                  ),
                                ),

                                /// HEART ICON
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child:     GestureDetector(
                                    onTap: () async {
                                      if (isFavourite) {
                                        // ❌ REMOVE
                                        setState(() {
                                          favouriteUsers.remove(userId);
                                        });

                                        await _removeFavourite(userId);

                                        _showFavouriteToast("Removed from Favourite");
                                      } else {
                                        // ✅ ADD
                                        setState(() {
                                          favouriteUsers.add(userId);
                                        });

                                        await _addFavourite(userId);

                                        _showFavouriteToast("Added to Favourite");
                                      }
                                    },
                                    child: Image.asset(
                                      isFavourite
                                          ? "assets/Icons/Heart_Angl_COLOR.png"
                                          : "assets/images/Heart Angle.png",
                                      height: 22,
                                      width: 22,
                                    ),
                                  ),
                                ),
*/

                                /// TEXT DATA
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  right: 12,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [

                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              color: Colors.yellow, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            "4.5",
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 4),

                                      /// NAME
                                      Text(
                                        "Angela Kia",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 2),

                                      /// TITLE
                                      Text(
                                        "Videography Specialist",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

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
                                                            id: 2
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: 30,
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
                    color: const Color(0xFFDCC7A1), // beige color
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Stack(
                    children: [
                      /// 🔥 Vertical Line
                      Positioned(
                        left: 45,
                        top: 20,
                        bottom: 20,
                        child: Container(
                          width: 2,
                          color: Colors.black26,
                        ),
                      ),

                      /// 🔥 Timeline Items
                      Column(
                        children: [
                          _buildItem(
                            Icons.memory,
                            "AI Matchmaking",
                            "The right creative. Every time.",
                          ),
                          _buildItem(
                            Icons.movie_creation_outlined,
                            "Pre-Production",
                            "Zero back-and-forth. Full clarity.",
                          ),
                          _buildItem(
                            Icons.videocam_outlined,
                            "Production",
                            "Show up. Shoot. Done.",
                          ),
                          _buildItem(
                            Icons.auto_awesome,
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
                          height: 300,
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

                                  /// 🔥 Smooth Effects
                                  double scale = (1 - (diff.abs() * 0.2)).clamp(0.7, 1.0);
                                  double rotation = (diff * 0.5).clamp(-0.5, 0.8);
                                  double translate = diff * -20;

                                  return Center(
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.0015) // perspective (3D feel)
                                        ..translate(translate)
                                        ..rotateY(rotation)
                                        ..scale(scale),
                                      child: Opacity(
                                        opacity: (1 - diff.abs() * 0.3).clamp(0.5, 1.0),
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(vertical: 10),
                                          width: 250,
                                          height: 300,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30),
                                            image: DecorationImage(
                                              image: AssetImage(featuredImages[actualIndex]),
                                              fit: BoxFit.cover,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.5),
                                                blurRadius: 20,
                                                offset: const Offset(0, 10),
                                              ),
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
  Widget _buildCardbook() {
    return Container(
      height: 160,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),

        /// ✅ FIGMA BORDER
        border: Border.all(
          color: Colors.white.withOpacity(0.05), // 🔥 5% white
          width: 0.5, // 🔥 exact figma
        ),

        /// 🔥 OPTIONAL SHADOW (aur premium)
       /* boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],*/
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [

            /// BACKGROUND
            Image.asset(
              "assets/images/home_background.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),

            /// GRADIENT OVERLAY
           /* Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.75),
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),*/

            /// RIGHT IMAGE
            Positioned(
              right: -5,
              bottom: 0,
              top: 0,
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: [Colors.transparent, Colors.black],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  "assets/images/man2.png",
                  fit: BoxFit.cover,
                  height: 180,
                ),
              ),
            ),

            /// TEXT
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Find Your Perfect Creator\nAnywhere, Anytime.",
                    style: TextStyle(
                      color: ColorCode.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,

                      fontFamily: "Helvetica Neue"
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8D1AB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "Book a Shoot",
                      style: TextStyle(
                        color: ColorCode.kHeadingColor,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
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
  Widget _buildBookingCard(int index) {
    final booking = bookingList[index]; // Ab ye error nahi dega
    return Container(
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Figma Dark Gray
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// --- IMAGE ---
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              booking['image']!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 15),

          /// --- TITLE ---
          Text(
            booking['title']!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: "Outfit",
            ),
          ),

          const Divider(color: Colors.white10, height: 25),

          /// --- DATE & TIME ---
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: Colors.white54, size: 20),
              const SizedBox(width: 10),
              Text(booking['date']!, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.access_time_outlined, color: Colors.white54, size: 20),
              const SizedBox(width: 10),
              Text(booking['time']!, style: const TextStyle(color: Colors.white70)),
            ],
          ),

          const Spacer(),

          /// --- FOOTER (Completed & Icon) ---
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(25),
                    color: const Color(0xFF142418), // Dark Greenish bg
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text("Completed",
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call_made_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
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

  Widget _buildServiceCard(String title, String imagePath, bool hasBadge) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 85,
                width: 85,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(20),
                  border: hasBadge
                      ? Border.all(
                      color: const Color(0xFFE8D1AB).withOpacity(0.5), width: 1)
                      : null,
                ),
                child: Image.asset(
                    imagePath, fit: BoxFit.contain), // Icon image
              ),
              // Purple Badge (D Pin)

            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontFamily: "Outfit"),
          )
        ],
      ),
    );
  }

  Widget _buildStudioCard(Map<String, String> data) {
    return Container(
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

          // Green Online Dot
          /*  Positioned(
            top: 18, left: 18,
            child: Container(
              width: 12, height: 12,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.greenAccent, blurRadius: 8)],
              ),
            ),
          ),*/

          // Heart/Favorite Icon
       /*   const Positioned(
            top: 15, right: 18,
            child: Icon(Icons.favorite_border, color: Colors.white, size: 24),
          ),*/


          // Rating and Price Overlay
          /*   Positioned(
            bottom: 20, left: 18, right: 18,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Rating Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(18)),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 5),
                      Text(data['rating']!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // Price
                Text(
                  "From ${data['price']}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),*/
        ],
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
    return GestureDetector(
      onTap: () {
        if (!_swipeController.isAnimating) {
          _swipeController.forward().then((_) {
            setState(() {
              _currentCreativeIndex = (_currentCreativeIndex + 1) % creatives.length;
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
            double slide = _swipeController.value * -600;
            double rotate = _swipeController.value * 0.4;
            double opacity = 1 - _swipeController.value;

            return Stack(
              alignment: Alignment.center,
              children: [
                // --- 3. SABSE PICHE WALA CARD (Back Card) ---
                Transform.translate(
                  offset: const Offset(0, -40), // 👈 Thoda aur upar
                  child: Transform.rotate(
                    angle: 0.08, // Right Tilt
                    child: Transform.scale(
                      scale: 0.85, // 👈 Sabse chota scale
                      child: Opacity(
                        opacity: 0.3,
                        child: _buildCreativeCard((_currentCreativeIndex + 2) % creatives.length),
                      ),
                    ),
                  ),
                ),

                // --- 2. BEECH WALA CARD (Middle Card) ---
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Transform.rotate(
                    angle: -0.06, // Left Tilt
                    child: Transform.scale(
                      scale: 0.92, // 👈 Medium scale
                      child: Opacity(
                        opacity: 0.6,
                        child: _buildCreativeCard((_currentCreativeIndex + 1) % creatives.length),
                      ),
                    ),
                  ),
                ),

                // --- 1. MAIN TOP INTERACTIVE CARD ---
                Transform.translate(
                  offset: Offset(0, slide),
                  child: Transform.rotate(
                    angle: rotate,
                    child: Opacity(
                      opacity: opacity,
                      child: _buildCreativeCard(_currentCreativeIndex),
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
    final item = creatives[index];

    return Container(
      height: 400, // Card ki apni height
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(45), // 👈 Zyada rounded corners premium dikhte hain
        image: DecorationImage(
          image: AssetImage(item["img"]!),
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
        borderRadius: BorderRadius.circular(45),
        child: Stack(
          children: [
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
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
                    item["name"]!,
                    style: const TextStyle(
                      color: ColorCode.white,
                      fontSize: 22, // Headline size
                      fontWeight: FontWeight.w700,
                      fontFamily: "Unbounded",
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item["bio"]!,
                    style: const TextStyle(
                      color: ColorCode.kWhiteOpacity70,
                      fontSize: 14,
                      fontFamily: "Helvetica Neue",


                    ),
                  ),

                  const SizedBox(height: 25),

                  // View Profile Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
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
                        fontFamily: "Helvetica Neue ",

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
Widget creativeCard() {
  return Container(
    // margin: const EdgeInsets.only(right: 15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(40),
     /* image: const DecorationImage(
        image: NetworkImage("https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1000&auto=format&fit=crop"), // Apni image link daalein
        fit: BoxFit.cover,
      ),*/
    ),
    child: Stack(
      children: [
        // Dark overlay for text readability
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Online dot and Rating
              Row(
                children: [
                  // Green Dot
                  Container(
                    height: 12,
                    width: 12,
                    decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.green, blurRadius: 10)]
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Rating Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.star, color: Colors.yellow, size: 16),
                        SizedBox(width: 4),
                        Text("4.5 (120)", style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(), // Content ko niche dhakelne ke liye

              // Name
              const Text(
                "Ethan Cole",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Unbounded",
                ),
              ),

              // Bio
              const Text(
                "Model, Entrepreneur & Media\nPersonality.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 20),

              // View Profile Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5D1B2), // Beige color from image
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "View Profile",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    ),
  );
}
Widget _buildItem(IconData icon, String title, String subtitle) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔥 Icon Circle
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black, size: 24),
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
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black.withOpacity(0.6),
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
      color: Colors.black,
      borderRadius: BorderRadius.circular(50),
    ),
  );
}


class BeveledTrayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;

    // Figma proportions
    double bevelHeight = 15;
    double slopeWidth = 20;
    double shoulderWidth = w * 0.20;

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

    // --- 1. Background Gradient (Dark Material) ---
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF131313), Color(0xFF242424)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, paint);

    // --- 2. Vertical Recessed Shadows (Jo "gehrai" dikhayenge) ---
    final shadowPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.black.withOpacity(0.8), Colors.transparent],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(shoulderWidth, 0, 40, h));

    // Left shadow marker
    canvas.drawRect(Rect.fromLTWH(shoulderWidth, 0, 15, h), shadowPaint);

    final shadowPaintRight = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(w - shoulderWidth - 15, 0, 15, h));

    // Right shadow marker
    canvas.drawRect(Rect.fromLTWH(w - shoulderWidth - 15, 0, 15, h), shadowPaintRight);

    // --- 3. Subtle Top Highlight (White border ko soft karne ke liye) ---
    // Hum sirf top flat area aur slopes par line khichenge
    final highlightPath = Path()
      ..moveTo(0, 0)
      ..lineTo(shoulderWidth, 0)
      ..lineTo(shoulderWidth + slopeWidth, bevelHeight)
      ..lineTo(w - (shoulderWidth + slopeWidth), bevelHeight)
      ..lineTo(w - shoulderWidth, 0)
      ..lineTo(w, 0);

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.06) // Bahut light white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(highlightPath, highlightPaint);
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


class TicketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0D0D0D) // Background dark color
      ..style = PaintingStyle.fill;

    double radius = 10; // Cutout ka size
    double gap = size.height / 4; // Charo cuts ke beech barabar jagah

    for (int i = 1; i <= 3; i++) {
      double y = gap * i;
      // Left Cut
      canvas.drawCircle(Offset(0, y), radius, paint);
      // Right Cut
      canvas.drawCircle(Offset(size.width, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}