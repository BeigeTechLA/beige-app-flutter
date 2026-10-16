import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/route_names.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../domain/entities/booking_wizard_step.dart';
import '../providers/creative_brief_notifier.dart';
import '../widgets/create_project_app_bar.dart';
import '../widgets/wizard_bottom_bar.dart';

/// Screen 4 of the Book-a-Shoot v2 flow — the Creative Brief.
///
/// Captures an optional narrative and inspiration links, then saves them via
/// `PUT /bookings/:id/details`. Both fields are optional; Continue always
/// advances (an empty brief is valid).
class CreativeBriefScreen extends ConsumerStatefulWidget {
  const CreativeBriefScreen({
    super.key,
    required this.bookingId,
    this.contentType,
    this.shootTypeName,
  });

  final int bookingId;
  final String? contentType;
  final String? shootTypeName;

  @override
  ConsumerState<CreativeBriefScreen> createState() =>
      _CreativeBriefScreenState();
}

class _CreativeBriefScreenState extends ConsumerState<CreativeBriefScreen> {
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _linksController = TextEditingController();

  @override
  void dispose() {
    _detailsController.dispose();
    _linksController.dispose();
    super.dispose();
  }

  /// Splits the free-text links field into a clean `reference_links` array.
  List<String> _parseLinks(String raw) => raw
      .split(RegExp(r'[\n,]+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _continue() async {
    final ok = await ref
        .read(creativeBriefNotifierProvider.notifier)
        .save(
          bookingId: widget.bookingId,
          additionalDetails: _detailsController.text.trim(),
          referenceLinks: _parseLinks(_linksController.text),
        );
    if (!mounted) return;
    if (ok) {
      context.pushNamed(
        RouteNames.partnerPreference,
        extra: {
          'bookingId': widget.bookingId,
          'contentType': widget.contentType,
          'shootTypeName': widget.shootTypeName,
        },
      );
    } else {
      final msg = ref.read(creativeBriefNotifierProvider).errorMessage;
      TopMessage.show(context, msg ?? 'Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving =
        ref.watch(creativeBriefNotifierProvider).status ==
        CreativeBriefStatus.saving;

    return AppScaffold(
      hasAppBar: true,
      useSafeArea: true,
      appBar: const CreateProjectAppBar(
        step: BookingWizardStep.creativeBrief,
        title: 'More Details',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHWide),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How Do You Want To Beige It',
              style: AppTextStyles.titleSmall.copyWith(color: AppColors.white),
            ),
            AppSpacing.verticalXl,
            AppTextField(
              label: 'Additional Details',
              controller: _detailsController,
              keyboardType: TextInputType.multiline,
              maxLines: 6,
            ),
            AppSpacing.verticalBase,
            AppTextField(
              label: 'Add inspiration',
              hint: 'Share any links to inspo or reference content.',
              controller: _linksController,
              keyboardType: TextInputType.url,
              maxLines: 2,
            ),
          ],
        ),
      ),
      bottomNavigationBar: WizardBottomBar(
        onBack: () => context.pop(),
        onContinue: saving ? null : _continue,
      ),
    );
  }
}
