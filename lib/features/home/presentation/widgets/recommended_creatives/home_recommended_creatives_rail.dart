import 'package:flutter/material.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/features/home/data/models/home_model.dart';

import 'home_recommended_creative_card.dart';

/// Horizontal rail under "We Think You'll Love These" — empty-state text
/// when the list is empty, otherwise a horizontal ListView of cards.
class HomeRecommendedCreativesRail extends StatelessWidget {
  final List<Creative> creatives;
  final void Function(int id) onViewProfile;

  const HomeRecommendedCreativesRail({
    super.key,
    required this.creatives,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    if (creatives.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "No Data Found",
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: creatives.length,
        itemBuilder: (context, index) {
          final data = creatives[index];
          /*  final item = featuredCreatives[index];
                        final int userId = item["id"];
                        bool isFavourite = favouriteUsers.contains(userId);*/
          return HomeRecommendedCreativeCard(
            data: data,
            onViewProfile: () => onViewProfile(data.id),
          );
        },
      ),
    );
  }
}
