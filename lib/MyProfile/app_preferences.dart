import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../utility/ColorCode.dart';
import '../utility/images.dart';
import 'DeleteAccount/delete_account.dart';
import 'DeleteAccount/delete_account_otp_screen.dart';

class AppPreferences extends StatefulWidget {
  const AppPreferences({super.key});

  @override
  State<AppPreferences> createState() => _AppPreferencesState();
}

class _AppPreferencesState extends State<AppPreferences> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔙 BACK BUTTON
              InkWell(
                onTap: () => Navigator.pop(context),
                child: SvgPicture.asset(
                  images.back,
                  height: 24,
                  width: 24,
                  colorFilter: const ColorFilter.mode(
                    ColorCode.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// 🏷 TITLE
              Text(
                "App Preferences",
                style: TextStyle(
                  fontFamily: "Unbounded",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ColorCode.white,
                ),
              ),

              const SizedBox(height: 20),


              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  /// 🗑 DELETE ACCOUNT
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DeleteAccount()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)
                      ),
                        color: ColorCode.k282828,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                images.delete2,
                                height: 24,
                                width: 24,
                                colorFilter: const ColorFilter.mode(
                                  ColorCode.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text(
                                "Delete Account",
                                style: TextStyle(
                                  color: ColorCode.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.white54),
                        ],
                      ),
                    ),
                  ),




                  SizedBox(height: 20,),

                  /// ℹ APP VERSION
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)
                    ),
                      color: ColorCode.k282828,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          images.appversion3,
                          height: 24,
                          width: 24,
                          colorFilter: const ColorFilter.mode(
                            ColorCode.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          "App Version V1.0",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),




                  SizedBox(height: 20,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
