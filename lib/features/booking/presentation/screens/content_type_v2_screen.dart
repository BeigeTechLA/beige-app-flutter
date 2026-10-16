import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/route_names.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../domain/entities/booking_flow_enums.dart';
import '../../domain/entities/booking_wizard_step.dart';
import '../providers/content_type_v2_notifier.dart';
import '../widgets/create_project_app_bar.dart';
import '../widgets/wizard_bottom_bar.dart';

/// Screen 1 of the Book-a-Shoot v2 flow — pick the content type.
class ContentTypeV2Screen extends ConsumerStatefulWidget {
  const ContentTypeV2Screen({super.key, this.bookingId, this.contentType});

  /// Existing draft booking (when re-entering / editing the content type).
  final int? bookingId;

  /// Pre-selected `content_type` string from the draft.
  final String? contentType;

  @override
  ConsumerState<ContentTypeV2Screen> createState() =>
      _ContentTypeV2ScreenState();
}

class _ContentTypeV2ScreenState extends ConsumerState<ContentTypeV2Screen> {
  bool _video = false;
  bool _photo = false;
  int? _bookingId;

  @override
  void initState() {
    super.initState();
    _bookingId = widget.bookingId;
    final parsed = ContentTypeV2.fromApiValue(widget.contentType);
    _video =
        parsed == ContentTypeV2.videographer || parsed == ContentTypeV2.both;
    _photo =
        parsed == ContentTypeV2.photographer || parsed == ContentTypeV2.both;
  }

  bool get _selectAll => _video && _photo;
  bool get _hasSelection => _video || _photo;

  ContentTypeV2? get _selection {
    if (_video && _photo) return ContentTypeV2.both;
    if (_video) return ContentTypeV2.videographer;
    if (_photo) return ContentTypeV2.photographer;
    return null;
  }

  void _toggleSelectAll() => setState(() {
    final next = !_selectAll;
    _video = next;
    _photo = next;
  });

  Future<void> _continue() async {
    final selection = _selection;
    if (selection == null) {
      TopMessage.show(context, 'Please select content type');
      return;
    }

    await ref
        .read(contentTypeV2NotifierProvider.notifier)
        .submit(contentType: selection, existingBookingId: _bookingId);

    if (!mounted) return;
    final state = ref.read(contentTypeV2NotifierProvider);

    if (state.status == ContentTypeV2Status.success &&
        state.bookingId != null) {
      _bookingId = state.bookingId;
      context.pushNamed(
        RouteNames.shootTypeV2,
        extra: {'bookingId': state.bookingId, 'contentType': state.contentType},
      );
    } else if (state.status == ContentTypeV2Status.error) {
      TopMessage.show(context, state.errorMessage ?? 'Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(contentTypeV2NotifierProvider).status ==
        ContentTypeV2Status.loading;

    return AppScaffold(
      hasAppBar: true,
      useSafeArea: true,
      appBar: const CreateProjectAppBar(step: BookingWizardStep.contentType),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: Opacity(
          opacity: isLoading ? 0.6 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHWide),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Content Type',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _option(
                          title: 'Select All',
                          image: AppAssets.selectAll,
                          value: _selectAll,
                          onTap: _toggleSelectAll,
                        ),
                        _option(
                          title: 'Videography',
                          image: AppAssets.serviceVideography,
                          value: _video,
                          onTap: () => setState(() => _video = !_video),
                        ),
                        _option(
                          title: 'Photography',
                          image: AppAssets.servicePhotography,
                          value: _photo,
                          onTap: () => setState(() => _photo = !_photo),
                        ),
                        _option(
                          title: 'Studios (Coming Soon)',
                          image: AppAssets.serviceStudio,
                          value: false,
                          isDisabled: true,
                          onTap: null,
                        ),
                        _option(
                          title: 'Editing Only (Coming Soon)',
                          image: AppAssets.serviceEditing,
                          value: false,
                          isDisabled: true,
                          onTap: null,
                        ),
                        _option(
                          title: 'Livestreaming (Coming Soon)',
                          image: AppAssets.serviceLivestream,
                          value: false,
                          isDisabled: true,
                          onTap: null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: WizardBottomBar(
        onContinue: _hasSelection && !isLoading ? _continue : null,
      ),
    );
  }

  Widget _option({
    required String title,
    required String image,
    required bool value,
    required VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isDisabled ? null : onTap,
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.iconBackground,
              ),
              child: Center(
                child: Opacity(
                  opacity: isDisabled ? 0.5 : 1,
                  child: Image.asset(image),
                ),
              ),
            ),
            AppSpacing.gapHBase,
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDisabled
                      ? AppColors.white60
                      : value
                      ? AppColors.primary
                      : AppColors.white,
                ),
              ),
            ),
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                borderRadius: AppRadii.smAll,
                border: Border.all(
                  color: value ? AppColors.primary : AppColors.borderLight,
                  width: 0.5,
                ),
                color: value ? AppColors.primary : AppColors.transparent,
              ),
              child: value
                  ? const Icon(Icons.check, size: 16, color: AppColors.black)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
