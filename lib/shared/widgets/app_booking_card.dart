import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/assets.dart';
import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';
import 'scale_clamped_text.dart';

enum AppBookingCardActionStyle { filled, outline }

class AppBookingCard extends StatelessWidget {
  const AppBookingCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.actionLabel,
    this.subtitle,
    this.onTap,
    this.onActionTap,
    this.actionStyle = AppBookingCardActionStyle.filled,
    this.trailingAction,
    this.height = 312,
    this.margin = const EdgeInsets.only(
      top: AppSpacing.xl,
      bottom: AppSpacing.base,
    ),
  });

  final String imagePath;
  final String title;
  final String? subtitle;
  final String actionLabel;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;
  final AppBookingCardActionStyle actionStyle;
  final Widget? trailingAction;
  final double height;
  final EdgeInsetsGeometry margin;

  static final BorderRadius _cardRadius = BorderRadius.circular(AppRadii.huge);
  static const double _actionHeight = 45;

  @override
  Widget build(BuildContext context) {
    final subtitleText = subtitle?.trim();

    return SizedBox(
      height: height,
      child: Material(
        color: AppColors.transparent,
        borderRadius: _cardRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          child: Stack(
            children: [
              Positioned.fill(child: _BookingCardImage(imagePath: imagePath)),
              // const Positioned.fill(child: _BookingCardTopGradient()),
              const Positioned.fill(child: _BookingCardBottomGradient()),
              Positioned(
                left: AppSpacing.base,
                right: AppSpacing.base,
                bottom: AppSpacing.base,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    if (subtitleText != null && subtitleText.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white70,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: _actionHeight,
                            child: _BookingCardActionButton(
                              label: actionLabel,
                              style: actionStyle,
                              onPressed: onActionTap,
                            ),
                          ),
                        ),
                        if (trailingAction != null) ...[
                          const SizedBox(width: AppSpacing.smd),
                          SizedBox(
                            height: _actionHeight,
                            child: Center(child: trailingAction),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingCardTopGradient extends StatelessWidget {
  const _BookingCardTopGradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: const [0.5, 0.75, 1],
          colors: [
            AppColors.transparent,
            AppColors.surfaceDeep.withValues(alpha: 0.6),
            AppColors.surfaceDeep,
          ],
        ),
      ),
    );
  }
}

class _BookingCardBottomGradient extends StatelessWidget {
  const _BookingCardBottomGradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.34, 0.58, 0.78, 1],
          colors: [
            AppColors.transparent,
            AppColors.surfaceDeep.withValues(alpha: 0.78),
            AppColors.surfaceDeep.withValues(alpha: 0.96),
            AppColors.surfaceDeep,
          ],
        ),
      ),
    );
  }
}

class _BookingCardImage extends StatelessWidget {
  const _BookingCardImage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final source = imagePath.trim();

    if (source.isEmpty) {
      return _placeholder();
    }

    if (_isSvgAsset(source)) {
      return SvgPicture.asset(source, fit: BoxFit.cover);
    }

    if (_isAsset(source)) {
      return Image.asset(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return Image.network(
      source,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  bool _isAsset(String value) => value.startsWith('assets/');

  bool _isSvgAsset(String value) =>
      _isAsset(value) && value.toLowerCase().endsWith('.svg');

  Widget _placeholder() {
    return SvgPicture.asset(AppAssets.imagePlaceholder, fit: BoxFit.cover);
  }
}

class _BookingCardActionButton extends StatelessWidget {
  const _BookingCardActionButton({
    required this.label,
    required this.style,
    required this.onPressed,
  });

  final String label;
  final AppBookingCardActionStyle style;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final textColor = switch (style) {
      AppBookingCardActionStyle.filled => AppColors.textHeading,
      AppBookingCardActionStyle.outline => AppColors.white,
    };

    final child = ScaleClampedText(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.buttonLarge.copyWith(color: textColor),
        ),
      ),
    );

    final shape = RoundedRectangleBorder(borderRadius: AppRadii.roundAll);

    return switch (style) {
      AppBookingCardActionStyle.filled => ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: textColor,
          disabledBackgroundColor: AppColors.disabled,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          shape: shape,
          splashFactory: NoSplash.splashFactory,
        ),
        child: child,
      ),
      AppBookingCardActionStyle.outline => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          disabledForegroundColor: AppColors.white38,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          side: const BorderSide(color: AppColors.white60, width: 1.1),
          shape: shape,
          splashFactory: NoSplash.splashFactory,
        ),
        child: child,
      ),
    };
  }
}
