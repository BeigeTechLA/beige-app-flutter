import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

class MessageDetails extends ConsumerStatefulWidget {

  final String name;
  final String image;

  const MessageDetails({
    super.key,
    required this.name,
    required this.image,
  });

  @override
  ConsumerState<MessageDetails> createState() =>
      _MessageDetailsState();
}

class _MessageDetailsState extends ConsumerState<MessageDetails> {
  bool isParticipantsOpen = false;
  bool isLinkedShootOpen = false;
  bool isSharedFilesOpen = true;

@override

Widget build(BuildContext context) {
return Scaffold(
body:   SingleChildScrollView(
  child: Column(
    children: [
      Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 248,
            width: double.infinity,
            color: AppColors.transparent,
          ),
          SizedBox(
            width: double.infinity,
            height: 200,
            child: ClipRRect(
              borderRadius: AppRadii.bottomHeader,
              child: Image.asset(
                AppAssets.profilePlaceholder,
                fit: BoxFit.cover,
              ),
            ),
          ),
  
          /// BACK BUTTON
          Positioned(
            top: 90,
            left: AppSpacing.base,
            child: InkWell(
              onTap: () => context.pop(true),
              child: SvgPicture.asset(
                AppAssets.back,
                colorFilter: const ColorFilter.mode(
                  AppColors.black,
                  BlendMode.srcIn,
                ),
                height: 24,
              ),
            ),
          ),
  
          /// TITLE
          Positioned(
            top: 90,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Details",
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.textHeading,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
  
          /// PROFILE IMAGE
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xxs),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(widget.image),
                    ),
                  ),
                /*  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
  
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.black12),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: AppColors.black,
                      ),
                    ),
                  ),*/
                ],
              ),
            ),
          ),
        ],
      ),
      AppSpacing.verticalSmd,
  
      /// USER INFO
      Text(
        widget.name,
        style: AppTextStyles.titleMedium.copyWith(
          fontFamily: AppAssets.fontOutfit,
          color: AppColors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      AppSpacing.verticalXxs,
     /* Text(
        "${myProfile?['email'] ?? ''}",
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white60,
          fontWeight: FontWeight.w400,
        ),
      ),*/
  
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
  
            /// SEARCH
            TextField(
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white,
              ),
  
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: AppRadii.lgAll,
                  borderSide: BorderSide.none,
                ),
  
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadii.lgAll,
                  borderSide: BorderSide.none,
                ),
  
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadii.lgAll,
                  borderSide: BorderSide.none,
                ),
  
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
  
                /// SVG SEARCH ICON
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(
                    AppSpacing.md,
                  ),
                  child: SvgPicture.asset(
                    AppAssets.search,
                  ),
                ),
  
  
                prefixIconConstraints:
                const BoxConstraints(
                  minHeight: 20,
                  minWidth: 20,
                ),
  
                hintText: "Search conversation...",
  
                hintStyle:
                AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white30,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xxl,),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.smd,
              ),
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
  
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
              ),
  
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                AppRadii.hugeAll,
  
                border: Border.all(
                  color: AppColors.white10,
                ),
              ),
  
              child: Column(
                children: [
  
                  /// PARTICIPANTS
                  buildCommonTile(
                    title: "Participants (2)",
                    icon: Icons.people_outline,
                    isExpanded: isParticipantsOpen,

                    onTap: () {
                      setState(() {
                        isParticipantsOpen =
                        !isParticipantsOpen;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      // horizontal: AppSpacing.xl,
                      vertical: AppSpacing.smd,
                    ),
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
  
                  /// LINKED SHOOT
                  buildCommonTile(
                    title: "Linked Shoot",
                    icon: Icons.calendar_today_outlined,
                    isExpanded: isLinkedShootOpen,

                    onTap: () {
                      setState(() {
                        isLinkedShootOpen =
                        !isLinkedShootOpen;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      // horizontal: AppSpacing.xl,
                      vertical: AppSpacing.smd,
                    ),
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
                  /// SHARED FILES
                  buildCommonTile(
                    title: "Shared Files (2)",
                    icon: Icons.insert_drive_file_outlined,
                    isExpanded: isSharedFilesOpen,

                    onTap: () {
                      setState(() {
                        isSharedFilesOpen =
                        !isSharedFilesOpen;
                      });
                    },
                  ),
  
                  AppSpacing.verticalMd,
  
                  /// FILE ITEM 2
                 /* buildFileItem(
                    title:
                    "Shot_List_ProductShoot_Jan23.pdf",
                    subtitle: "2.3 MB",
                  ),*/
  
                  AppSpacing.verticalSm,
                ],
              ),
            ),
  
            AppSpacing.verticalXxl,
  
            Container(
              width: double.infinity,
  
              padding: const EdgeInsets.all(
                AppSpacing.base,
              ),
  
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                AppRadii.hugeAll,
  
                border: Border.all(
                  color: AppColors.white10,
                ),
              ),
  
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
  
                  Text(
                    "Notes",
  
                    style: AppTextStyles
                        .titleSmall
                        .copyWith(
                      color:
                      AppColors.white,
                    ),
                  ),
  
                  AppSpacing.verticalSm,
  
                  Text(
                    "Add private notes about this conversation\n(visible to admins only)",
  
                    style: AppTextStyles
                        .bodyMedium
                        .copyWith(
                      color:
                      AppColors.white38,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          
          ],
        ),
      )
          ]
      ),
)
);

}


/// =======================================
/// COMMON TILE
/// =======================================

Widget buildCommonTile({
  required String title,
  required IconData icon,
  bool isExpanded = false,
  VoidCallback? onTap,
}) {
  return InkWell(
    borderRadius: AppRadii.lgAll,
    onTap: onTap,

    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),

      child: Row(
        children: [

          Icon(
            icon,
            size: 20,
            color: AppColors.white,
          ),

          AppSpacing.gapHSm,

          Expanded(
            child: Text(
              title,
              style: AppTextStyles
                  .bodyLarge
                  .copyWith(
                color: AppColors.white,
                fontWeight:
                FontWeight.w500,
              ),
            ),
          ),

          /// OPEN / CLOSE ICON
          AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,

            duration:
            const Duration(
              milliseconds: 250,
            ),

            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.white60,
              size: 24,
            ),
          ),
        ],
      ),
    ),
  );
}

/// =======================================
/// FILE ITEM
/// =======================================

Widget buildFileItem({
  required String title,
  required String subtitle,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.base,
    ),

    child: Row(
      children: [

        Container(
          height: 48,
          width: 48,

          decoration: BoxDecoration(
            color:
            AppColors.surfaceVariant,

            borderRadius:
            AppRadii.mdAll,
          ),

          child: const Icon(
            Icons.folder_open_outlined,
            color: AppColors.primary,
          ),
        ),

        AppSpacing.gapHSm,

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              Text(
                title,

                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,

                style: AppTextStyles
                    .bodyLarge
                    .copyWith(
                  color:
                  AppColors.white,
                ),
              ),

              AppSpacing.verticalXxs,

              Text(
                subtitle,

                style: AppTextStyles
                    .bodyMedium
                    .copyWith(
                  color:
                  AppColors.white38,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}