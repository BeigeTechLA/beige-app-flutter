import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/features/profile/presentation/providers/delete_account_notifier.dart';

import '../../../../app/assets.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  String? selectedReason;

  final List<String> reasons = [
    "What's the reason for deleting your account?",
    "Help us understand why you're leaving",
    "I'm not using the app anymore",
    "Others",
  ];

  @override
  Widget build(BuildContext context) {
    final deleteState = ref.watch(deleteAccountNotifierProvider);
    final isLoading = deleteState.status == DeleteAccountStatus.loading;

    ref.listen<DeleteAccountState>(deleteAccountNotifierProvider, (prev, next) {
      if (next.status == DeleteAccountStatus.success) {
        context.pushNamed(RouteNames.deleteAccountOtp);
      } else if (next.status == DeleteAccountStatus.error &&
          next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// BACK BUTTON
              InkWell(
                onTap: () => context.pop(),
                child: SvgPicture.asset(
                  AppAssets.back,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              AppSpacing.verticalBase,

              /// TITLE
              Text(
                "Delete Account",
                style: AppTextStyles.titleSmall.copyWith(
                  fontFamily: AppTextStyles.fontFamilyDisplay,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              AppSpacing.verticalXl,
              Text(
                "This action will permanently delete your account and all associated data. If you need help or have questions, please contact us at support@beige.com",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white70,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              AppSpacing.verticalXl,
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadii.lgAll,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Why do you wish to leave Beige?",
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Please let us know the reason for deleting your account.",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    ...reasons.map((reason) => _buildReasonOption(reason)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    if (selectedReason == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a reason"),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                    ref
                        .read(deleteAccountNotifierProvider.notifier)
                        .requestDelete(selectedReason!);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadii.xlAll),
            ),
            child: Text(
              "Continue",
              style: AppTextStyles.labelLarge.copyWith(
                fontFamily: AppTextStyles.fontFamilyDisplay,
                fontWeight: FontWeight.w500,
                color: AppColors.textHeading,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReasonOption(String reason) {
    final bool isSelected = selectedReason == reason;

    return InkWell(
      onTap: () => setState(() => selectedReason = reason),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.white70,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.mld),
            Expanded(
              child: Text(
                reason,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
