import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/core/notifications/domain/notification_preferences.dart';
import 'package:beige/core/notifications/push_preferences_provider.dart';
import 'package:beige/core/notifications/push_session_id.dart';
import 'package:beige/features/profile/presentation/widgets/notification_categories_bottom_sheet.dart';
import 'package:beige/shared/widgets/app_toggle_switch.dart';
import 'package:beige/shared/widgets/loading.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _saving = false;
  bool _loading = true;

  late final List<NotificationCategoryItem> _categories = [
    NotificationCategoryItem(
      id: 'shoots',
      title: 'Shoots',
      description: 'Shoot schedules, assignments, & updates',
      iconData: Icons.camera_alt_outlined,
    ),
    NotificationCategoryItem(
      id: 'payments',
      title: 'Payments',
      description: 'Invoices, payment receipts, & reminders',
      iconData: Icons.attach_money_rounded,
    ),
    NotificationCategoryItem(
      id: 'messages',
      title: 'Messages',
      description: 'Direct messages and mentions',
      iconData: Icons.chat_bubble_outline_rounded,
    ),
    NotificationCategoryItem(
      id: 'meetings',
      title: 'Meetings',
      description: 'Meeting invites, reminders, & updates',
      iconData: Icons.calendar_today_outlined,
    ),
    NotificationCategoryItem(
      id: 'proposals',
      title: 'Proposals',
      description: 'Proposal shares, approvals, & feedback',
      iconData: Icons.description_outlined,
    ),
    NotificationCategoryItem(
      id: 'files',
      title: 'Files',
      description: 'File uploads, shares, & review requests',
      iconData: Icons.folder_open_outlined,
    ),
    NotificationCategoryItem(
      id: 'system',
      title: 'System',
      description: 'System alerts & account updates',
      iconData: Icons.settings_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  /// Hydrates the toggles from the saved server preferences. On failure the
  /// hardcoded defaults (all-on) are kept.
  Future<void> _loadPreferences() async {
    final sessionId = await PushSessionId.getOrCreate();
    final result = await ref
        .read(pushPreferencesRepositoryProvider)
        .getPreferences(sessionId: sessionId);

    if (!mounted) return;
    result.fold((_) {}, (prefs) {
      setState(() {
        _pushEnabled = prefs.pushEnabled;
        for (final category in _categories) {
          final saved = prefs.topics[category.id];
          if (saved != null) category.isEnabled = saved;
        }
      });
    });
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _openCategories() async {
    final saved = await NotificationCategoriesBottomSheet.show(
      context,
      _categories,
    );
    if (saved == true) {
      await _savePreferences();
    }
  }

  Future<void> _savePreferences() async {
    if (_saving) return;
    setState(() => _saving = true);

    final preferences = NotificationPreferences(
      pushEnabled: _pushEnabled,
      topics: {for (final c in _categories) c.id: c.isEnabled},
    );
    final sessionId = await PushSessionId.getOrCreate();
    final result = await ref
        .read(pushPreferencesRepositoryProvider)
        .updatePreferences(sessionId: sessionId, preferences: preferences);

    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification preferences updated')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// BACK BUTTON
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SvgPicture.asset(
                        AppAssets.back,
                        height: 24,
                        width: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  /// PAGE TITLE & SUBTITLE
                  Text(
                    "Notification Settings",
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Choose how you want to receive notifications",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white60,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  /// PUSH NOTIFICATIONS ROW
                  InkWell(
                    onTap: _pushEnabled ? _openCategories : null,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: AppColors.notifBlueBg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.smartphone_rounded,
                                size: 24,
                                color: AppColors.notifBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.base),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Push Notifications",
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: AppColors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Receive notifications on your mobile device",
                                  style: AppTextStyles.bodyCompact.copyWith(
                                    fontSize: 12,
                                    color: AppColors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          AppToggleSwitch(
                            value: _pushEnabled,
                            onChanged: (val) {
                              setState(() {
                                _pushEnabled = val;
                              });
                              if (val) {
                                _openCategories();
                              } else {
                                _savePreferences();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  /// EMAIL NOTIFICATIONS ROW
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: AppColors.notifPurpleBg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.mail_outline_rounded,
                              size: 24,
                              color: AppColors.notifPurple,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.base),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Email Notifications",
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Receive notifications via email",
                                style: AppTextStyles.bodyCompact.copyWith(
                                  fontSize: 12,
                                  color: AppColors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppToggleSwitch(
                          value: _emailEnabled,
                          onChanged: (val) {
                            setState(() {
                              _emailEnabled = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  /// SMART DELIVERY INFO CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.base),
                    decoration: BoxDecoration(
                      color: AppColors.notifInfoBg,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.notifBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            size: 20,
                            color: AppColors.notifInfoBg,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Smart Delivery",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.notifInfoTitle,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Critical notifications are always sent via push and email, regardless of your preferences. We also suppress notifications when you're actively using the app to reduce interruptions.",
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.notifInfoBody,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  /// FUTURE READY SECTION
                  Row(
                    children: [
                      Text(
                        "Future Ready",
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.notifPurpleBg,
                          borderRadius: BorderRadius.circular(AppRadii.massive),
                        ),
                        child: const Text(
                          "Coming Soon",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.notifPurple,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.base),

                  /// CARD 1: AI NOTIFICATION SUMMARIES
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.base),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AI Notification Summaries",
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Get smart digests like "3 files uploaded and 2 approvals pending"',
                          style: AppTextStyles.bodyCompact.copyWith(
                            fontSize: 13,
                            color: AppColors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  /// CARD 2: WORKFLOW AUTOMATION
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.base),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Workflow Automation",
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Build custom rules like "If proposal approved -> notify finance team"',
                          style: AppTextStyles.bodyCompact.copyWith(
                            fontSize: 13,
                            color: AppColors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
          if (_saving || _loading) const AppLoadingOverlay(),
        ],
      ),
    );
  }
}
