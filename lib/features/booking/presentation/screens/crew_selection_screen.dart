import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../app/assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/features/booking/presentation/providers/crew_selection_notifier.dart';
import 'package:beige/shared/widgets/loading.dart' show AppLoader;
import 'package:beige/shared/layouts/app_scaffold.dart';

class CrewSelectionScreen extends ConsumerStatefulWidget {
  final int ShootTypeId;
  final int bookingId;
  final int contentTypeId;

  const CrewSelectionScreen({
    super.key,
    required this.ShootTypeId,
    required this.bookingId,
    required this.contentTypeId,
  });

  @override
  ConsumerState<CrewSelectionScreen> createState() =>
      _CrewSelectionScreenState();
}

class _CrewSelectionScreenState extends ConsumerState<CrewSelectionScreen> {
  bool _isPopping = false;
  bool _isNavigating = false;

  void _handleBack() {
    if (_isPopping) return;
    if (!context.canPop()) return;
    _isPopping = true;
    context.pop();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _isPopping = false;
    });
  }

  void _goToReviewConfirm() {
    if (_isNavigating) return;
    _isNavigating = true;
    context.pushNamed(
      RouteNames.reviewConfirm,
      pathParameters: {'bookingId': widget.bookingId.toString()},
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _isNavigating = false;
    });
  }

  int getRequired(int roleId) {
    final rr = ref
        .read(crewSelectionNotifierProvider(widget.bookingId))
        .requiredByRole;
    return rr[roleId.toString()] ?? rr[roleId] ?? 0;
  }

  int getHeld(int roleId) {
    final hr = ref
        .read(crewSelectionNotifierProvider(widget.bookingId))
        .heldByRole;
    return hr[roleId.toString()] ?? hr[roleId] ?? 0;
  }

  int currentStep = 1;
  bool isAdded = false;

  Set<int> favouriteUsers = {};
  final List<String> options = [
    "Top Rated",
    "Nearest",
    "Newest Profiles",
    // "A to Z",
  ];

  String _getSortKey(int index) {
    switch (index) {
      case 0:
        return "top_rated";
      case 1:
        return "nearest";
      case 2:
        return "newest";
      case 3:
        return "a_z";
      default:
        return "nearest";
    }
  }

  int getRoleIdByContentType(int contentTypeId, String roleName) {
    final name = roleName.toLowerCase();

    /// VIDEO ONLY
    if (contentTypeId == 1) return 1;

    /// PHOTO ONLY
    if (contentTypeId == 2) return 2;

    /// BOTH
    if (contentTypeId == 3) {
      if (name.contains("photographer")) return 2;
      if (name.contains("video")) return 1;
    }

    return 1;
  }

  /// 🔥 ROLE NAME → ROLE ID mapping
  int _mapRoleName(String roleName) {
    final name = roleName.toLowerCase();

    if (name.contains("video")) return 1;
    if (name.contains("photo")) return 2;

    return 1; // default (kabhi 0 nahi)
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _addFavourite(int userId) async {
    // Favourites managed via CreativeRepository (already migrated in Group 4)
  }

  Future<void> _removeFavourite(int userId) async {
    // Favourites managed via CreativeRepository (already migrated in Group 4)
  }

  Future<bool> _addHolds({
    required int creativeUserId,
    required int roleId,
  }) async {
    final success = await ref
        .read(crewSelectionNotifierProvider(widget.bookingId).notifier)
        .addHold(
          bookingId: widget.bookingId,
          crewMemberId: creativeUserId,
          roleId: roleId,
        );

    if (!success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to add hold")));
    }

    // Refresh holds to get updated summary
    if (success) {
      await ref
          .read(crewSelectionNotifierProvider(widget.bookingId).notifier)
          .refreshHolds(widget.bookingId);
    }

    return success;
  }

  Future<bool> _removeHolds({required int creativeUserId}) async {
    final success = await ref
        .read(crewSelectionNotifierProvider(widget.bookingId).notifier)
        .removeHold(bookingId: widget.bookingId, crewMemberId: creativeUserId);

    if (!success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to remove hold")));
    }

    if (success) {
      await ref
          .read(crewSelectionNotifierProvider(widget.bookingId).notifier)
          .refreshHolds(widget.bookingId);
    }

    return success;
  }

  Future<void> _filterCrew({required String sort}) async {
    await ref
        .read(crewSelectionNotifierProvider(widget.bookingId).notifier)
        .filterCrew(bookingId: widget.bookingId, sort: sort);
  }

  int getRoleId(dynamic roleData) {
    if (roleData is List && roleData.isNotEmpty) {
      return int.tryParse(roleData.first.toString()) ?? 0;
    }
    return int.tryParse(roleData.toString()) ?? 0;
  }

  int getSelectedCountByRole(int roleId) {
    final st = ref.read(crewSelectionNotifierProvider(widget.bookingId));
    int count = 0;

    for (final match in st.crewMatches) {
      final int uid = match['crew_member_id'] ?? 0;

      final roleData = match['role_id'];
      final List roles = roleData is List ? roleData : [roleData];
      bool hasRole = roles.any((r) => int.tryParse(r.toString()) == roleId);

      if (hasRole && st.addedCrewUserIds.contains(uid)) {
        count++;
      }
    }

    return count;
  }

  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '${ApiEndpoints.imageUrl}$path';
  }

  @override
  Widget build(BuildContext context) {
    final crewState = ref.watch(
      crewSelectionNotifierProvider(widget.bookingId),
    );
    final crewMatches = crewState.crewMatches;
    final nearbyCreators = crewState.nearbyCreators;
    final otherCreators = crewState.otherCreators;

    final isLoading = crewState.status == CrewSelectionStatus.loading;

    final addedCrewUserIds = crewState.addedCrewUserIds;
    final heldByRole = crewState.heldByRole;
    final requiredByRole = crewState.requiredByRole;

    /// 🔥 CHECK LOCATION BASED CREATORS
    final bool hasLocationCreators = crewMatches.isNotEmpty;

    /// 🔥 DISPLAY LIST
    final List<dynamic> displayCreators = hasLocationCreators
        ? crewMatches
        : otherCreators;

    /// 🔥 SHOW BOOKED CARD
    final bool showLocationCard =
        !hasLocationCreators && otherCreators.isNotEmpty;

    return AppScaffold(
      hasAppBar: true,
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
            ),
            Text(
              "More Details",
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
            ),
            // 🔹 Step Text (Right)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "2/3",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontFamily: AppAssets.fontOutfit,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
            child: Column(
              children: [
                Row(
                  children: List.generate(3, (index) {
                    double fillWidth = 0;

                    if (index < currentStep) {
                      // ✅ Completed step (FULL)
                      fillWidth = double.infinity;
                    } else if (index == currentStep) {
                      // 🟡 Current step (HALF)
                      fillWidth = 140.44;
                    } else {
                      fillWidth = 0;
                    }

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary, // grey background
                          borderRadius: BorderRadius.circular(64),
                        ),
                        child: fillWidth > 0
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  height: 5,
                                  width: fillWidth == double.infinity
                                      ? null
                                      : fillWidth,
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

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select Your Dream Team",
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _openFilterDialog(context, (sortKey) {
                          _filterCrew(sort: sortKey);
                        });
                      },
                      child: SvgPicture.asset(AppAssets.filter, height: 24),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      /// 🔥 LOCATION NOT FOUND CARD
                      /// 🔥 LOCATION NOT FOUND CARD
                      if (showLocationCard)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: AppRadii.hugeAll,
                          ),
                          child: Column(
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  AppAssets.saleIcon,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                "Our creators around \nyour location are booked ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppAssets.fontUnbounded,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                "Looks like no creators are available right now, but our sales expert can help you find a great match.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.white60,
                                ),
                              ),

                              SizedBox(height: 10),

                              Center(
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  child: Divider(
                                    color: AppColors.dividerDark,
                                    thickness: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      /// TITLE
                      if (!hasLocationCreators && otherCreators.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "  Browse Other Creative Partners", //
                            style: AppTextStyles.labelLarge.copyWith(
                              fontFamily: AppAssets.fontUnbounded,
                              color: AppColors.white,
                            ),
                          ),
                        ),

                      /// CREW LIST
                      ...displayCreators.map((item) {
                        /// ✅ SAFE ID (NO CRASH)
                        final int creativeUserId = item['crew_member_id'] ?? 0;

                        final int userId = creativeUserId;

                        /// ✅ SAFE ROLE ID
                        final roleData = item['role_id'];
                        final int roleId = (roleData is List)
                            ? int.tryParse(roleData.first.toString()) ?? 0
                            : int.tryParse(roleData.toString()) ?? 0;

                        final bool isAdded = addedCrewUserIds.contains(
                          creativeUserId,
                        );
                        final bool isFavourite = favouriteUsers.contains(
                          creativeUserId,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            height: 237,
                            decoration: BoxDecoration(
                              borderRadius: AppRadii.hugeAll,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                //

                                /// 🔹 IMAGE
                                Positioned.fill(
                                  child: item['profile_photo'] != null
                                      ? Image.network(
                                          _getImageUrl(item['profile_photo']),
                                          fit: BoxFit.cover,
                                          alignment: Alignment.topCenter,
                                          // 🔥 important
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return SvgPicture.asset(
                                                  AppAssets.imagePlaceholder,
                                                  fit: BoxFit.contain,
                                                  height: 25,
                                                );
                                              },
                                        )
                                      : Image.asset(
                                          AppAssets.creativeCardBg,
                                          fit: BoxFit.contain,
                                          height: 25,
                                        ),
                                ),

                                /// 🔹 GRADIENT
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppColors.transparent,
                                          AppColors.black.withValues(
                                            alpha: 0.75,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: const [0.5, 0.75, 1],
                                      colors: [
                                        AppColors.transparent,
                                        AppColors.surfaceDeep.withValues(
                                          alpha: 0.6,
                                        ),
                                        AppColors.surfaceDeep,
                                      ],
                                    ),
                                  ),
                                ),

                                /// 🔹 FAV ICON
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (isFavourite) {
                                        setState(() {
                                          favouriteUsers.remove(userId);
                                        });

                                        await _removeFavourite(userId);
                                        _showFavouriteToast(
                                          "Removed from Favourite",
                                        );
                                      } else {
                                        setState(() {
                                          favouriteUsers.add(userId);
                                        });

                                        await _addFavourite(userId);
                                        _showFavouriteToast(
                                          "Added to Favourite",
                                        );
                                      }
                                    },
                                    child: SvgPicture.asset(
                                      isFavourite
                                          ? AppAssets.heartFilled
                                          : AppAssets.heart,
                                      height: 22,
                                      width: 22,
                                    ),
                                  ),
                                ),

                                /// 🔹 BOTTOM INFO
                                Positioned(
                                  left: 14,
                                  right: 14,
                                  bottom: 14,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      /// LEFT INFO
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          /*   Row(
                                              children: [
                                                const Icon(Icons.star,
                                                    color: AppColors.amber, size: 14),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "${item['average_rating'] ?? '0'} (${item['total_reviews'] ?? 0})",
                                                  style: const TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),*/
                                          const SizedBox(height: 6),
                                          Text(
                                            item['name'] ?? '',
                                            style: AppTextStyles.labelLarge
                                                .copyWith(
                                                  color: AppColors.white,
                                                ),
                                          ),
                                          Text(
                                            item['role_name'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontFamily: AppAssets.fontOutfit,
                                              color: AppColors.white70,
                                            ),
                                          ),
                                        ],
                                      ),

                                      /// RIGHT BUTTONS
                                      Row(
                                        children: [
                                          /// 🔥 ADD / REMOVE BUTTON
                                          /// 🔥 ADD / REMOVE BUTTON
                                          if (!showLocationCard)
                                            InkWell(
                                              onTap: () async {
                                                try {
                                                  /// ✅ DIRECT ID
                                                  final int creativeUserId =
                                                      item['crew_member_id'] ??
                                                      0;

                                                  final roleData =
                                                      item['role_id'];

                                                  /// ✅ SAFE ROLE ID
                                                  final int roleId =
                                                      (roleData is List)
                                                      ? int.tryParse(
                                                              roleData.first
                                                                  .toString(),
                                                            ) ??
                                                            0
                                                      : int.tryParse(
                                                              roleData
                                                                  .toString(),
                                                            ) ??
                                                            0;

                                                  if (creativeUserId == 0)
                                                    return;

                                                  /// 🔴 REMOVE
                                                  if (addedCrewUserIds.contains(
                                                    creativeUserId,
                                                  )) {
                                                    setState(() {
                                                      addedCrewUserIds.remove(
                                                        creativeUserId,
                                                      );
                                                    });

                                                    final success =
                                                        await _removeHolds(
                                                          creativeUserId:
                                                              creativeUserId,
                                                        );

                                                    if (success) {
                                                      await ref
                                                          .read(
                                                            crewSelectionNotifierProvider(
                                                              widget.bookingId,
                                                            ).notifier,
                                                          )
                                                          .refreshHolds(
                                                            widget.bookingId,
                                                          );
                                                    } else {
                                                      setState(() {
                                                        addedCrewUserIds.add(
                                                          creativeUserId,
                                                        );
                                                      });
                                                    }

                                                    return;
                                                  }

                                                  /// 🟢 ADD FLOW
                                                  int selectedCount =
                                                      getSelectedCountByRole(
                                                        roleId,
                                                      );

                                                  /// 🔥 MAIN FIX
                                                  final int maxAllowed =
                                                      (getRequired(roleId) ??
                                                              0) ==
                                                          0
                                                      ? 10
                                                      : getRequired(roleId)!;

                                                  if (selectedCount >=
                                                      maxAllowed) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          "You can add only $maxAllowed ${item['role_name']}",
                                                        ),
                                                      ),
                                                    );

                                                    return;
                                                  }

                                                  /// ✅ UI FIRST
                                                  setState(() {
                                                    addedCrewUserIds.add(
                                                      creativeUserId,
                                                    );
                                                  });

                                                  final success =
                                                      await _addHolds(
                                                        creativeUserId:
                                                            creativeUserId,
                                                        roleId: roleId,
                                                      );

                                                  if (success) {
                                                    await ref
                                                        .read(
                                                          crewSelectionNotifierProvider(
                                                            widget.bookingId,
                                                          ).notifier,
                                                        )
                                                        .refreshHolds(
                                                          widget.bookingId,
                                                        );
                                                  } else {
                                                    setState(() {
                                                      addedCrewUserIds.remove(
                                                        creativeUserId,
                                                      );
                                                    });
                                                  }
                                                } catch (e) {
                                                  debugPrint("ERROR: $e");
                                                }
                                              },

                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: isAdded
                                                      ? AppColors.errorLight
                                                      : AppColors.primary,
                                                  borderRadius:
                                                      AppRadii.roundAll,
                                                  border: isAdded
                                                      ? Border.all(
                                                          color:
                                                              AppColors.error,
                                                        )
                                                      : null,
                                                ),
                                                child: Text(
                                                  isAdded
                                                      ? "Remove"
                                                      : "Add to Crew",
                                                  style: AppTextStyles
                                                      .buttonSmall
                                                      .copyWith(
                                                        color: isAdded
                                                            ? AppColors.error
                                                            : AppColors.black,
                                                      ),
                                                ),
                                              ),
                                            ),

                                          if (!showLocationCard)
                                            const SizedBox(width: 8),

                                          /// 🔹 DETAILS BUTTON
                                          InkWell(
                                            onTap: () {
                                              context.pushNamed(
                                                RouteNames.recommendedDetails,
                                                extra: {
                                                  'id': item['crew_member_id'],
                                                  'bookingId': widget.bookingId,
                                                },
                                              );
                                            },
                                            child: SvgPicture.asset(
                                              AppAssets.homeViewProfile,
                                              color: AppColors.white,
                                              height: 36,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isLoading) const AppLoader(),
        ],
      ),

      bottomNavigationBar: SafeArea(
        bottom: true,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: AppColors.transparent,
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 🔥 SHOW ONLY WHEN NO LOCATION DATA
                  if (showLocationCard)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          ref
                              .read(
                                crewSelectionNotifierProvider(
                                  widget.bookingId,
                                ).notifier,
                              )
                              .markStepCompleted();
                          context.pushNamed(
                            RouteNames.reviewConfirm,
                            pathParameters: {
                              'bookingId': widget.bookingId.toString(),
                            },
                          );
                        },
                        child: Text(
                          "Complete your Shoot",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white70,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                  /// 🔥 MAIN BUTTON
                  SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        /// 🔴 IF NO DATA → SALES FLOW
                        if (showLocationCard) {
                          showSalesDialog(context);
                          return;
                        }

                        /// 🟢 NORMAL FLOW
                        for (final userId in addedCrewUserIds) {
                          final matches = displayCreators
                              .where((e) => e['crew_member_id'] == userId)
                              .toList();

                          if (matches.isEmpty) continue;

                          final roleId =
                              int.tryParse(
                                matches.first['role_id'].toString(),
                              ) ??
                              0;

                          await _addHolds(
                            creativeUserId: userId,
                            roleId: roleId,
                          );
                        }

                        ref
                            .read(
                              crewSelectionNotifierProvider(
                                widget.bookingId,
                              ).notifier,
                            )
                            .markStepCompleted();
                        context.pushNamed(
                          RouteNames.reviewConfirm,
                          pathParameters: {
                            'bookingId': widget.bookingId.toString(),
                          },
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.lgAll,
                        ),
                      ),

                      child: Text(
                        showLocationCard
                            ? "Contact With Sales"
                            : "Continue with ${addedCrewUserIds.length.toString().padLeft(2, '0')} ${addedCrewUserIds.length == 1 ? "Member" : "Members"}",
                        style: AppTextStyles.buttonMedium.copyWith(
                          fontFamily: AppAssets.fontUnbounded,
                          color: AppColors.black,
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
    );
  }

  void _openFilterDialog(
    BuildContext context,
    Function(String sortKey) onApply,
  ) {
    int selectedIndex = 1;
    RangeValues priceRange = const RangeValues(100, 15000);

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: AppColors.black.withValues(alpha: 0.6),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: AppColors.transparent,
                child: Container(
                  width: double.infinity,
                  padding: AppSpacing.cardInsets,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// TOP INDICATOR
                        Center(
                          child: Container(
                            width: 35,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.white70,
                              borderRadius: AppRadii.hugeAll,
                            ),
                          ),
                        ),

                        /// HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Filter By",
                              style: AppTextStyles.titleSmall.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            InkWell(
                              onTap: () => context.pop(),
                              child: const Icon(
                                Icons.close,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        Divider(color: AppColors.white.withValues(alpha: 0.15)),
                        const SizedBox(height: 16),

                        /// 🔹 SORT CARD (FIXED)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Sort By",
                                style: TextStyle(
                                  fontFamily: AppAssets.fontOutfit,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(height: 12),

                              ...List.generate(options.length, (index) {
                                return InkWell(
                                  onTap: () {
                                    setState(() => selectedIndex = index);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          options[index],
                                          style: TextStyle(
                                            fontFamily: AppAssets.fontOutfit,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.white70,
                                          ),
                                        ),

                                        /// ✅ GRADIENT RADIO (index valid here)
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: selectedIndex == index
                                                ? const LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      AppColors.primary,
                                                      // light shade
                                                      AppColors.primaryDark,
                                                      // dark shade
                                                    ],
                                                  )
                                                : null,
                                            border: Border.all(
                                              color: AppColors.white38,
                                            ),
                                          ),
                                          child: selectedIndex == index
                                              ? Center(
                                                  child: Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration:
                                                        const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color:
                                                              AppColors.black,
                                                        ),
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        /// PRICE RANGE
                        /*    Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            // color: AppColors.background,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Price Range",
                                style: TextStyle(
                                  fontFamily: AppAssets.fontOutfit,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white,
                                ),
                              ),
                              RangeSlider(
                                values: priceRange,
                                min: 100,
                                max: 15000,
                                activeColor: AppColors.primary,
                                inactiveColor: AppColors.white24,
                                onChanged: (values) {
                                  setState(() => priceRange = values);
                                },
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Minimum\n\$${priceRange.start.toInt()}",
                                    style: const TextStyle(
                                      color: AppColors.white70,
                                      fontSize: 11,
                                      fontFamily: AppAssets.fontUnbounded,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    "Maximum\n\$${priceRange.end.toInt()}",
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      color: AppColors.white70,
                                      fontSize: 11,
                                      fontFamily: AppAssets.fontUnbounded,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),*/
                        const SizedBox(height: 16),

                        /// BUTTONS
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: AppRadii.xlAll,
                                  border: Border.all(color: AppColors.white60),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedIndex = 0;
                                      priceRange = const RangeValues(
                                        100,
                                        15000,
                                      );
                                    });
                                  },
                                  child: Text(
                                    "Clear All",
                                    style: AppTextStyles.labelLarge.copyWith(
                                      fontFamily: AppAssets.fontUnbounded,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: AppRadii.xlAll,
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    final sortKey = _getSortKey(selectedIndex);

                                    context.pop();

                                    onApply(sortKey); // 🔥 YAHI MAIN LINE HAI
                                  },
                                  child: Text(
                                    "Apply",
                                    style: AppTextStyles.labelLarge.copyWith(
                                      fontFamily: AppAssets.fontUnbounded,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showFavouriteToast(String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 100,
        left: 16,
        right: 16,
        child: Material(
          color: AppColors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppRadii.lgAll,
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontFamily: AppAssets.fontOutfit,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => overlayEntry.remove(),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.white,
                    size: 18,
                  ),
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

  void _showNoCrewPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: AppColors.black.withValues(alpha: 0.7),
      builder: (context) {
        return Center(
          child: Container(
            width: 380,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: AppColors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 🔹 ICON
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceVariant,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 TITLE
                  const Text(
                    "No Crew Selected?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppAssets.fontUnbounded,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// 🔹 DESCRIPTION
                  Text(
                    "You are choosing to continue without adding any team members.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white70,
                      height: 1.4,
                    ),
                  ),
                  Text(
                    "Beige's team will create the best talent for you based on your needs.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  /// 🔹 BUTTONS
                  Row(
                    children: [
                      /// Go Back Button
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: AppRadii.lgAll,
                            border: Border.all(color: AppColors.white24),
                          ),
                          child: TextButton(
                            onPressed: () {
                              context.pop();
                            },
                            child: const Text(
                              "Go Back & Select",
                              style: TextStyle(
                                color: AppColors.white,
                                fontFamily: AppAssets.fontOutfit,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      /// Yes Continue Button
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: AppRadii.lgAll,
                          ),
                          child: TextButton(
                            onPressed: () {
                              if (_isNavigating) return;
                              Navigator.of(context).pop();
                              _goToReviewConfirm();
                            },
                            child: const Text(
                              "Yes, Continue",
                              style: TextStyle(
                                color: AppColors.black,
                                fontFamily: AppAssets.fontOutfit,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showSalesDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.hugeAll),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 🔥 IMPORTANT
              children: [
                /// 🔥 SMALL ICON / LOTTIE
                SizedBox(
                  child: Lottie.asset(
                    AppAssets.lottieSuccess,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 12),

                /// 🔹 TITLE
                Text(
                  "Request Received",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.goldParchment,
                  ),
                ),

                const SizedBox(height: 8),

                /// 🔹 DESCRIPTION
                Text(
                  "Our Sales team will shortly reach out to you to finalize your creative requirements.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white70,
                  ),
                ),

                const SizedBox(height: 16),

                /// 🔹 BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 45, // 🔽 reduce
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldParchment,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text(
                      "Got It",
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 13,
                        fontFamily: AppAssets.fontUnbounded,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
