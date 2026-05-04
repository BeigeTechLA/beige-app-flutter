import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/app/radii.dart';
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

    ref.listen<DeleteAccountState>(deleteAccountNotifierProvider,
        (prev, next) {
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
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 16),

              /// TITLE
              Text(
                "Delete Account",
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamilyDisplay,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "This action will permanently delete your account and all associated data. If you need help or have questions, please contact us at support@beige.com",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.white70,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  fontFamily: AppTextStyles.fontFamilyBody,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
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
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppTextStyles.fontFamilyBody,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Please let us know the reason for deleting your account.",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.white70,
                        fontFamily: AppTextStyles.fontFamilyBody,
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
        padding: const EdgeInsets.all(12.0),
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
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.xlAll,
              ),
            ),
            child: const Text(
              "Continue",
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamilyDisplay,
                fontSize: 14,
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
                  color:
                      isSelected ? AppColors.primary : AppColors.white70,
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
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                reason,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: AppTextStyles.fontFamilyBody,
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
