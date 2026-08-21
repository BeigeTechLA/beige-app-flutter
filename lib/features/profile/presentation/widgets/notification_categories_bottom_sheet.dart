import 'package:flutter/material.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/shared/widgets/app_toggle_switch.dart';

class NotificationCategoryItem {
  final String id;
  final String title;
  final String description;
  final IconData iconData;
  bool isEnabled;

  NotificationCategoryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.iconData,
    this.isEnabled = true,
  });
}

class NotificationCategoriesBottomSheet extends StatefulWidget {
  /// Shared, mutable list owned by the caller. The sheet toggles items in place
  /// so the caller sees the changes after the sheet is dismissed. Returns
  /// `true` when the user taps Save, `null`/`false` otherwise.
  final List<NotificationCategoryItem> categories;

  const NotificationCategoriesBottomSheet({super.key, required this.categories});

  static Future<bool?> show(
    BuildContext context,
    List<NotificationCategoryItem> categories,
  ) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          NotificationCategoriesBottomSheet(categories: categories),
    );
  }

  @override
  State<NotificationCategoriesBottomSheet> createState() =>
      _NotificationCategoriesBottomSheetState();
}

class _NotificationCategoriesBottomSheetState
    extends State<NotificationCategoriesBottomSheet> {
  List<NotificationCategoryItem> get _categories => widget.categories;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),

          /// Drag indicator pill
          Container(
            height: 4,
            width: 36,
            decoration: BoxDecoration(
              color: AppColors.white60,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          /// Header: Title + Close Button
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.base,
              right: AppSpacing.xs,
              top: AppSpacing.sm,
              bottom: AppSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Categories",
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            color: AppColors.dividerDark,
            height: 1,
          ),

          /// Categories list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
              itemCount: _categories.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _buildCategoryRow(category);
              },
            ),
          ),

          /// Save Button
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.base,
              right: AppSpacing.base,
              top: AppSpacing.sm,
              bottom: bottomPadding > 0 ? bottomPadding + 8 : AppSpacing.xl,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.massive),
                  ),
                ),
                child: Text(
                  "Save",
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(NotificationCategoryItem category) {
    return Row(
      children: [
        /// Icon container
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              category.iconData,
              size: 22,
              color: AppColors.white,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.base),

        /// Title + Description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                category.description,
                style: AppTextStyles.bodyCompact.copyWith(
                  fontSize: 12,
                  color: AppColors.white60,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        /// Switch Toggle
        AppToggleSwitch(
          value: category.isEnabled,
          onChanged: (val) {
            setState(() {
              category.isEnabled = val;
            });
          },
        ),
      ],
    );
  }
}
