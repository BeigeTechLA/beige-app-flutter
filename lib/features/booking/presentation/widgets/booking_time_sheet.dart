import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_text_field.dart';

class BookingTimeSheet extends StatefulWidget {
  const BookingTimeSheet({
    super.key,
    required this.isStart,
    required this.slots,
    required this.currentValue,
    required this.formatSlot,
    required this.isSameTime,
  });

  final bool isStart;
  final List<TimeOfDay> slots;
  final TimeOfDay? currentValue;
  final String Function(TimeOfDay time) formatSlot;
  final bool Function(TimeOfDay a, TimeOfDay b) isSameTime;

  @override
  State<BookingTimeSheet> createState() => BookingTimeSheetState();
}

class BookingTimeSheetState extends State<BookingTimeSheet> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSlots = _query.isEmpty
        ? widget.slots
        : widget.slots.where((slot) {
            return widget
                .formatSlot(slot)
                .toLowerCase()
                .contains(_query.toLowerCase());
          }).toList();

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: AppColors.transparent,
        child: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.7,
              decoration: const BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: AppRadii.topSheet,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base,
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.isStart ? 'Start Time' : 'End Time',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        if (widget.currentValue != null)
                          Container(
                            margin: const EdgeInsets.only(
                              right: AppSpacing.xxs,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.14),
                              borderRadius: AppRadii.fullAll,
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.35,
                                ),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              widget.formatSlot(widget.currentValue!),
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(null),
                          icon: const Icon(
                            CupertinoIcons.xmark,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.dividerDark),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    child: AppTextField(
                      hint: widget.isStart
                          ? 'Search Start Time...'
                          : 'Search End Time...',
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) {
                        setState(() => _query = value.trim());
                      },
                    ),
                  ),
                  Expanded(
                    child: filteredSlots.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 32,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'No slots available',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.base,
                              AppSpacing.xxs,
                              AppSpacing.base,
                              AppSpacing.base,
                            ),
                            itemCount: filteredSlots.length,
                            itemBuilder: (context, index) {
                              final slot = filteredSlots[index];
                              final isSelected =
                                  widget.currentValue != null &&
                                  widget.isSameTime(widget.currentValue!, slot);

                              return Semantics(
                                button: true,
                                selected: isSelected,
                                label: widget.formatSlot(slot),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => Navigator.of(context).pop(slot),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: AppSpacing.jumbo,
                                    ),
                                    margin: const EdgeInsets.only(
                                      bottom: AppSpacing.xxs,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.base,
                                      vertical: AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary.withValues(
                                              alpha: 0.18,
                                            )
                                          : AppColors.transparent,
                                      borderRadius: AppRadii.mdAll,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.transparent,
                                        width: 0.5,
                                      ),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      widget.formatSlot(slot),
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
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
