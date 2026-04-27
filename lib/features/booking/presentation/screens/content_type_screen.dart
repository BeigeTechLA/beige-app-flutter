import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/features/booking/presentation/providers/content_type_notifier.dart';

class ContentTypeScreen extends ConsumerStatefulWidget {
  final int? value;
  final int? specialtyId;
  final bool fromHome;
  const ContentTypeScreen({super.key, this.specialtyId, this.value, this.fromHome = false});

  @override
  ConsumerState<ContentTypeScreen> createState() => _ContentTypeScreenState();
}

class _ContentTypeScreenState extends ConsumerState<ContentTypeScreen> {
  int? bookingId;
  List<int> selectedContentTypeIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      selectedContentTypeIds = [widget.value!];
    }
  }

  bool get isSelectAll =>
      selectedContentTypeIds.contains(1) &&
      selectedContentTypeIds.contains(2);


  void _handleSelection(int contentTypeId) {
    setState(() {
      if (contentTypeId == 3) {
        // ✅ Toggle Select All: if both already selected → clear, else select both
        if (isSelectAll) {
          selectedContentTypeIds.clear();
        } else {
          selectedContentTypeIds = [1, 2];
        }
        return;
      }

      // ✅ Individual toggle — works independently of Select All
      if (selectedContentTypeIds.contains(contentTypeId)) {
        selectedContentTypeIds.remove(contentTypeId);
      } else {
        selectedContentTypeIds.add(contentTypeId);
      }
    });
  }



  Future<void> _continueBooking() async {
    if (selectedContentTypeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select content type")),
      );
      return;
    }

    final int contentTypeToSend =
        isSelectAll ? 3 : selectedContentTypeIds.first;

    await ref.read(contentTypeNotifierProvider.notifier).continueBooking(
      specialtyId: widget.specialtyId,
      contentType: contentTypeToSend,
      existingBookingId: bookingId,
    );

    if (!mounted) return;

    final state = ref.read(contentTypeNotifierProvider);

    if (state.status == ContentTypeStatus.success && state.bookingId != null) {
      bookingId = state.bookingId;

      final result = await context.pushNamed<int>(
        RouteNames.videoShootType,
        extra: {
          'bookingId': bookingId!,
          'contentTypeId': contentTypeToSend,
        },
      );

      if (result != null) {
        bookingId = result;
      }
    } else if (state.status == ContentTypeStatus.error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage ?? "Something went wrong")),
        );
      }
    }
  }
  bool get isContinueEnabled =>
      selectedContentTypeIds.isNotEmpty &&
      ref.read(contentTypeNotifierProvider).status != ContentTypeStatus.loading;

  @override
  Widget build(BuildContext context) {
    final contentState = ref.watch(contentTypeNotifierProvider);
    final isLoading = contentState.status == ContentTypeStatus.loading;

    return Scaffold(

        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: widget.fromHome   // 👈 condition
                    ? InkWell(
                  onTap: () => context.pop(),
                  child: SvgPicture.asset(
                    "assets/svg/back.svg",
                    height: 24,
                  ),
                )
                    : const SizedBox(), // 👈 hide
              ),
              /// Center Title
              Center(
                child: Text(
                  "Create Project",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              /// Right Step Text
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "1/3",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        body: Stack(
          children: [

            /// MAIN UI
            SafeArea(
              child: AbsorbPointer(
                absorbing: isLoading, // 🔥 API call ke time click disable
                child: Opacity(
                  opacity: isLoading ? 0.6 : 1.0, // 🔥 thoda blur/disable feel
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [

                        /// STEP PROGRESS BAR
                        Row(
                          children: List.generate(3, (index) {
                            bool isActive = index == 0;

                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                height: 5,
                                decoration: BoxDecoration(
                                  color: AppColors.textSecondary,
                                  borderRadius: BorderRadius.circular(64),
                                ),
                                child: isActive
                                    ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 5,
                                    width: 35.44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(64),
                                    ),
                                  ),
                                )
                                    : const SizedBox(),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 20),

                        /// TITLE
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Content Type",
                            style: TextStyle(
                              fontFamily: "Unbounded",
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// SELECT ALL
                        _buildOption(
                          title: "Select All",
                          activeImage:"assets/new_home/selectall.png",
                          value: isSelectAll,
                          onTap: () => _handleSelection(3),
                        ),

                        /// VIDEOGRAPHY
                        _buildOption(
                          title: "Videography",
                          activeImage:"assets/new_home/Videography.png",

                          value: selectedContentTypeIds.contains(1),
                          onTap: () => _handleSelection(1),
                        ),

                        /// PHOTOGRAPHY
                        _buildOption(
                          title: "Photography",
                          activeImage:"assets/new_home/photography.png",
                          value: selectedContentTypeIds.contains(2),
                          onTap: () => _handleSelection(2),
                        ),

                        _buildOption(
                          title: "Studios (Coming Soon)",
                          value: false,
                          isDisabled: true,
                          activeImage:"assets/new_home/stuido_new.png",
                          onTap: null,
                        ),

                        /// EDITING
                        _buildOption(
                          title: "Editing Only (Coming Soon)",
                          value: false,
                          isDisabled: true,
                          activeImage:"assets/new_home/edit_new.png",
                          onTap: null,
                        ),

                        /// LIVESTREAM
                        _buildOption(
                          title: "Livestreaming (Coming Soon)",
                          value: false,
                          isDisabled: true,
                          activeImage:"assets/new_home/Livestream_new.png",
                          onTap: null,
                        ),

                        const Spacer(),

                        SizedBox(

                          height: 56,
                          child: ElevatedButton(
                            onPressed: isContinueEnabled ? _continueBooking : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isContinueEnabled
                                  ? AppColors.primary
                                  : Colors.grey.shade700,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Continue",
                              style: TextStyle(
                                color: AppColors.backgroundOpacity70,
                                fontSize: 12,
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ),

              ),


            ),
          ],
        ));


  }
  Widget _buildOption({
    required String title,
    required String activeImage,
    required bool value,
    required VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            /// ICON
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDisabled? AppColors.iconBackground: AppColors.iconBackground,
              ),
              child: Center(
                child: ImageFiltered(
                  imageFilter: isDisabled
                      ? ImageFilter.blur(sigmaX: 0.6, sigmaY: 0.6)
                      : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                  child: Opacity(
                    opacity: isDisabled ? 0.7 : 1,
                    child: Image.asset(
                      width: 30,
                      height: 22,
                      value ? activeImage : activeImage,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            /// TITLE
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDisabled
                      ? AppColors.white60
                      : value
                      ? AppColors.primary
                      : Colors.white,
                ),
              ),
            ),

            /// CHECK BOX (CLICKABLE)
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value
                      ? AppColors.primary
                      : AppColors.borderLight,
                  width: 0.5,
                ),
                color: value
                    ? AppColors.primary
                    : Colors.transparent,
              ),
              child: value
                  ? const Icon(
                Icons.check,
                size: 16,
                color: Colors.black,
              )
                  : null,
            ),

          ],
        ),
      ),
    );
  }
}