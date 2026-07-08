import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/loading.dart';
import '../../domain/models/shoot_participant_option.dart';
import '../providers/shoot_participants_provider.dart';

/// Modal bottom sheet for picking meeting participants from the booking's
/// roster. Multi-select. Returns the selected list on confirm, `null` on
/// dismiss.
Future<List<ShootParticipantOption>?> showMeetingParticipantPickerSheet(
  BuildContext context, {
  required int bookingId,
  required List<ShootParticipantOption> initialSelected,
}) {
  return showModalBottomSheet<List<ShootParticipantOption>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _PickerSheet(bookingId: bookingId, initialSelected: initialSelected),
  );
}

class _PickerSheet extends ConsumerStatefulWidget {
  const _PickerSheet({required this.bookingId, required this.initialSelected});

  final int bookingId;
  final List<ShootParticipantOption> initialSelected;

  @override
  ConsumerState<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends ConsumerState<_PickerSheet> {
  late final Set<ShootParticipantOption> _selected;
  late final TextEditingController _searchCtrl;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelected};
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggle(ShootParticipantOption opt) {
    setState(() {
      if (_selected.contains(opt)) {
        _selected.remove(opt);
      } else {
        _selected.add(opt);
      }
    });
  }

  void _confirm() {
    Navigator.of(context).pop(_selected.toList(growable: false));
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(shootParticipantsProvider(widget.bookingId));

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: AppRadii.topSheet,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const _Handle(),
                const _SheetHeader(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: _SearchField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                Expanded(
                  child: async.when(
                    loading: () => const AppScreenLoader(),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: AppEmptyState(
                        icon: Icons.error_outline,
                        title: 'Could not load roster',
                        description: e.toString(),
                        actionLabel: 'Retry',
                        onAction: () => ref.invalidate(
                          shootParticipantsProvider(widget.bookingId),
                        ),
                      ),
                    ),
                    data: (people) {
                      final filtered = _query.trim().isEmpty
                          ? people
                          : people
                                .where((p) {
                                  final q = _query.toLowerCase();
                                  return p.name.toLowerCase().contains(q) ||
                                      (p.email ?? '').toLowerCase().contains(q);
                                })
                                .toList(growable: false);
                      if (filtered.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: AppEmptyState(
                            icon: Icons.people_outline,
                            title: people.isEmpty
                                ? 'No one on this shoot yet'
                                : 'No matches',
                            description: people.isEmpty
                                ? 'Add a CP or crew to the booking first.'
                                : 'Try a different name or email.',
                          ),
                        );
                      }
                      return ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const Divider(
                          color: AppColors.dividerDark,
                          height: 1,
                        ),
                        itemBuilder: (context, i) {
                          final p = filtered[i];
                          return _ParticipantRow(
                            option: p,
                            isSelected: _selected.contains(p),
                            onTap: () => _toggle(p),
                          );
                        },
                      );
                    },
                  ),
                ),
                _Footer(count: _selected.length, onConfirm: _confirm),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Center(
        child: Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.dividerDark,
            borderRadius: AppRadii.fullAll,
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.base,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Text('Invite Participants', style: AppTextStyles.titleMedium),
          const Spacer(),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.dividerDark),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textTertiary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
                hintText: 'Search name or email',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final ShootParticipantOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = option.name.trim().isEmpty
        ? '?'
        : option.name.trim().substring(0, 1).toUpperCase();
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surfaceInput,
              child: Text(
                initials,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    option.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if ((option.role ?? '').isNotEmpty)
                    Text(
                      option.role!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            Checkbox(
              value: isSelected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.count, required this.onConfirm});

  final int count;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.dividerDark, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.base,
      ),
      child: AppButton(
        label: count == 0 ? 'Done' : 'Add $count',
        fullWidth: true,
        onPressed: onConfirm,
      ),
    );
  }
}
