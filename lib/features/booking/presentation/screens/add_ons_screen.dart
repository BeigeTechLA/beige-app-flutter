import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/route_names.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/app_qty_counter.dart';
import '../../../../shared/widgets/loading.dart';
import '../../domain/entities/booking_flow_enums.dart';
import '../../domain/entities/booking_wizard_step.dart';
import '../providers/add_ons_notifier.dart';
import '../widgets/create_project_app_bar.dart';
import '../widgets/wizard_bottom_bar.dart';

/// Screen 9 of the Book-a-Shoot v2 flow — Optional Add-ons.
///
/// Loads the server catalogue and lets the client add quantities. The subtotal
/// shown here is a local cart preview (rate × qty from catalogue prices); the
/// authoritative totals/fees come from `/review` on the next screen. Selected
/// items are forwarded as `add_on_items: [{slug, quantity}]`.
class AddOnsScreen extends ConsumerStatefulWidget {
  const AddOnsScreen({
    super.key,
    required this.bookingId,
    this.contentType,
    this.shootTypeName,
    this.matchingMethod = MatchingMethod.manual,
    this.selectedCrewIds = const [],
  });

  final int bookingId;
  final String? contentType;
  final String? shootTypeName;
  final MatchingMethod matchingMethod;
  final List<int> selectedCrewIds;

  @override
  ConsumerState<AddOnsScreen> createState() => _AddOnsScreenState();
}

class _AddOnsScreenState extends ConsumerState<AddOnsScreen> {
  /// slug → selected quantity.
  final Map<String, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(addOnsNotifierProvider.notifier).load());
  }

  double _subtotal(List<AddOn> catalogue) {
    var total = 0.0;
    for (final addOn in catalogue) {
      total += addOn.rate * (_quantities[addOn.slug] ?? 0);
    }
    return total;
  }

  List<Map<String, dynamic>> _addOnItems() => [
    for (final entry in _quantities.entries)
      if (entry.value > 0) {'slug': entry.key, 'quantity': entry.value},
  ];

  void _continue() {
    context.pushNamed(
      RouteNames.reviewConfirmV2,
      extra: {
        'bookingId': widget.bookingId,
        'contentType': widget.contentType,
        'shootTypeName': widget.shootTypeName,
        'matchingMethod': widget.matchingMethod.name,
        'selectedCrewIds': widget.selectedCrewIds,
        'addOnItems': _addOnItems(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addOnsNotifierProvider);

    return AppScaffold(
      hasAppBar: true,
      useSafeArea: true,
      appBar: CreateProjectAppBar(
        step: BookingWizardStep.addOns,
        title: 'Optional Add-on',
        method: widget.matchingMethod,
      ),
      body: state.status == AddOnsStatus.loading
          ? const Center(child: AppImageLoader(size: 60))
          : state.status == AddOnsStatus.error
          ? _error(state.errorMessage)
          : _list(state.catalogue),
      bottomNavigationBar: _bottomBar(state.catalogue),
    );
  }

  Widget _list(List<AddOn> catalogue) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHWide),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Want To Add Anything Extra?',
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.white),
          ),
          AppSpacing.verticalBase,
          if (catalogue.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Center(
                child: Text(
                  'No add-ons available for this shoot.\nYou can continue.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.white70),
                ),
              ),
            )
          else
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadii.xlAll,
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Column(
              children: [
                for (var i = 0; i < catalogue.length; i++)
                  _addOnRow(
                    catalogue[i],
                    showDivider: i < catalogue.length - 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addOnRow(AddOn addOn, {required bool showDivider}) {
    final qty = _quantities[addOn.slug] ?? 0;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      addOn.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (addOn.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xxs),
                        child: Text(
                          addOn.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _priceLabel(addOn.rate),
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              qty > 0
                  ? AppQtyCounter(
                      value: qty,
                      onIncrement: () => setState(
                        () => _quantities[addOn.slug] = (qty + 1).clamp(
                          0,
                          addOn.maxQuantity,
                        ),
                      ),
                      onDecrement: () => setState(() {
                        final next = qty - 1;
                        if (next <= 0) {
                          _quantities.remove(addOn.slug);
                        } else {
                          _quantities[addOn.slug] = next;
                        }
                      }),
                    )
                  : _addButton(addOn),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: AppColors.white15),
      ],
    );
  }

  Widget _addButton(AddOn addOn) {
    return OutlinedButton(
      onPressed: () => setState(
        () => _quantities[addOn.slug] = addOn.minQuantity.clamp(
          1,
          addOn.maxQuantity,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(80, 48),
        foregroundColor: AppColors.white,
        side: const BorderSide(color: AppColors.white30),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),
      child: Text('Add', style: AppTextStyles.labelMedium),
    );
  }

  String _priceLabel(double rate) {
    final whole = rate == rate.roundToDouble();
    final value = whole ? rate.toStringAsFixed(0) : rate.toStringAsFixed(2);
    return '\$$value/-';
  }

  Widget _bottomBar(List<AddOn> catalogue) {
    final subtotal = _subtotal(catalogue);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (catalogue.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadii.lgAll,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Add-ons subtotal',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyLargeMedium.copyWith(
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        WizardBottomBar(onBack: () => context.pop(), onContinue: _continue),
      ],
    );
  }

  Widget _error(String? message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message ?? 'Failed to load add-ons',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white70),
          ),
          AppSpacing.verticalBase,
          OutlinedButton(
            onPressed: () => ref.read(addOnsNotifierProvider.notifier).load(),
            child: Text('Retry', style: AppTextStyles.labelMedium),
          ),
        ],
      ),
    ),
  );
}
