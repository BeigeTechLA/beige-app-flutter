import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/route_names.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/loading.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../domain/entities/booking_flow_enums.dart';
import '../../domain/entities/booking_wizard_step.dart';
import '../providers/shoot_type_v2_notifier.dart';
import '../widgets/create_project_app_bar.dart';
import '../widgets/gradient_radio.dart';
import '../widgets/wizard_bottom_bar.dart';

/// Screen 2 of the Book-a-Shoot v2 flow — pick the shoot type (saved by name).
class ShootTypeV2Screen extends ConsumerStatefulWidget {
  const ShootTypeV2Screen({
    super.key,
    required this.bookingId,
    this.contentType,
  });

  final int bookingId;
  final String? contentType;

  @override
  ConsumerState<ShootTypeV2Screen> createState() => _ShootTypeV2ScreenState();
}

class _ShootTypeV2ScreenState extends ConsumerState<ShootTypeV2Screen> {
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(shootTypeV2NotifierProvider.notifier).load(),
    );
  }

  /// Reads the image path from whichever key the catalogue uses.
  String? _imagePath(Map<String, dynamic> item) {
    for (final key in const [
      'image',
      'image_url',
      'imageUrl',
      'thumbnail',
      'icon',
      'photo',
      'cover_image',
    ]) {
      final v = item[key]?.toString();
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  String _imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    // Already absolute (server may return full CDN URLs).
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '${ApiEndpoints.imageUrl}$path';
  }

  Future<void> _continue(List<Map<String, dynamic>> shootTypes) async {
    if (_selectedIndex < 0 || _selectedIndex >= shootTypes.length) {
      TopMessage.show(context, 'Please select shoot type');
      return;
    }
    final name = shootTypes[_selectedIndex]['name']?.toString() ?? '';

    final ok = await ref
        .read(shootTypeV2NotifierProvider.notifier)
        .selectShootType(bookingId: widget.bookingId, shootTypeName: name);

    if (!mounted) return;
    if (ok) {
      context.pushNamed(
        RouteNames.whenWhere,
        extra: {
          'bookingId': widget.bookingId,
          'contentType': widget.contentType,
          'shootTypeName': name,
        },
      );
    } else {
      final msg = ref.read(shootTypeV2NotifierProvider).errorMessage;
      TopMessage.show(context, msg ?? 'Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shootTypeV2NotifierProvider);
    final shootTypes = state.shootTypes;
    final isBusy =
        state.status == ShootTypeV2Status.loading ||
        state.status == ShootTypeV2Status.saving;

    return AppScaffold(
      hasAppBar: true,
      useSafeArea: true,
      appBar: const CreateProjectAppBar(step: BookingWizardStep.shootType),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenHWide),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              switch (ContentTypeV2.fromApiValue(widget.contentType)) {
                ContentTypeV2.videographer => 'Video Shoot Type',
                ContentTypeV2.photographer => 'Photo Shoot Type',
                ContentTypeV2.both => 'Photo & Video Shoot Type',
                null => 'Shoot Type',
              },
              style: AppTextStyles.titleSmall.copyWith(color: AppColors.white),
            ),
            Expanded(
              child: state.status == ShootTypeV2Status.loading
                  ? const Center(child: AppImageLoader(size: 60))
                  : ListView.builder(
                      cacheExtent: 4000,
                      itemCount: shootTypes.length,
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      itemBuilder: (context, index) =>
                          _card(shootTypes[index], index),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: WizardBottomBar(
        onBack: () => context.pop(),
        onContinue: (_selectedIndex >= 0 && !isBusy)
            ? () => _continue(shootTypes)
            : null,
      ),
    );
  }

  Widget _card(Map<String, dynamic> item, int index) {
    final description = [
      item['description']?.toString().trim(),
      (item['tags'] as List?)?.join(' , ').trim(),
      item['subtitle']?.toString().trim(),
    ].whereType<String>().where((text) => text.isNotEmpty).firstOrNull;
    final selected = _selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => setState(() => _selectedIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: AppRadii.xxlAll,
              child: SizedBox(
                height: 125,
                width: 120,
                child: CachedNetworkImage(
                  imageUrl: _imageUrl(_imagePath(item)),
                  fit: BoxFit.cover,
                  placeholder: (_, _) => const AppImageLoader(size: 60),
                  errorWidget: (_, _, _) => const Icon(
                    Icons.broken_image,
                    color: AppColors.neutralGrey,
                  ),
                ),
              ),
            ),
            AppSpacing.gapHBase,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item['name']?.toString() ?? '',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  if (description != null)
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white70,
                      ),
                    ),
                ],
              ),
            ),
            AppSpacing.gapHMd,
            GradientRadio(selected: selected),
          ],
        ),
      ),
    );
  }
}
