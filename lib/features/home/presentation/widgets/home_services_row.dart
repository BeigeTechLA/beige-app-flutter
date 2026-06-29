import 'package:flutter/material.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/spacing.dart';

import 'home_service_card.dart';

/// Horizontal "Explore Services" row composing five [HomeServiceCard]s.
class HomeServicesRow extends StatelessWidget {
  final int selectedIndex;
  final AnimationController controller;
  final void Function(int index, String title) onTap;

  const HomeServicesRow({
    super.key,
    required this.selectedIndex,
    required this.controller,
    required this.onTap,
  });

  static const List<({String title, String imagePath})> _items = [
    (title: "Photo", imagePath: AppAssets.homePhotography),
    (title: "Video", imagePath: AppAssets.homeVideography),
    (title: "Editing", imagePath: AppAssets.homeEditing),
    (title: "Livestream", imagePath: AppAssets.homeLivestream),
    (title: "Studio", imagePath: AppAssets.homeStudio),
  ];

  double _serviceCardSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 4 full cards + 30% peek of 5th card
    // each card total width = cardSize + (sm * 2) horizontal padding
    // screenWidth - xl = 4.3 * (cardSize + sm * 2)
    return (screenWidth - AppSpacing.xl) / 4.3 - (AppSpacing.sm * 2);
  }

  @override
  Widget build(BuildContext context) {
    final size = _serviceCardSize(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          for (var i = 0; i < _items.length; i++)
            HomeServiceCard(
              title: _items[i].title,
              imagePath: _items[i].imagePath,
              isSelected: selectedIndex == i,
              size: size,
              controller: controller,
              onTap: () => onTap(i, _items[i].title),
            ),
        ],
      ),
    );
  }
}
