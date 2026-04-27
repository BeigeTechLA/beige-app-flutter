import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../core/network/api_endpoints.dart';
import '../app/colors.dart';
import '../features/profile/presentation/providers/favourites_notifier.dart';

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
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () => context.pop(),
                child: SvgPicture.asset(
                  "assets/svg/back.svg",
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            /// TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                " Favourites",
                style: TextStyle(
                  fontFamily: "Unbounded",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : favourites.isEmpty
                      ? const Center(
                          child: Text(
                            "No Favourite Data",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: favourites.length,
                          itemBuilder: (context, index) {
                            final item = favourites[index];
                            final int? creatorId =
                                item['crew_member_id'];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
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
                                              "assets/svg/imag_placeholder.svg",
                                              width: double.infinity,
                                              height: 220,
                                              fit: BoxFit.cover,
                                            ),

                                      /// REMOVE BUTTON
                                      Positioned(
                                        top: 10,
                                        right: 10,
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
                                            "assets/svg/Heart_COLOR.svg",
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
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite,
                    color: AppColors.primary, size: 18),
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
                  child: const Icon(Icons.close,
                      color: Colors.white, size: 18),
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
