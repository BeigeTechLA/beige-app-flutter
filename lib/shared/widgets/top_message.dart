import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';

class TopMessage {
  static void show(BuildContext context, String message) {
    final overlay = Overlay.of(context);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Container(color: AppColors.black.withValues(alpha: 0.8)),
            ),
          ),
          Positioned(
            top: 110,
            left: AppSpacing.base,
            right: AppSpacing.base,
            child: Material(
              color: AppColors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.mld,
                ),
                decoration: BoxDecoration(
                  color: AppColors.errorSurface,
                  borderRadius: AppRadii.xlAll,
                  border: Border.all(color: AppColors.errorAccent),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.do_not_disturb,
                      color: AppColors.errorAccent,
                    ),
                    AppSpacing.gapHSmd,
                    Expanded(
                      child: Text(
                        message,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.errorAccent,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        overlayEntry.remove();
                      },
                      child: const Icon(Icons.close, color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
