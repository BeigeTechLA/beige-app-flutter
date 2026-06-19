import 'package:flutter/material.dart';

import '../../app/colors.dart';
import '../../app/text_styles.dart';

enum AppAvatarSize { xs, sm, md, lg, xl }

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppAvatarSize.md,
    this.onTap,
  }) : assert(imageUrl != null || name != null, 'Provide imageUrl or name for initials');

  final String? imageUrl;
  final String? name;
  final AppAvatarSize size;
  final VoidCallback? onTap;

  double get _dimension => switch (size) {
        AppAvatarSize.xs => 24,
        AppAvatarSize.sm => 32,
        AppAvatarSize.md => 40,
        AppAvatarSize.lg => 56,
        AppAvatarSize.xl => 72,
      };

  TextStyle get _textStyle => switch (size) {
        AppAvatarSize.xs => AppTextStyles.caption,
        AppAvatarSize.sm => AppTextStyles.labelSmall,
        AppAvatarSize.md => AppTextStyles.labelMedium,
        AppAvatarSize.lg => AppTextStyles.labelLarge,
        AppAvatarSize.xl => AppTextStyles.titleSmall,
      };

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final dim = _dimension;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final Widget avatar = hasImage
        ? CircleAvatar(
            radius: dim / 2,
            backgroundColor: AppColors.surfaceVariant,
            backgroundImage: NetworkImage(imageUrl!),
          )
        : Container(
            width: dim,
            height: dim,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE8EFEC), Color(0xFFBFCBC4)],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: _textStyle.copyWith(
                color: const Color(0xFF1F1F1F),
                fontWeight: FontWeight.w600,
              ),
            ),
          );

    if (onTap == null) return avatar;
    return GestureDetector(onTap: onTap, child: avatar);
  }
}
