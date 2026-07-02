import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
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
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D0D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            notifier.setSelectedTab('staff');
                            _searchController.clear();
                            notifier.setSearchText('');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isStaffTab
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Staff',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isStaffTab
                                    ? AppColors.onPrimary
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            notifier.setSelectedTab('cp');
                            _searchController.clear();
                            notifier.setSearchText('');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: !isStaffTab
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Creative Partner',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: !isStaffTab
                                    ? AppColors.onPrimary
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceInput,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.dividerDark),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: notifier.setSearchText,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: isStaffTab
                                ? 'Search Staff Members...'
                                : 'Search Creative Partners...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
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
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
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
