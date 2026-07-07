import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/route_names.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/loading.dart';

class MeetingScheduledScreen extends ConsumerStatefulWidget {
  const MeetingScheduledScreen({super.key});

  @override
  ConsumerState<MeetingScheduledScreen> createState() =>
      _MeetingScheduledScreenState();
}

class _MeetingScheduledScreenState
    extends ConsumerState<MeetingScheduledScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), _goToList);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToList() {
    if (!mounted) return;
    context.goNamed(RouteNames.meetings);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _goToList();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppSuccessAnimation(height: 180,),
                  AppSpacing.verticalXl,
                  Text(
                    'Meeting Scheduled',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontFamily: AppAssets.fontUnbounded,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.verticalSmd,
                  Text(
                    'Your meeting has been scheduled successfully.\nAll participants have been notified.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white60,
                      fontFamily: AppAssets.fontOutfit,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
