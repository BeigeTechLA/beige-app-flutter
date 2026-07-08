import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/text_styles.dart';
import '../../domain/models/meeting_type.dart';

/// Read-only text field styled like the other form dropdowns. Tapping opens
/// a bottom sheet with the fixed [_options]. Only Pre / Post Production are
/// user-selectable — the backend `meeting_type` enum has more values but
/// product scope is limited to these two.
class MeetingTypeDropdown extends StatelessWidget {
  const MeetingTypeDropdown({
    super.key,
    required this.selected,
    required this.decoration,
    required this.onChanged,
  });

  final MeetingType selected;
  final InputDecoration decoration;
  final ValueChanged<MeetingType> onChanged;

  static const List<MeetingType> _options = [
    MeetingType.preProduction,
    MeetingType.postProduction,
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showModalBottomSheet<MeetingType>(
          context: context,
          isScrollControlled: false,
          backgroundColor: Colors.transparent,
          builder: (_) => _MeetingTypePickerSheet(selected: selected),
        );
        if (picked != null) onChanged(picked);
      },
      child: AbsorbPointer(
        child: TextFormField(
          key: ValueKey(selected.serverValue),
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          readOnly: true,
          decoration: decoration.copyWith(
            suffixIcon: const Icon(
              Icons.expand_more,
              color: AppColors.textSecondary,
            ),
          ),
          controller: TextEditingController(text: selected.label),
        ),
      ),
    );
  }
}

class _MeetingTypePickerSheet extends StatelessWidget {
  const _MeetingTypePickerSheet({required this.selected});

  final MeetingType selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: AppRadii.topSheet,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.dividerDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Meeting Type',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final t in MeetingTypeDropdown._options)
                    _MeetingTypeOptionTile(
                      type: t,
                      isSelected: t == selected,
                      onTap: () => Navigator.of(context).pop(t),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _MeetingTypeOptionTile extends StatelessWidget {
  const _MeetingTypeOptionTile({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final MeetingType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.dividerDark,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                type.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                size: 18,
                color: AppColors.onPrimary,
              ),
          ],
        ),
      ),
    );
  }
}
