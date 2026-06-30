import 'package:flutter/material.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/spacing.dart';

import 'home_service_card.dart';

/// Grid-based "Explore Services" container composing five [HomeServiceCard]s.
class HomeServicesRow extends StatelessWidget {
  final Set<int> selectedIndices;
  final AnimationController controller;
  final void Function(int index, String title) onTap;

  const HomeServicesRow({
    super.key,
    required this.selectedIndices,
    required this.controller,
    required this.onTap,
  });

  static const List<({String title, String imagePath})> items = [
    (title: "Photo", imagePath: AppAssets.homePhotography),
    (title: "Video", imagePath: AppAssets.homeVideography),
    (title: "Editing", imagePath: AppAssets.homeEditing),
    (title: "Livestream", imagePath: AppAssets.homeLivestream),
    (title: "Studios", imagePath: AppAssets.homeStudio),
  ];

  double _serviceCardSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // We want 3 columns of equal size.
    // The screen horizontal padding is 20px on left and right.
    // The visual gap between columns is exactly 20px (2 gaps).
    // Total horizontal space taken by margins & gaps = 20 * 2 (margins) + 20 * 2 (gaps) = 80px.
    // Since each card has AppSpacing.sm (8px) internal padding:
    // Layout size = (screenWidth - 80) / 3.
    return (screenWidth - 80) / 3;
  }

  @override
  Widget build(BuildContext context) {
    final size = _serviceCardSize(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl - AppSpacing.sm, // 20 - 8 = 12
      ),
      child: Wrap(
        spacing: 4, // 20px visual gap - 16px (8px padding from both cards)
        runSpacing: 4, // 20px visual gap - 16px (8px padding from both cards)
        children: [
          for (var i = 0; i < items.length; i++)
            HomeServiceCard(
              title: items[i].title,
              imagePath: items[i].imagePath,
              isSelected: selectedIndices.contains(i),
              size: size,
              controller: controller,
              onTap: () => onTap(i, items[i].title),
            ),
        ],
      ),
    );
  }
}
