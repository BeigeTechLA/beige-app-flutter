import 'dart:io';

import 'package:beige/MyProfile/my_profile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../utility/ColorCode.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, // ✅ open gallery
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              /// 🔹 BACK BUTTON
              Positioned(
                top: 90,
                left: 16,
                child:  InkWell(
                  onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => MyProfile()),
                      );
                  },
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
                    "Edit Profile",
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
                      InkWell(
                        onTap: () {
                          debugPrint("✏️ Edit icon clicked");
                          _pickImage();
                        },
                        child: Container(
                          padding:  EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                :  AssetImage("assets/Icons/profile.png"),
                          ),



                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 2,
                        child: InkWell(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque, // 🔥 extra safety
                            onTap: () {
                              debugPrint("✏️ Edit icon clicked");
                              _pickImage();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 22,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),




                    ],
                  ),
                ),
              ),

            ],
          ),



          const SizedBox(height: 60),

          /// 🔹 USER INFO
          const Text(
            "John Smith",
            style: TextStyle(
              fontFamily: "Outfit",
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "johnsmith@gmail.com | +91 98765 43210",
            style: TextStyle(
              color: ColorCode.kWhiteOpacity60,
              fontFamily: "Outfit",
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 14),
          Padding(
            padding:  EdgeInsets.all(15),
            child: Divider(color: ColorCode.kDividerWhite12,),
          ),

          Padding(
            padding:  EdgeInsets.all(20.0),
            child: Column(
              children: [

                TextField(
                // controller: emailController,
                cursorColor: ColorCode.white,

                style: const TextStyle(
                  color: ColorCode.white, // typed text color
                ),

                decoration: InputDecoration(
                  labelText: "Name*",
                  floatingLabelBehavior: FloatingLabelBehavior.always,

                  labelStyle: const TextStyle(
                    color: ColorCode.kWhiteOpacity70, // #1D1D1B 60% opacity
                  ),

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),

                  /// ⭐ 0.5px BORDER + OPACITY COLOR
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
                      width: 0.5,                       // 🔥 exact 0.5px
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
                      width: 0.5,                          // focus border thicker
                    ),
                  ),

                  floatingLabelStyle: const TextStyle(
                    color: ColorCode.kWhiteOpacity70,
                  ),)

            ),
                SizedBox(height: 20,),
                TextField(
                  // controller: emailController,
                    cursorColor: ColorCode.white,

                    style: const TextStyle(
                      color: ColorCode.white, // typed text color
                    ),

                    decoration: InputDecoration(
                      labelText: "Email ID*",
                      floatingLabelBehavior: FloatingLabelBehavior.always,

                      labelStyle: const TextStyle(
                        color: ColorCode.kWhiteOpacity70, // #1D1D1B 60% opacity
                      ),

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),

                      /// ⭐ 0.5px BORDER + OPACITY COLOR
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
                          width: 0.5,                       // 🔥 exact 0.5px
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
                          width: 0.5,                          // focus border thicker
                        ),
                      ),

                      floatingLabelStyle: const TextStyle(
                        color: ColorCode.kWhiteOpacity70,
                      ),)

                ),
                SizedBox(height: 20,),
                TextField(
                  // controller: emailController,
                    cursorColor: ColorCode.white,

                    style: const TextStyle(
                      color: ColorCode.white, // typed text color
                    ),

                    decoration: InputDecoration(
                      labelText: "Location*",
                      floatingLabelBehavior: FloatingLabelBehavior.always,

                      labelStyle: const TextStyle(
                        color: ColorCode.kWhiteOpacity70, // #1D1D1B 60% opacity
                      ),

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),

                      /// ⭐ 0.5px BORDER + OPACITY COLOR
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
                          width: 0.5,                       // 🔥 exact 0.5px
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
                          width: 0.5,                          // focus border thicker
                        ),
                      ),

                      floatingLabelStyle: const TextStyle(
                        color: ColorCode.kWhiteOpacity70,
                      ),)

                ),
                SizedBox(height: 20,),
                TextField(
                  // controller: emailController,
                    cursorColor: ColorCode.white,

                    style: const TextStyle(
                      color: ColorCode.white, // typed text color
                    ),

                    decoration: InputDecoration(
                      labelText: "Change Password*",
                      floatingLabelBehavior: FloatingLabelBehavior.always,

                      labelStyle: const TextStyle(
                        color: ColorCode.kWhiteOpacity70, // #1D1D1B 60% opacity
                      ),

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),

                      /// ⭐ 0.5px BORDER + OPACITY COLOR
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
                          width: 0.5,                       // 🔥 exact 0.5px
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
                          width: 0.5,                          // focus border thicker
                        ),
                      ),

                      floatingLabelStyle: const TextStyle(
                        color: ColorCode.kWhiteOpacity70,
                      ),)

                ),
                SizedBox(height: 20,),
              ],
            ),
          )



        ],
      ),
      bottomNavigationBar: Padding(
        padding:  EdgeInsets.all(22),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              /* Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddOnServices(),
                ),
              );*/
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorCode.kButtonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
            Text(
              "Update Profile",
              style: TextStyle(
                fontFamily: "Unbounded",
                fontWeight: FontWeight.w500,
                color: ColorCode.kHeadingColor,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
