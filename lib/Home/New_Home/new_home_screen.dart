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

class _NewHomeScreenState extends State<NewHomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
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
  final List<Map<String, String>> studioList = [
    {
      "image": "assets/new_home/4ce6dbc682ece0f18c3f89046020d5e78a3fcf13.png", // Apni studio images dalein
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
      "image": "assets/new_home/baab5672af97f5f157ca09ab0e02230f6e29b353.png", // Apni studio images dalein
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
  int _currentPage = 0;
  final PageController _studioController = PageController(viewportFraction: 0.75);
  int _activeStudioIndex = 0;


  final PageController _pageController = PageController(
    initialPage: 1000,
    viewportFraction: 0.65, // Isse side ke cards screen ke paas aayenge

  );
  int _activeStudio = 0;


  final List<Color> _textColors = [
    Colors.white.withOpacity(0.5), // Wedding ke liye normal white
    const Color(0xFFE8D1AB),        // Corporate ke liye aapka golden color
    ColorCode.kWhiteOpacity70
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,

      duration: const Duration(seconds: 10),
    )..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                // --- 1. ANIMATED BORDER ---
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
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 95),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
                      image: DecorationImage(
                        image: AssetImage("assets/images/map_dots.png"),
                        opacity: 0.1,
                        fit: BoxFit.cover,
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
                                      style: TextStyle(color: Colors.white, fontSize: 22, fontFamily: "Outfit", fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Flexible(
                                          child: Text("Westheimer Santa Ana, Illinois",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15, fontFamily: "Outfit"))),
                                      const Icon(Icons.expand_more, color: Colors.white, size: 20),
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
                                border: Border.all(color: const Color(0xFFE8D1AB).withOpacity(0.3), width: 0.5),
                              ),
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26),
                                  ),
                                  const CircleAvatar(radius: 20, backgroundImage: AssetImage("assets/images/home2.png"))
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
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF282828),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFE8D1AB).withOpacity(0.4), width: 0.5),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
                    ),
                    alignment: Alignment.center,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        // Logic to change text based on animation progress
                        int index = (_controller.value * _searchTexts.length).floor() % _searchTexts.length;

                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 800), // Smooth Fade
                          child: Text(
                            _searchTexts[index],
                            key: ValueKey<int>(index), // Key badalne par hi animation hoga
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
            const SizedBox(height: 50),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40), // Header aur Banner ke beech gap

                // --- 1. PROMO BANNER ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A), // Dark background
                      borderRadius: BorderRadius.circular(25),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/home_background.png"), // Aapki ripple image
                        fit: BoxFit.cover,
                        opacity: 0.4,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // --- 1. COUPLE IMAGE (RIGHT SIDE) ---
                        Positioned(
                          right: 0,
                          bottom: 0,
                          top: 0, // Top 0 rakhne se image poori height cover karegi
                          child: Image.asset(
                            "assets/images/home_couple.png", // Couple wali full image
                            fit: BoxFit.fitHeight, // Isse image ki height container ke barabar ho jayegi
                            alignment: Alignment.bottomRight,
                          ),
                        ),

                        // --- 2. TEXT & BUTTON LAYER ---
                        Padding(
                          padding: const EdgeInsets.all(22.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Find Your Perfect Creator\nAnywhere, Anytime.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Outfit",
                                  height: 1.2, // Line spacing ke liye
                                ),
                              ),
                              const SizedBox(height: 18),
                              // Book a Shoot Button
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8D1AB), // Golden color
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: const Text(
                                  "Book a Shoot",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    fontFamily: "Outfit",
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Banner Dots Indicator
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 25, height: 4, decoration: BoxDecoration(color: const Color(0xFFE8D1AB), borderRadius: BorderRadius.circular(10))),
                    const SizedBox(width: 5),
                    Container(width: 15, height: 4, decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(10))),
                    const SizedBox(width: 5),
                    Container(width: 15, height: 4, decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(10))),
                  ],
                ),

                const SizedBox(height: 30),

                // --- 2. EXPLORE SERVICES SECTION ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Explore Services",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "Outfit"),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.5), size: 18),
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

                      _buildServiceCard("Photo", "assets/new_home/photo.png", true), // Isme purple badge aayega
                      _buildServiceCard("Video", "assets/new_home/Video.png", false),
                      _buildServiceCard("Editing", "assets/new_home/Editing.png", false),
                      _buildServiceCard("Livestream", "assets/new_home/live.png", false),
                      _buildServiceCard("stuido", "assets/new_home/stuido.png", false),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Continue Your Booking",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "Outfit"),
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 10),


                // Main Card
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: EdgeInsets.all(12),
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
                              "assets/new_home/e5843d2072dc20c350afa27e2260f0c1bb588db3.png", // Replace with your image
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
                          color:  ColorCode.kHeadingColor, // Dark background
                          borderRadius: BorderRadius.circular(23),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Resume",
                              style: TextStyle(
                                color:ColorCode.kButtonColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Unbounded",
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.arrow_forward,
                              color:ColorCode.kButtonColor,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Featured Creatives",
                        style: TextStyle(color: ColorCode.white, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: "Unbounded"),
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 320,
                  child: AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      return PageView.builder(
                        controller: _pageController,
                        clipBehavior: Clip.none,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final int actualIndex = index % featuredImages.length;

                          double page = _pageController.hasClients
                              ? _pageController.page ?? _initialPage.toDouble()
                              : _initialPage.toDouble();

                          double difference = (index - page);

                          // 1. Perspective (3D depth) - 0.001 se 0.002 best rehta hai
                          double perspective = 0.0015;

                          // 2. Rotation Logic (Blue box jaisa effect):
                          // Right waali image (difference > 0) ke liye positive rotation
                          // jisse uska right side peeche jaye.
                          double rotation = difference * 0.5; // Is value ko 0.4 se 0.7 tak change karke dekhein
                          rotation = rotation.clamp(-0.8, 0.8);

                          // 3. Scale & Opacity
                          double scale = (1 - (difference.abs() * 0.15)).clamp(0.8, 1.0);
                          double opacity = (1 - (difference.abs() * 0.35)).clamp(0.5, 1.0);

                          // 4. Translate (Cards ko center ke paas laane ke liye)
                          // Agar cards ke beech zyada gap hai to is -50 ko badha kar -70 kar dena
                          double translateX = difference * -50;

                          return Opacity(
                            opacity: opacity,
                            child: Transform(
                              // Alignment center se hi 3D look sabse acha aata hai
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, perspective) // 3D depth
                                ..translate(translateX)       // Paas lane ke liye
                                ..rotateY(rotation)           // Aapke blue box jaisa fold karne ke liye
                                ..scale(scale),               // Chota karne ke liye
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
                const SizedBox(height: 10),
                Container(
                  // margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  padding: const EdgeInsets.only(top: 35, bottom: 25),
                  decoration: BoxDecoration(
                    // Top Beige to Bottom Dark Gradient
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFE8D1AB).withOpacity(0.4),
                        Colors.black.withOpacity(0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Beige Studios",
                        style: TextStyle(
                          color: ColorCode.kBlackOpacity16, // 👈 use here
                          fontSize: 38,
                          fontWeight: FontWeight.w500, // Medium = 500
                          fontFamily: "Unbounded", // 👈 Figma font
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Studio Images Carousel
                      SizedBox(
                        height: 350,
                        child: PageView.builder(
                          controller: _studioController,
                          itemCount: studioList.length,
                          onPageChanged: (index) {
                            setState(() {
                              _activeStudioIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return AnimatedBuilder(
                              animation: _studioController,
                              builder: (context, child) {
                                double value = 1.0;
                                if (_studioController.position.haveDimensions) {
                                  value = _studioController.page! - index;
                                  value = (1 - (value.abs() * 0.1)).clamp(0.9, 1.0);
                                }
                                return Transform.scale(
                                  scale: value,
                                  child: _buildStudioCard(studioList[index]),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Dynamic Text Info below the image
                      const SizedBox(height: 20),
                      Text(
                        studioList[_activeStudioIndex]['name']!,
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, fontFamily: "Outfit"),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          studioList[_activeStudioIndex]['desc']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: "Outfit"),
                        ),
                      ),
                      Text(
                        studioList[_activeStudioIndex]['location']!,
                        style: const TextStyle(color: Colors.white38, fontSize: 12, fontFamily: "Outfit"),
                      ),

                      // Dots Indicator
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          studioList.length,
                              (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _activeStudioIndex == index ? 28 : 15,
                            height: 5,
                            decoration: BoxDecoration(
                              color: _activeStudioIndex == index ? const Color(0xFFE8D1AB) : Colors.white24,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Your Bookings",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "Outfit"),
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 10),

                const SizedBox(height: 10),
                SizedBox(
                  height: 380, // Total height for stack effect
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.85), // Taaki side wala card dikhe
                    itemCount: bookingList.length,
                    clipBehavior: Clip.none,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            // --- Piche wala card (Peek Effect) ---
                            if (index < bookingList.length - 1)
                              Positioned(
                                right: -20,
                                top: 20,
                                bottom: 20,
                                child: Opacity(
                                  opacity: 0.3,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.7,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E1E1E),
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(color: Colors.white10),
                                    ),
                                  ),
                                ),
                              ),

                            // --- Main Top Card ---
                            // --- Main Top Card ---
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E), // Dark card color
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      bookingList[index]['image']!,
                                      height: 160,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  // Title
                                  Text(
                                    bookingList[index]['title']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Outfit",
                                    ),
                                  ),
                                  const Divider(color: Colors.white10, height: 25),
                                  // Date
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_month_outlined, color: Colors.white54, size: 20),
                                      const SizedBox(width: 10),
                                      Text(bookingList[index]['date']!, style: const TextStyle(color: Colors.white70)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Time
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time_outlined, color: Colors.white54, size: 20),
                                      const SizedBox(width: 10),
                                      Text(bookingList[index]['time']!, style: const TextStyle(color: Colors.white70)),
                                    ],
                                  ),
                                  const Spacer(),
                                  // Footer Buttons
                                  Row(
                                    children: [
                                      // Completed Button
                                      Expanded(
                                        child: Container(
                                          height: 48,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.green.withOpacity(0.5)),
                                            borderRadius: BorderRadius.circular(25),
                                            color: Colors.green.withOpacity(0.05),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                                              SizedBox(width: 8),
                                              Text("Completed", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Circular Arrow Button
                                      Container(
                                        height: 48, width: 48,
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
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        "We Think You’ll Love These ",
                        style: TextStyle(color: ColorCode.white, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: "Unbounded"),
                      ),


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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                  builder: (context) => HomeViewProfile(
                                                    id: 2
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              height: 30, // 👈 FIX (important)
                                              alignment: Alignment.center, // 👈 center text
                                              decoration: BoxDecoration(
                                                color: ColorCode.kButtonColor,
                                                borderRadius: BorderRadius.circular(40), // 👈 pill shape
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Rebook Your Shoots",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Unbounded",
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
                                          color: Colors.white.withOpacity(0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.music_note, color: Colors.white, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                          height: 52,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8D1AB), // Aapka beige color
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          child: const Text(
                                            "Book Again",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: "Outfit",
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Circular Arrow Button
                                      Container(
                                        height: 52,
                                        width: 52,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.call_made_rounded, color: Colors.white, size: 22),
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
                    const SizedBox(height: 30),
                  ],
                ),
                const SizedBox(height: 10),

                // --- RECENT PROJECT SECTION ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Recent Project",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Unbounded"),
                      ),
                      const SizedBox(height: 15),

                      // Card 1 with "D" Badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _buildProjectCard("Private Event", "Mar 10, 2025", "136 Files", "assets/new_home/photo.png"),

                        ],
                      ),

                      const SizedBox(height: 12),

                      // Card 2
                      _buildProjectCard("Wedding Photography", "Feb 15, 2025", "150 Files", "assets/new_home/Editing.png"),
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

  Widget _buildProjectCard(String title, String date, String files, String img) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              "assets/new_home/e5843d2072dc20c350afa27e2260f0c1bb588db3.png", // Replace with your image
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
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                Text(date, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 8),
                Text(files, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Column(
            children: [
              _buildSmallCircleBtn(Icons.share_outlined),
              const SizedBox(height: 8),
              _buildSmallCircleBtn(Icons.file_download_outlined),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSmallCircleBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 18),
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
                  border: hasBadge ? Border.all(color: const Color(0xFFE8D1AB).withOpacity(0.5), width: 1) : null,
                ),
                child: Image.asset(imagePath, fit: BoxFit.contain), // Icon image
              ),
              // Purple Badge (D Pin)

            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, fontFamily: "Outfit"),
          )
        ],
      ),
    );
  }
  Widget _buildStudioCard(Map<String, String> data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 10))
        ],
      ),
      child: Stack(
        children: [
          // Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.asset(data['image']!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          ),

          // Green Online Dot
          Positioned(
            top: 18, left: 18,
            child: Container(
              width: 12, height: 12,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.greenAccent, blurRadius: 8)],
              ),
            ),
          ),

          // Heart/Favorite Icon
          const Positioned(
            top: 15, right: 18,
            child: Icon(Icons.favorite_border, color: Colors.white, size: 24),
          ),

          // Blue Badge with 'D'
          Positioned(
            bottom: 60, right: 35,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
              child: const Text("D", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),

          // Rating and Price Overlay
          Positioned(
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
          ),
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
            duration: const Duration(milliseconds:600),
            curve: Curves.easeOutCubic,

            height: 212,
            width: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  // color: Colors.black.withOpacity(0.45),
                  blurRadius: 12,
                  // offset: const Offset(0, 10),
                ),
              ],
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
}

// --- BORDER PAINTER (LEFT-TO-RIGHT) ---
class BorderAnimationPainter extends CustomPainter {
  final double animationValue;
  BorderAnimationPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 0.5;
    final Color mainColor = const Color(0xFFE8D1AB);

    const radius = Radius.circular(45);
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - 45)
      ..arcToPoint(Offset(size.width - 45, size.height), radius: radius)
      ..lineTo(45, size.height)
      ..arcToPoint(Offset(0, size.height - 45), radius: radius)
      ..close();

    canvas.drawPath(path, Paint()..color = mainColor.withOpacity(0.1)..strokeWidth = strokeWidth..style = PaintingStyle.stroke);

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final length = metric.length;
      final reversedValue = 1.0 - animationValue; // Direction: Left to Right
      final start = length * reversedValue;
      final end = (start + (length * 0.15)) % length;

      final glowPaint = Paint()
        ..color = mainColor
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1.5);

      if (start < end) {
        canvas.drawPath(metric.extractPath(start, end), glowPaint);
      } else {
        canvas.drawPath(metric.extractPath(start, length), glowPaint);
        canvas.drawPath(metric.extractPath(0, end), glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(BorderAnimationPainter oldDelegate) => true;
}