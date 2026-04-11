import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../MyProfile/my_profile.dart';
import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../utility/ColorCode.dart';
import 'HomeSekect/Home_view_profile.dart';
import 'HomeSekect/change_location_screen.dart';
import 'HomeSekect/home_booking_summary_details.dart';
import 'HomeSekect/recommended_detils_screen.dart';
import 'HomeSekect/select_location.dart';
import 'SelectLocationMapScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  String location = "";
  List specialties = [];
  bool isLoading = true;
  List featuredCreatives = [];
  TextEditingController searchController = TextEditingController();

  List<dynamic> incomeList = [];
  List<dynamic> mainCreatives = [];
  int currentIndex = 0;
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slideDown;
  late Animation<double> _scale;
  Map<String, dynamic>? myProfile;
  List<dynamic> filteredMainCreatives = [];
  List<dynamic> filteredFeaturedCreatives = [];
  double? selectedLat;
  double? selectedLng;

  late final double _scrollSpeed;
  late PageController _pageController;
  double _currentPage = 0;

  final int _initialPage = 1000;

  bool isFavourite = false;
  Set<int> favouriteUsers = {};
  @override
  void initState() {
    super.initState();

    /// 🔥 PageController (Smooth Infinite Carousel)
    _pageController = PageController(
      viewportFraction: 0.42, // thoda spacing better
      initialPage: _initialPage,
    );

    _currentPage = _initialPage.toDouble();

    /// ❌ No setState here (smooth scrolling)
    _pageController.addListener(() {
      _currentPage =
          _pageController.page ?? _initialPage.toDouble();
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _slideDown = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.5),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    _scale = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    _fade = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );


    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _scale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _slideDown = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );


    _controller.forward();

    /// 🌐 API call
    _fetchhome_data();
  }
  List<dynamic> filteredCreatives = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /* void startAutoScroll() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_scrollController.hasClients) return;

      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50) {
          _scrollController.jumpTo(0);
        }
      });

      Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 16));

        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
            _scrollController.position.pixels + _scrollSpeed,
          );
        }

        return true;
      });
    });
  }
*/



  String? getProfileImageUrl() {
    if (myProfile == null) return null;

    final image = myProfile!['profile_image_url'];

    if (image == null || image.toString().isEmpty) return null;

    return ApiService.imageURL + image;
  }



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





  Future<void> _fetchhome_data() async {
    try {
      final response = await ApiService().fetchData(
        "${ApiEndpoints.home_data}",
      );

      print("HOME_API lat=$selectedLat lng=$selectedLng");
      print("HOME_RESPONSE = $response");

      if (response != null && response['error'] == false) {
        setState(() {
          location = response['data']['location'] ?? "";
          specialties = response['data']['specialties'] ?? [];
          mainCreatives = response['data']['mainCreatives'] ?? [];

          featuredCreatives = response['data']['featuredCreatives'] ?? [];
          myProfile = response['data'];
          mainCreatives = response['data']['mainCreatives'] ?? [];
          mainCreatives = response['data']['mainCreatives'] ?? [];
          featuredCreatives = response['data']['featuredCreatives'] ?? [];

          filteredMainCreatives = mainCreatives;
          filteredFeaturedCreatives = featuredCreatives;
          filteredCreatives = mainCreatives;
          isLoading = false;
        });
      }
    } catch (e) {
      print("FETCH_ERROR = $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _addFavourite(int userId) async {
    try {
      final response = await ApiService().postData(
        "${ApiEndpoints.addfavourites}/$userId",
        {},
      );

      if (response != null && response['error'] == false) {
        debugPrint("Favourite added");
      }
    } catch (e) {
      debugPrint("Add Favourite Error: $e");
    }
  }


  Future<void> _removeFavourite(int userId) async {
    try {
      final response = await ApiService().deleteData(
        "${ApiEndpoints.addfavourites}/$userId",

      );

      if (response != null && response['error'] == false) {
        debugPrint("Favourite removed");
      }
    } catch (e) {
      debugPrint("Remove Favourite Error: $e");
    }
  }
  void searchCreatives(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredMainCreatives = mainCreatives;
        currentIndex = 0; // important
      });
      return;
    }

    final q = query.toLowerCase();

    setState(() {
      filteredMainCreatives = mainCreatives.where((item) {
        final name = (item["name"] ?? "").toString().toLowerCase();
        final title = (item["primary_title"] ?? "").toString().toLowerCase();

        return name.contains(q) || title.contains(q);
      }).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: ColorCode.k282828,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // 🔥 VERY IMPORTANT
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// TOP ROW
                        /*  Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                        *//*    /// MENU
                            Image.asset(
                              "assets/Icons/menu-02.png",
                              width: 26,
                              color: Colors.white,
                            ),*//*

                            const SizedBox(width: 12),

                            /// LOCATION (🔥 FIXED)
                            Expanded(
                              child: InkWell(
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
                                    _fetchhome_data();
                                  }
                                },

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            location.isNotEmpty
                                                ? location.split(',').take(2).join(', ')
                                                : "Select Location",

                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: "Outfit",
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      location.contains(',')
                                          ? location.split(',').sublist(1).join(', ')
                                          : "Tap to change location",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFFB5B5B5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),



                             SizedBox(width: 15),

                            /// BELL + PROFILE
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  "assets/Icons/notifactioin.png",
                                  width: 22,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 15),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyProfile(),
                                      ),
                                    );
                                  },
                                  child:CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.grey.shade800,
                                    backgroundImage:
                                    getProfileImageUrl() != null
                                        ? NetworkImage(getProfileImageUrl()!)
                                        : const AssetImage("assets/Icons/profile.png") as ImageProvider,
                                  ),





                                ),
                              ],
                            ),
                          ],
                        ),*/

                        Row(
                          children: [

                            /// PROFILE IMAGE (LEFT SIDE)
                            InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MyProfile(),
                                  ),
                                );
                                _fetchhome_data(); // refresh home profile image
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey.shade800,
                                backgroundImage: getProfileImageUrl() != null
                                    ? NetworkImage(getProfileImageUrl()!)
                                    : null,
                                child: getProfileImageUrl() == null
                                    ? Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: SvgPicture.asset(
                                    "assets/svg/persone.svg",

                                  ),
                                )
                                    : null,
                              ),
                            ),

                            const SizedBox(width: 12),

                            /// LOCATION TEXT
                            Expanded(
                              child: InkWell(
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
                                    _fetchhome_data();
                                  }
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            location.isNotEmpty
                                                ? location.split(',').take(2).join(', ')
                                                : "Select Location",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: "Outfit",
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      location.contains(',')
                                          ? location.split(',').sublist(1).join(', ')
                                          : "Tap to change location",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFFB5B5B5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SvgPicture.asset(
                              "assets/svg/notifaction.svg",

                            ),

                          ],
                        ),
                        SizedBox(height: 20),

                        /// SEARCH BAR
                        /*         Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: ColorCode.kHeadingColor,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "assets/svg/serch.svg",

                              ),
                              const SizedBox(width: 10),
                               Expanded(
                                child: TextField(
                                  controller: searchController,
                                  onChanged: (value) {
                                    searchCreatives(value);
                                  },
                                  style: const TextStyle(color: ColorCode.white),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Search",
                                    hintStyle: TextStyle(
                                      fontFamily: "Outfit",
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: ColorCode.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ),
              ),



              SizedBox(height: 30),
              /*         Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [

                    // ⭐ TITLE ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:  [
                        Text(
                          "Book a Shoot",
                          style: TextStyle(
                            color: ColorCode.white,
                            fontFamily: 'Unbounded',   // ← Add this
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                         // Looks cleaner in Unbounded
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>  const  Specialities(showBackButton: true,),
                              ),
                            );
                          },
                          child: Image.asset(
                            "assets/Icons/rightside.png",
                            height: 40,   // bigger height
                            width: 40,
                            color: ColorCode.white,
                          ),
                        )

                      ],
                    ),

                SizedBox(height: 15,),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  height: 115, // 🔥 fixed total height for stability
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: specialties.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 18),
                    itemBuilder: (context, index) {
                      final item = specialties[index];
                      final iconPath =
                      specialtyIcons[index % specialtyIcons.length];

                      return LayoutBuilder(
                        builder: (context, constraints) {

                          double circleSize = 65; // 🔥 balanced size

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [

                              /// 🔵 Premium Circle
                              Container(
                                height: circleSize,
                                width: circleSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2E2E2E),
                                      Color(0xFF1F1F1F),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Image.asset(
                                    iconPath,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              /// 📝 Name
                              SizedBox(
                                width: circleSize + 10,
                                child: Text(
                                  (item["name"] ?? "")
                                      .toString()
                                      .replaceAll(" & ", " &\n"),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: ColorCode.kWhiteOpacity70,
                                    fontFamily: 'Outfit',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),





              ],
                ),
              ),*/




              isLoading
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
                  : filteredMainCreatives.isEmpty
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(
                  child: Text(
                    "No Data Found",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
                  : Center(
                child: GestureDetector(
                  onTap: () async {
                    if (_controller.isAnimating) return;

                    await _controller.reverse();
                    setState(() {
                      currentIndex =
                          (currentIndex + 1) % mainCreatives.length;
                    });
                    _controller.forward();
                  },
                  child: SizedBox(
                    height: 380,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        /// THIRD CARD
                        Transform.translate(
                          offset: const Offset(0, -48),
                          child: Transform.scale(
                            scale: 0.88,
                            child: Opacity(
                              opacity: 0.35,
                              child: _buildCard(
                                key: const ValueKey("third"),
                                data: mainCreatives[
                                (currentIndex + 2) %
                                    mainCreatives.length],
                              ),
                            ),
                          ),
                        ),

                        /// SECOND CARD
                        Transform.translate(
                          offset: const Offset(0, -20),
                          child: Transform.scale(
                            scale: 0.94,
                            child: Opacity(
                              opacity: 0.65,
                              child: _buildCard(
                                key: const ValueKey("second"),
                                data: mainCreatives[
                                (currentIndex + 1) %
                                    mainCreatives.length],
                              ),
                            ),
                          ),
                        ),

                        /// CURRENT CARD
                        /*     SlideTransition(
                          position: _slideDown,
                          child: FadeTransition(
                            opacity: _fade,
                            child: ScaleTransition(
                              scale: _scale,
                              child: _buildCard(
                                key: ValueKey(currentIndex),
                                data: mainCreatives[currentIndex],
                              ),
                            ),
                          ),
                        ),*/
                        SlideTransition(
                          position: _slideDown,
                          child: FadeTransition(
                            opacity: _fade,
                            child: ScaleTransition(
                              scale: _scale,
                              child: _buildCard(
                                key: ValueKey(currentIndex),
                                data: filteredMainCreatives[
                                currentIndex % filteredMainCreatives.length
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 1,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        ColorCode.kDividerStart,
                        ColorCode.kDividerCenter,
                        ColorCode.kDividerEnd,
                      ],
                      stops: [0.0, 0.49, 1.0],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),


              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:  [
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Featured Creatives",
                          style: TextStyle(
                            color: ColorCode.white,
                            fontFamily: 'Unbounded',   // ← Add this
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            // Looks cleaner in Unbounded
                          ),
                        ),
                      ),
                      /*   GestureDetector(
                          *//*              onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Specialities(),
                            ),
                          );
                        },*//*
                        child: Image.asset(
                          "assets/Icons/rightside.png",
                          height: 40,   // bigger height
                          width: 40,
                          color: ColorCode.white,
                        ),
                      )
              */
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 260,
                    child: AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        return PageView.builder(
                          controller: _pageController,
                          physics: const BouncingScrollPhysics(), // 🔥 smooth iOS feel
                          itemBuilder: (context, index) {

                            final int actualIndex =
                                index % featuredImages.length;

                            double page = _pageController.hasClients
                                ? _pageController.page ?? _initialPage.toDouble()
                                : _initialPage.toDouble();

                            double difference = (page - index);

                            // 🔥 ultra smooth scale
                            double scale = 1 -
                                (difference.abs() * 0.15);

                            scale = scale.clamp(0.85, 1.0);

                            // 🔥 smoother vertical movement
                            double translateY =
                            (difference.abs() * 25);

                            translateY = translateY.clamp(0, 30);

                            // 🔥 smoother opacity
                            double opacity =
                                1 - (difference.abs() * 0.25);

                            opacity = opacity.clamp(0.6, 1.0);

                            return Opacity(
                              opacity: opacity,
                              child: Transform.translate(
                                offset: Offset(0, translateY),
                                child: Transform.scale(
                                  scale: scale,
                                  child: teamCard(
                                    image: featuredImages[actualIndex],
                                    name: featuredNames[actualIndex],
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


              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Divider(
                    color: ColorCode.kDividerWhite12,
                    thickness: 1,
                  ),
                ),
              ),

              SizedBox(height: 20),

              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:  [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "We Think You’ll Love These ",
                          style: TextStyle(
                            color: ColorCode.white,
                            fontFamily: 'Unbounded',   // ← Add this
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            // Looks cleaner in Unbounded
                          ),
                        ),
                      ),
                      /*    Image.asset(
                        "assets/Icons/rightside.png",
                        height: 40,   // bigger height
                        width: 40,
                        color: ColorCode.white,
                      ),*/
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredCreatives.length,
                      itemBuilder: (context, index) {

                        final item = featuredCreatives[index];
                        final int userId = item["id"];
                        bool isFavourite = favouriteUsers.contains(userId);
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
                                  child: item["profile_image_url"] != null
                                      ? Image.network(
                                    ApiService().getImageURL(item["profile_image_url"]),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  )
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
                                            item["average_rating"] != null
                                                ? item["average_rating"].toString()
                                                : "4.5",
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
                                        item["name"] ?? "",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 2),

                                      /// TITLE
                                      Text(
                                        item["primary_title"] ?? "",
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
                                                      id: item["id"],
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
                  )
                ],
              ),
            ],
          ),
        )

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
            height: 190,
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



  Widget _buildCard({
    required Map<String, dynamic> data,
    required Key key,
    int index = 0,
  }) {
    return Transform.translate(
      offset: Offset(0, -index * 30),
      child: Container(
        key: key,
        height: 360,
        width: 340,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: Stack(
            children: [

              /// IMAGE
              Positioned.fill(
                child: data["profile_image_url"] != null &&
                    data["profile_image_url"].toString().isNotEmpty
                    ? Image.network(
                  ApiService().getImageURL(
                      data["profile_image_url"]),
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  "assets/images/home2.png",
                  fit: BoxFit.cover,
                ),
              ),

              /// BLUR EFFECT
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 1.5,
                    sigmaY: 1.5,
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0.15),
                  ),
                ),
              ),

              /// DARK GRADIENT (TEXT CLEAR KARNE KE LIYE)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.65),
                      ],
                    ),
                  ),
                ),
              ),

              /// STATUS + TEXT
              Positioned(
                top: 16,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -2),
                          child: Image.asset(
                            "assets/Icons/home_green.png",
                            height: 22,
                            width: 22,
                          ),
                        ),
                        const SizedBox(width: 6),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: ColorCode.kWhiteOpacity60,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                data["average_rating"] != null
                                    ? data["average_rating"].toString()
                                    : "4.5",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      data["name"] ?? "",
                      style: const TextStyle(
                        fontFamily: "Unbounded",
                        color: ColorCode.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      data["primary_title"] ?? "-",
                      style: const TextStyle(
                        fontFamily: "Outfit",
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeViewProfile(
                              id: data["id"],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAD7B0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          /*"From \$${double.tryParse(data["hourly_rate"].toString())?.toInt() ?? 0}/Hr",*/
                          "View Profile",
                          style: const TextStyle(
                            fontFamily: "Outfit",
                            color: ColorCode.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  void _showFavouriteToast(String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: ColorCode.kButtonColor, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "Outfit",
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => overlayEntry.remove(),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
