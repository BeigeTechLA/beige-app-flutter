import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/features/creative/presentation/providers/creative_profile_notifier.dart';

class RecommendedCreativeDetailScreen extends ConsumerStatefulWidget {
  final int id;
  final int bookingId;

  const RecommendedCreativeDetailScreen({
    super.key,
    required this.id,
    required this.bookingId,
  });

  @override
  ConsumerState<RecommendedCreativeDetailScreen> createState() =>
      _RecommendedCreativeDetailScreenState();
}

class _RecommendedCreativeDetailScreenState
    extends ConsumerState<RecommendedCreativeDetailScreen> {
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
      viewportFraction: 0.45,
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

    final weeklyAvailabilityJson = state.weeklyAvailabilityJson;
    final weeklyAvailability = weeklyAvailabilityJson != null
        ? List<String>.from(jsonDecode(weeklyAvailabilityJson))
        : <String>[];

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
                        "assets/svg/imag_placeholder.svg",
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
                          stops: const [0.0, 0.4, 0.7, 1.0],
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                            Colors.black,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => context.pop(),
                            child: SvgPicture.asset(
                              "assets/svg/back.svg",
                              height: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 24,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                creative?['name'] ?? "",
                                style: const TextStyle(
                                  fontFamily: "Outfit",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                creative?['primary_title'] ?? "",
                                style: const TextStyle(
                                  fontFamily: "Outfit",
                                  fontSize: 14,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
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

                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: const Divider(
                      color: AppColors.dividerDark,
                      thickness: 1,
                    ),
                  ),
                ),

                /// ABOUT
                _sectionTitle("About Creator"),
                _sectionText(about?['bio'] ?? "No information available"),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: const Divider(
                      color: AppColors.dividerDark,
                      thickness: 1,
                    ),
                  ),
                ),

                /// PORTFOLIO
                _sectionTitle("Portfolio"),
                Column(
                  children: [
                    SizedBox(
                      height: 260,
                      child: portfolio.isEmpty
                          ? Center(
                              child: SvgPicture.asset(
                                "assets/svg/imag_placeholder.svg",
                              ),
                            )
                          : PageView.builder(
                              controller: _portfolioController,
                              itemCount: 10000,
                              clipBehavior: Clip.none,
                              itemBuilder: (context, index) {
                                final realIndex = index % portfolio.length;
                                final item = portfolio[realIndex];

                                final imageUrl =
                                    _imageUrl(item["file_path"] ?? "");

                                return AnimatedBuilder(
                                  animation: _portfolioController,
                                  builder: (context, child) {
                                    double value = 0;
                                    if (_portfolioController
                                        .position.haveDimensions) {
                                      value = index -
                                          (_portfolioController.page ?? 0);
                                    }

                                    double scale =
                                        (1 - (value.abs() * 0.8))
                                            .clamp(0.85, 1.0);
                                    double opacity =
                                        (1 - (value.abs() * 0.9))
                                            .clamp(0.6, 1.0);

                                    return Transform.scale(
                                      scale: scale,
                                      child: Opacity(
                                        opacity: opacity,
                                        child: Center(
                                          child: Container(
                                            width: 176,
                                            height: 236,
                                            margin: const EdgeInsets
                                                .symmetric(horizontal: 4),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                              child: Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (_, __, ___) =>
                                                        SvgPicture.asset(
                                                  "assets/svg/imag_placeholder.svg",
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: const Divider(
                      color: AppColors.dividerDark,
                      thickness: 1,
                    ),
                  ),
                ),

                /// WEEKLY AVAILABILITY
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (weeklyAvailability.isNotEmpty) ...[
                        const Text(
                          "Weekly Availability",
                          style: TextStyle(
                            fontFamily: "Outfit",
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: weekDaysOrder.map((day) {
                              bool isActive =
                                  weeklyAvailability.contains(day);
                              return _availabilityRow(
                                day,
                                isActive,
                                "10:00 am - 10:00 pm",
                              );
                            }).toList(),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Divider(color: Colors.white10),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 40),
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

  Widget _infoCard({
    required IconData icon,
    required String value,
    required String title,
  }) {
    return Container(
      width: 105,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE8D1AB).withValues(alpha: 0.40),
            const Color(0xFFE8D1AB).withValues(alpha: 0.04),
            const Color(0xFFE8D1AB).withValues(alpha: 0.28),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.6),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(11.5),
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
                    color: Color(0xFFE8D1AB),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(14),
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.7),
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
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: "Unbounded",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: "Outfit",
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.white70,
        ),
      ),
    );
  }

  Widget _availabilityRow(String day, bool isActive, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF2ED47A) : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              day,
              style: TextStyle(
                fontFamily: "Outfit",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isActive ? const Color(0xFF2ED47A) : Colors.white,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontFamily: "Outfit",
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? const Color(0xFF2ED47A)
                  : Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
