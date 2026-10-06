import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:beige/app/assets.dart';
import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/shared/widgets/loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';
import 'package:beige/shared/widgets/top_message.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_shoot_type_notifier.dart';

/// Screen 2 — "What are you shooting?" Shared catalogue with the original list design; saves the exact
/// selected shoot-type name.
class BookingShootTypeScreen extends ConsumerStatefulWidget {
  const BookingShootTypeScreen({super.key});

  @override
  ConsumerState<BookingShootTypeScreen> createState() =>
      _BookingShootTypeScreenState();
}

class _BookingShootTypeScreenState
    extends ConsumerState<BookingShootTypeScreen> {
  String? _selectedName;

  @override
  void initState() {
    super.initState();
    _selectedName = ref.read(bookingFlowControllerProvider).shootTypeName;
  }

  Future<void> _continue() async {
    if (ref.read(bookingShootTypeNotifierProvider).isLoading) return;
    final name = _selectedName;
    if (name == null) {
      TopMessage.show(context, 'Please pick a shoot type');
      return;
    }
    final ok = await ref
        .read(bookingShootTypeNotifierProvider.notifier)
        .submit(name);
    if (!mounted) return;
    if (ok) {
      context.pushNamed(RouteNames.bookingSchedule);
    } else {
      TopMessage.show(
        context,
        ref.read(bookingShootTypeNotifierProvider).error ??
            'Something went wrong',
      );
    }
  }

  void _handleBack() {
    if (context.canPop()) context.pop();
  }

  String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) return path;
    return '${ApiEndpoints.imageUrl}$path';
  }

  String get _title => switch (ref
      .watch(bookingFlowControllerProvider)
      .contentType) {
    BookingContentType.videographer => 'Video Shoot Type',
    BookingContentType.photographer => 'Photo Shoot Type',
    BookingContentType.photographerVideographer => 'Photo & Video Shoot Type',
    null => 'Shoot Type',
  };

  @override
  Widget build(BuildContext context) {
    final catalogue = ref.watch(shootTypeCatalogueProvider);
    final isLoading = ref.watch(bookingShootTypeNotifierProvider).isLoading;

    return AppScaffold(
      hasAppBar: true,
      useSafeArea: true,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: _handleBack,
                child: SvgPicture.asset(AppAssets.back, height: 24),
              ),
            ), //
            Text(
              "Create Project",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            // 🔹 Step Text (Right)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "1/3",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: List.generate(3, (index) {
                bool isActive = index == 0; // current step (1/3)

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary, // grey background
                      borderRadius: AppRadii.enormousAll,
                    ),
                    child: isActive
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 5,
                              width: 70, // 🔥 colored portion only
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: AppRadii.enormousAll,
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                );
              }),
            ),
            AppSpacing.verticalXl,
            Row(
              children: [
                Text(
                  _title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            Expanded(
              child: catalogue.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (_, _) => _ErrorRetry(
                  onRetry: () => ref.invalidate(shootTypeCatalogueProvider),
                ),
                data: (shootTypes) => shootTypes.isEmpty
                    ? Center(
                        child: Text(
                          'No shoot types available right now.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        cacheExtent: 4000,
                        itemCount: shootTypes.length,
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final item = shootTypes[index];
                          final String tagsText = item.description ?? '';

                          final imagePath = item.imageUrl;
                          final fullImageUrl = _getFullImageUrl(imagePath);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// 🔹 IMAGE CARD
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: isLoading
                                    ? null
                                    : () => setState(
                                        () => _selectedName = item.name,
                                      ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadii.lgAll,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      /// 🔹 LEFT IMAGE
                                      ClipRRect(
                                        borderRadius: AppRadii.xxlAll,
                                        child: SizedBox(
                                          height: 125,
                                          width: 120,
                                          child: CachedNetworkImage(
                                            imageUrl: fullImageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const AppImageLoader(size: 60),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(
                                                      Icons.broken_image,
                                                      color:
                                                          AppColors.neutralGrey,
                                                    ),
                                          ),
                                        ),
                                      ),

                                      AppSpacing.gapHBase,

                                      /// 🔹 CENTER TEXT SECTION
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            /// Title
                                            Text(
                                              item.name,
                                              style: AppTextStyles.labelLarge
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.white,
                                                  ),
                                            ),

                                            Text(
                                              tagsText,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                    color: AppColors.white70,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      AppSpacing.gapHMd,

                                      /// 🔹 RIGHT RADIO BUTTON
                                      InkWell(
                                        child: Container(
                                          height: 25,
                                          width: 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: _selectedName == item.name
                                                ? const LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      AppColors
                                                          .goldGradientLight,
                                                      AppColors
                                                          .goldGradientDark,
                                                    ],
                                                  )
                                                : null,
                                            border: Border.all(
                                              color: AppColors.white54,
                                            ),
                                          ),
                                          child: _selectedName == item.name
                                              ? const Center(
                                                  child: CircleAvatar(
                                                    radius: 3,
                                                    backgroundColor:
                                                        AppColors.black,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),

      /// ✅ BOTTOM BAR (FIXED)
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.smd),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : _handleBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    side: const BorderSide(color: AppColors.neutralGrey),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.mld,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
                  ),
                  child: Text(
                    "Back",
                    style: AppTextStyles.labelLarge.copyWith(
                      fontFamily: AppAssets.fontUnbounded,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              AppSpacing.gapHMd,
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedName == null || isLoading
                      ? null
                      : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedName == null
                        ? AppColors
                              .goldGradientLight // disabled
                        : AppColors.primary, // enabled
                    foregroundColor: _selectedName == null
                        ? AppColors.greyShade400
                        : AppColors.black,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.mld,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
                  ),
                  child: Text(
                    isLoading ? "Saving..." : "Continue",
                    style: AppTextStyles.labelLarge.copyWith(
                      fontFamily: AppAssets.fontUnbounded,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Couldn't load shoot types.",
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          ),
          AppSpacing.verticalMd,
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
