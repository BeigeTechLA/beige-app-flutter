import 'package:flutter/material.dart';
import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/text_styles.dart';
import '../../../../app/spacing.dart';
import '../../../../app/radii.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/features/profile/presentation/providers/favourites_notifier.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final favState = ref.watch(favouritesNotifierProvider);
    final isLoading = favState.status == FavouritesStatus.loading;
    final favourites = favState.favourites;

    ref.listen<FavouritesState>(favouritesNotifierProvider, (prev, next) {
      if (next.toastMessage != null) {
        _showFavouriteToast(next.toastMessage!);
        ref.read(favouritesNotifierProvider.notifier).clearToast();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// BACK BUTTON
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: InkWell(
                onTap: () => context.pop(),
                child: SvgPicture.asset(
                  AppAssets.back,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            AppSpacing.verticalSmd,

            /// TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: Text(
                " Favourites",
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : favourites.isEmpty
                      ? Center(
                          child: Text(
                            "No Favourite Data",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.smd),
                          itemCount: favourites.length,
                          itemBuilder: (context, index) {
                            final item = favourites[index];
                            final int? creatorId =
                                item['crew_member_id'];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.smd),
                              child: ClipRRect(
                                borderRadius: AppRadii.hugeAll,
                                child: SizedBox(
                                  height: 220,
                                  child: Stack(
                                    children: [
                                      /// IMAGE
                                      (item['profile_image_url'] !=
                                                  null &&
                                              item['profile_image_url']
                                                  .toString()
                                                  .isNotEmpty)
                                          ? Image.network(
                                              ApiEndpoints.imageUrl +
                                                  item[
                                                      'profile_image_url'],
                                              width: double.infinity,
                                              height: 220,
                                              fit: BoxFit.fill,
                                            )
                                          : SvgPicture.asset(
                                              AppAssets.imagePlaceholder,
                                              width: double.infinity,
                                              height: 220,
                                              fit: BoxFit.cover,
                                            ),

                                      /// REMOVE BUTTON
                                      Positioned(
                                        top: AppSpacing.smd,
                                        right: AppSpacing.smd,
                                        child: GestureDetector(
                                          onTap: () {
                                            if (creatorId != null) {
                                              ref
                                                  .read(
                                                      favouritesNotifierProvider
                                                          .notifier)
                                                  .removeFavourite(
                                                    creativeId:
                                                        creatorId,
                                                    index: index,
                                                  );
                                            }
                                          },
                                          child: SvgPicture.asset(
                                            AppAssets.heartFilled,
                                            height: 22,
                                            width: 22,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFavouriteToast(String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + AppSpacing.smd,
        left: AppSpacing.base,
        right: AppSpacing.base,
        child: Material(
          color: AppColors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceStats,
              borderRadius: AppRadii.lgAll,
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite,
                    color: AppColors.primary, size: 18),
                AppSpacing.gapHSmd,
                Expanded(
                  child: Text(
                    message,
                    style: AppTextStyles.bodyCompact.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => overlayEntry.remove(),
                  child: const Icon(Icons.close,
                      color: AppColors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
