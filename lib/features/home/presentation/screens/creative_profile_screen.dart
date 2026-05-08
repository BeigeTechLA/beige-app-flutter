import 'package:flutter/material.dart';
import '../../../../app/assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/features/creative/presentation/providers/creative_profile_notifier.dart';

class CreativeProfileScreen extends ConsumerStatefulWidget {
  final int id;

  const CreativeProfileScreen({super.key, required this.id});

  @override
  ConsumerState<CreativeProfileScreen> createState() =>
      _CreativeProfileScreenState();
}

class _CreativeProfileScreenState extends ConsumerState<CreativeProfileScreen> {
  late PageController _portfolioController;

  final List<String> weekDaysOrder = const [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  @override
  void initState() {
    super.initState();

    _portfolioController = PageController(
      initialPage: 1000,
      viewportFraction: 0.70,
    );
  }

  @override
  void dispose() {
    _portfolioController.dispose();
    super.dispose();
  }

  String _imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '${ApiEndpoints.imageUrl}$path';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(creativeProfileNotifierProvider(widget.id));

    final creative = state.creative;
    final stats = state.stats;
    final about = state.about;
    final portfolio = state.portfolio;

    final weeklyAvailability = state.weeklyAvailability;

    final isLoading = state.status == CreativeProfileStatus.loading;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TOP IMAGE + ACTIONS
                Stack(
                  children: [
                    Image.network(
                      _imageUrl(creative?['profile_image_url']),
                      height: 360,
                      width: double.infinity,
                      fit: BoxFit.fill,
                      errorBuilder: (_, __, ___) => SvgPicture.asset(
                        AppAssets.imagePlaceholder,
                        height: 360,
                        width: double.infinity,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Container(
                      height: 360,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.black.withValues(alpha: 0.5),
                            AppColors.transparent,
                            AppColors.black.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: AppSpacing.base,
                      right: AppSpacing.base,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => context.pop(),
                            child: SvgPicture.asset(AppAssets.back, height: 24),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.base,
                      bottom: AppSpacing.xxl,
                      right: AppSpacing.base,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                creative?['name'] ?? "",
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                              AppSpacing.verticalXs,
                              Text(
                                creative?['primary_title'] ?? "",
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                /// INFO STATS
                Padding(
                  padding: AppSpacing.insetsHBase,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      _infoCard(
                        icon: Icons.group_outlined,
                        value: "${stats?['clients_count'] ?? 0}",
                        title: "Clients",
                      ),
                      _infoCard(
                        icon: Icons.verified_outlined,
                        value: "${stats?['years_experience'] ?? 0} yrs",
                        title: "Experience",
                      ),
                    ],
                  ),
                ),

                AppSpacing.verticalXl,
                _divider(),

                /// ABOUT
                _sectionTitle("About Creator"),
                _sectionText(about?['bio'] ?? "No information available"),
                AppSpacing.verticalXl,
                _divider(),

                /// PORTFOLIO
                _sectionTitle("Portfolio"),
                Column(
                  children: [
                    SizedBox(
                      height: 260,
                      child: portfolio.isEmpty
                          ? Center(
                              child: SvgPicture.asset(
                                AppAssets.imagePlaceholder,
                              ),
                            )
                          : PageView.builder(
                              controller: _portfolioController,
                              itemCount: 10000,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final realIndex = index % portfolio.length;
                                final item = portfolio[realIndex];

                                final imageUrl = _imageUrl(
                                  item["file_path"] ?? "",
                                );

                                return AnimatedBuilder(
                                  animation: _portfolioController,
                                  builder: (context, child) {
                                    double value = 0;

                                    if (_portfolioController.hasClients &&
                                        _portfolioController
                                            .position
                                            .haveDimensions) {
                                      value =
                                          (_portfolioController.page ?? 0) -
                                          index;
                                    }

                                    double scale = (1 - (value.abs() * 0.2))
                                        .clamp(0.8, 1.0);
                                    double angle = value * -0.5;

                                    return Transform(
                                      alignment: value > 0
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateY(angle)
                                        ..scaleByDouble(scale, scale, scale, 1),
                                      child: Opacity(
                                        opacity: (1 - value.abs()).clamp(
                                          0.5,
                                          1.0,
                                        ),
                                        child: Center(
                                          child: SizedBox(
                                            height: 240,
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.7,
                                            child: child,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: AppRadii.portfolioAll,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.black.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: AppRadii.portfolioAll,
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            SvgPicture.asset(
                                              AppAssets.imagePlaceholder,
                                              fit: BoxFit.cover,
                                            ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
                _divider(),

                /// WEEKLY AVAILABILITY
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base,
                    AppSpacing.xxl,
                    AppSpacing.base,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (weeklyAvailability.isNotEmpty) ...[
                        Text(
                          "Weekly Availability",
                          style: AppTextStyles.titleMedium.copyWith(
                            fontFamily: AppAssets.fontOutfit,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.mld),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.mld),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: AppRadii.hugeAll,
                          ),
                          child: Column(
                            children: weekDaysOrder.map((day) {
                              bool isActive = weeklyAvailability.contains(day);
                              return _availabilityRow(
                                day,
                                isActive,
                                "10:00 am - 10:00 pm",
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.massive),
              ],
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.smd,
      ),
      child: Container(
        height: 1,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.white.withValues(alpha: 0.09),
              AppColors.white.withValues(alpha: 0.09),
              AppColors.white.withValues(alpha: 0.09),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String value,
    required String title,
  }) {
    return Container(
      width: 105,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: AppRadii.lgAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.40),
            AppColors.primary.withValues(alpha: 0.04),
            AppColors.primary.withValues(alpha: 0.28),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.fine),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceStats,
            borderRadius: AppRadii.statsInnerAll,
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: -1,
                child: Container(
                  width: 38,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(AppRadii.xl),
                    ),
                  ),
                  child: Icon(icon, size: 20, color: AppColors.black),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppSpacing.verticalXl,
                  Text(
                    value,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.xxl,
        AppSpacing.base,
        AppSpacing.sm,
      ),
      child: Text(
        text,
        style: AppTextStyles.labelLarge.copyWith(
          fontFamily: AppAssets.fontUnbounded,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _sectionText(String text) {
    return Padding(
      padding: AppSpacing.insetsHBase,
      child: Text(
        text,
        style: AppTextStyles.bodyCompact.copyWith(
          fontWeight: FontWeight.w400,
          color: AppColors.white70,
        ),
      ),
    );
  }

  Widget _availabilityRow(String day, bool isActive, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.online : AppColors.neutralGrey,
              shape: BoxShape.circle,
            ),
          ),
          AppSpacing.gapHMd,
          Expanded(
            child: Text(
              day,
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.online : AppColors.white,
              ),
            ),
          ),
          Text(
            time,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w500,
              color: isActive
                  ? AppColors.online
                  : AppColors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
