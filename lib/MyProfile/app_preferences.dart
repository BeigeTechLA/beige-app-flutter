import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../app/colors.dart';
import '../app/route_names.dart';
import '../app/text_styles.dart';
import '../app/radii.dart';
import '../app/assets.dart';

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
                onTap: () => context.pop(),
                child: SvgPicture.asset(
                  AppAssets.back,
                  height: 24,
                  width: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// 🏷 TITLE
              Text(
                "App Preferences",
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamilyDisplay,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),

              const SizedBox(height: 20),


              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  /// 🌙 DARK MODE
             /*     Container(
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
                              images.chando1,
                              height: 24,
                              width: 24,
                              colorFilter: const ColorFilter.mode(
                                ColorCode.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              "Dark Mode",
                              style: TextStyle(
                                color: ColorCode.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 41,
                          height: 26,
                          child: Switch(
                            value: isDarkMode,
                            activeColor: Colors.amber,
                            onChanged: (value) {
                              setState(() {
                                isDarkMode = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),*/




                  SizedBox(height: 20,),

                  /// 🗑 DELETE ACCOUNT
                  InkWell(
                    onTap: () {
                      context.pushNamed(RouteNames.deleteAccount);
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(borderRadius: AppRadii.mdAll,
                        color: AppColors.surfaceVariant,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppAssets.delete2,
                                height: 24,
                                width: 24,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text(
                                "Delete Account",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontFamily: AppTextStyles.fontFamilyBody,
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
                    decoration: BoxDecoration(borderRadius: AppRadii.mdAll,
                      color: AppColors.surfaceVariant,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppAssets.appVersion3,
                          height: 24,
                          width: 24,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
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
