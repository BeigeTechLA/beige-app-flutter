import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colors.dart';
import '../../../../app/durations.dart';
import '../../../../app/radii.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading.dart';
import '../providers/create_meeting_notifier.dart';
import 'member_selection_tile.dart';

class InviteAdditionalMembersBottomSheet extends ConsumerStatefulWidget {
  const InviteAdditionalMembersBottomSheet({super.key});

  @override
  ConsumerState<InviteAdditionalMembersBottomSheet> createState() =>
      _InviteAdditionalMembersBottomSheetState();
}

class _InviteAdditionalMembersBottomSheetState
    extends ConsumerState<InviteAdditionalMembersBottomSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch directory API roster
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(createMeetingNotifierProvider.notifier).fetchDirectory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createMeetingNotifierProvider);
    final notifier = ref.read(createMeetingNotifierProvider.notifier);

    // Filter directory participants based on tab, search text, and exclude default members
    final defaultIds = state.defaultInvitedMembers.map((m) => m.id).toSet();
    final isStaffTab = state.selectedTab == 'staff';

    final filteredList = state.directoryParticipants.where((p) {
      // Exclude default invited members
      if (defaultIds.contains(p.id)) return false;

      // Filter by tab type
      final matchesTab = isStaffTab
          ? p.type == 'staff'
          : p.type == 'creativePartner';
      if (!matchesTab) return false;

      // Filter by search query
      if (state.searchText.isNotEmpty) {
        final query = state.searchText.toLowerCase();
        final matchesName = p.name.toLowerCase().contains(query);
        final matchesEmail = (p.email ?? '').toLowerCase().contains(query);
        return matchesName || matchesEmail;
      }

      return true;
    }).toList();

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
          child: Column(
            children: [
              // Drag Handle
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

              // Title and Close Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Invite More Staff Or\nCreative Partners',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
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

              // Segmented Tab Bar (Staff / Creative Partner)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Container(
                  height: 53,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMid,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _RolePill(
                          label: 'Staff',
                          isActive: isStaffTab,
                          onTap: () {
                            notifier.setSelectedTab('staff');
                            _searchController.clear();
                            notifier.setSearchText('');
                          },
                        ),
                      ),
                      Expanded(
                        child: _RolePill(
                          label: 'Creative Partner',
                          isActive: !isStaffTab,
                          onTap: () {
                            notifier.setSelectedTab('cp');
                            _searchController.clear();
                            notifier.setSearchText('');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: notifier.setSearchText,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceInput,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    hintText: isStaffTab
                        ? 'Search Staff Members...'
                        : 'Search Creative Partners...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    suffixIcon: state.searchText.isEmpty
                        ? null
                        : GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              notifier.setSearchText('');
                            },
                            child: const Icon(
                              Icons.close,
                              color: AppColors.textTertiary,
                              size: 18,
                            ),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.dividerDark,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.dividerDark,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),

              // Section List Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isStaffTab ? 'Staff Members' : 'Creative Partners',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // Roster List
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state.directoryLoading) {
                      return const AppScreenLoader();
                    }

                    if (state.directoryError != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                state.directoryError!,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: notifier.fetchDirectory,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Check if search has no results
                    if (state.searchText.isNotEmpty && filteredList.isEmpty) {
                      return Center(
                        child: Text(
                          'No matching members found',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    // Check if tabs are empty
                    if (filteredList.isEmpty) {
                      return Center(
                        child: Text(
                          isStaffTab
                              ? 'No staff members found'
                              : 'No creative partners found',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final member = filteredList[index];
                        final isSelected = isStaffTab
                            ? state.selectedAdditionalStaffMembers.contains(member)
                            : state.selectedAdditionalCreativePartners.contains(member);

                        return MemberSelectionTile(
                          participant: member,
                          isSelected: isSelected,
                          onTap: () => notifier.toggleAdditionalMember(member),
                        );
                      },
                    );
                  },
                ),
              ),

              // Bottom Done Button
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  border: Border(
                    top: BorderSide(color: AppColors.dividerDark, width: 1),
                  ),
                ),
                child: AppButton(
                  label: 'Done',
                  fullWidth: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            gradient: isActive ? AppColors.goldHorizontalGradient : null,
            borderRadius: AppRadii.mldAll,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: isActive ? AppColors.textHeading : AppColors.white30,
            ),
          ),
        ),
      ),
    );
  }
}
