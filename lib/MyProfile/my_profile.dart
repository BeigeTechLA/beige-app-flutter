import 'package:beige/Home/home_screen.dart';
import 'package:beige/auth/new_login_screen.dart';
import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../service/shared_service.dart';
import '../utility/ColorCode.dart';
import 'Booking_History_screen.dart';
import 'Favourite_screen.dart';
import 'app_preferences.dart';
import 'edit_profile.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {


  bool isLoading =true;


  List<dynamic> myprofile = [];


  Map<String, dynamic>? myProfile;
  @override
  void initState() {
    super.initState();
    _fetchMyProfile();
  }

  Future<void> _fetchMyProfile() async {
    debugPrint("🟢 MY PROFILE API CALL STARTED");

    try {
      final response = await ApiService().fetchData(ApiEndpoints.my_profile);

      debugPrint("🟡 API RESPONSE: $response");

      if (response != null && response['error'] == false) {
        final user = response['data']['user'];

        setState(() {
          myProfile = user;


          isLoading = false;
        });

        debugPrint("✅ PROFILE DATA SET IN TEXTFIELDS");
      } else {
        isLoading = false;
      }
    } catch (e) {
      debugPrint("🚨 FETCH ERROR: $e");
      isLoading = false;
    }
  }


  String? getProfileImageUrl() {
    if (myProfile == null) return null;

    final image = myProfile!['user_profile_image_url'];

    if (image == null || image.toString().isEmpty) return null;

    return ApiService.imageURL + image;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      body: SingleChildScrollView(
        child: Column(
          children: [

            ///  HEADER SECTION
            Stack(
              clipBehavior: Clip.none,
              children: [

                /// 🔹 BACKGROUND HEADER
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    child: Image.asset(
                      "assets/images/profile.png",
                      fit: BoxFit.fill,
                    ),
                  ),
                ),

                /// 🔹 BACK BUTTON
                Positioned(
                  top: 90,
                  left: 16,
                  child:  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset("assets/Icons/Reply.png", height: 24,color: ColorCode.kHeadingColor,),
                  ),
                ),

                /// 🔹 TITLE (CENTERED)
                const Positioned(
                  top:90 ,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "My Profile",
                      style: TextStyle(
                        color: ColorCode.kHeadingColor,
                        fontSize: 16,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                /// 🔹 PROFILE IMAGE (CUT INTO CURVE)
                Positioned(
                  bottom: -48,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.grey.shade200,
                            child: ClipOval(
                              child: getProfileImageUrl() != null
                                  ? Image.network(
                                getProfileImageUrl()!,
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,

                                /// 🔄 LOADER UNTIL IMAGE LOADS
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;

                                  return Center(
                                    child: SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },

                                /// ❌ IF IMAGE FAILS
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    "assets/Icons/profile.png",
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                                  : Image.asset(
                                "assets/Icons/profile.png",
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),


                        ),
                        /*Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: ColorCode.black
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ),
              ],
            ),



            const SizedBox(height: 60),

            /// 🔹 USER INFO
             Text(
              myProfile?['name'] ?? '',
              style: TextStyle(
                fontFamily: "Outfit",
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
             Text(
              "${myProfile?['email'] ?? ''}",
              style: TextStyle(
                color: ColorCode.kWhiteOpacity60,
                fontFamily: "Outfit",
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 14),

            /// 🔹 EDIT BUTTON
            InkWell(
              onTap: () {
                 Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>  EditProfile(),
                              ),
                            );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                decoration: BoxDecoration(
                  color:  ColorCode.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: "Outfit",
                    color: ColorCode.kHeadingColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),


            Padding(
              padding:  EdgeInsets.all(12),
              child: Divider(color: ColorCode.kDividerWhite12,),
            ),




            _profileMenuCard(),


            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _profileMenuCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("My Account",style: TextStyle(
                    color: ColorCode.white,
                    fontFamily: "Unbounded",
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                ),)
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _menuRow(
                  "assets/images/Heart Angle.png",
                  "Favourites",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>  FavouriteScreen(),
                      ),
                    );
                  },
                ),

                _divider(),
                _menuRow("assets/Icons/calendar_search.png", "Booking History", onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  BookingHistoryScreen(),
                    ),
                  );
                }),
                _divider(),
                _menuRow("assets/Icons/wallet.png", "Payment methods"),
              ],
            ),
          ),

          SizedBox(height: 10,),
          Padding(
            padding:  EdgeInsets.all(12),
            child: Divider(color: ColorCode.kDividerWhite12,),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("Legal",style: TextStyle(
                    color: ColorCode.white,
                    fontFamily: "Unbounded",
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                ),)
              ],
            ),
          ),
          SizedBox(height: 10,),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _menuRow("assets/Icons/note.png", "Terms & Condition"),
                _divider(),
                _menuRow("assets/Icons/help-circle.png", "Help & Support"),
                _divider(),
                _menuRow("assets/Icons/elements.png", "Privacy Policy"),
              ],
            ),
          ),

          Padding(
            padding:  EdgeInsets.all(12),
            child: Divider(color: ColorCode.kDividerWhite12,),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("Settings",style: TextStyle(
                    color: ColorCode.white,
                    fontFamily: "Unbounded",
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                ),)
              ],
            ),
          ),
          SizedBox(height: 10,),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _menuRow("assets/Icons/mobile-navigator-01.png", "App Preferences",
                onTap: () {
          Navigator.push(
          context,
          MaterialPageRoute(
          builder: (_) =>  AppPreferences(),
          ),
          );
          }),
                _divider(),
                _menuRow("assets/Icons/Settings Minimalistic.png" ,"Notifications Settings"),
                _divider(),
                _menuRow(
                  "assets/Icons/Exit.png",
                  "Logout",
                  onTap: _showLogoutBottomSheet,
                ),

              ],
            ),
          ),
        ],
      ),
    );


  }

  Widget _menuRow(String iconPath, String title, {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF3A3A3A),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  iconPath,
                  height: 22,
                  width: 22,
                  color: ColorCode.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: "Outfit",
                  color: ColorCode.white,
                  fontSize: 14,
                ),
              ),
            ),
            Image.asset(
              "assets/Icons/rightside.png",
              height: 20,
              width: 20,
              color: ColorCode.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Colors.white12,
      ),
    );
  }

  void _showLogoutBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// DRAG INDICATOR
              Container(
                height: 5,
                width: 30,
                margin:  EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: ColorCode.kWhiteOpacity70,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),


               Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: "Unbounded",
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              /// SUBTITLE
              const Text(
                "Are you sure you want to log out?",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  fontFamily: "Outfit",
                ),
              ),
              SizedBox(height: 14),

              Divider(
                height: 1,
                color: ColorCode.kDividerWhite12,
              ),

               SizedBox(height: 10),



              /// BUTTONS
              Row(
                children: [
                  /// CANCEL
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side:  BorderSide(color: ColorCode.kWhiteOpacity60),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child:  Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontFamily: "Unbounded",
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// LOGOUT
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await SharedService.logout(); // 🔥 clear all prefs

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => NewLoginScreen()),
                              (route) => false,
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor:  ColorCode.kButtonColor,
                        padding:  EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child:  Text(
                        "Yes, Logout",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ColorCode.kHeadingColor,
                          fontFamily: "Unbounded",
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
