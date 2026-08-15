import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/app_bottom_sheet_layout.dart';
import 'package:mishka_app/features/community/data/models/joined_community_models.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Bottom sheet: joined communities → expandable groups → multi-select share.
Future<ShareCommunitySelection?> showShareToCommunitySheet({
  required BuildContext context,
  required List<JoinedCommunity> communities,
}) {
  final l10n = AppLocalizations.of(context)!;
  final selectedGroupIds = <String>{};
  final expandedCommunityIds = <String>{};
  final noteController = TextEditingController();

  if (communities.length == 1) {
    expandedCommunityIds.add(communities.first.id);
  }

  return showModalBottomSheet<ShareCommunitySelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          final selectedGroups = communities
              .expand((c) => c.groups)
              .where((g) => selectedGroupIds.contains(g.id))
              .toList();

          return AppBottomSheetLayout.wrap(
            context,
            child: LayoutBuilder(
              builder: (context, sheetConstraints) {
                return Container(
                  height: sheetConstraints.maxHeight.isFinite
                      ? sheetConstraints.maxHeight
                      : MediaQuery.sizeOf(context).height * 0.88,
                  padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: Column(
                    children: [
                    Text(
                      l10n.shareCommunitiesYouJoined,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: AppSizes.fontSizeXLarge,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mainDark,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: ListView.separated(
                        itemCount: communities.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final community = communities[index];
                          final expanded =
                              expandedCommunityIds.contains(community.id);
                          return _CommunityShareCard(
                            community: community,
                            expanded: expanded,
                            selectedGroupIds: selectedGroupIds,
                            onToggleExpand: () {
                              setSheetState(() {
                                if (expanded) {
                                  expandedCommunityIds.remove(community.id);
                                } else {
                                  expandedCommunityIds.add(community.id);
                                }
                              });
                            },
                            onGroupToggle: (groupId, selected) {
                              setSheetState(() {
                                if (selected) {
                                  selectedGroupIds.add(groupId);
                                } else {
                                  selectedGroupIds.remove(groupId);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if (selectedGroups.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      TextField(
                        controller: noteController,
                        maxLines: 2,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: l10n.shareOptionalNote,
                          hintStyle: TextStyle(
                            fontFamily: 'Pridi',
                            fontSize: AppSizes.fontSizeSmall,
                            color: AppColors.greyText,
                          ),
                          filled: true,
                          fillColor: AppColors.lightFrameBackground,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSmall),
                            borderSide: const BorderSide(color: AppColors.stroke),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSmall),
                            borderSide: const BorderSide(color: AppColors.stroke),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                        ),
                        style: TextStyle(
                          fontFamily: 'Pridi',
                          fontSize: AppSizes.fontSizeSmall,
                          color: AppColors.mainDark,
                        ),
                      ),
                    ],
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: selectedGroups.isEmpty
                            ? null
                            : () {
                                final note = noteController.text.trim();
                                Navigator.pop(
                                  sheetContext,
                                  ShareCommunitySelection(
                                    groups: selectedGroups,
                                    note: note.isEmpty ? null : note,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainGold,
                          disabledBackgroundColor:
                              AppColors.mainGold.withValues(alpha: 0.45),
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                        ),
                        child: Text(
                          l10n.shareToSelectedGroups,
                          style: TextStyle(
                            fontFamily: 'Pridi',
                            fontSize: AppSizes.fontSizeLarge,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
              },
            ),
          );
        },
      );
    },
  ).whenComplete(noteController.dispose);
}

class _CommunityShareCard extends StatelessWidget {
  const _CommunityShareCard({
    required this.community,
    required this.expanded,
    required this.selectedGroupIds,
    required this.onToggleExpand,
    required this.onGroupToggle,
  });

  final JoinedCommunity community;
  final bool expanded;
  final Set<String> selectedGroupIds;
  final VoidCallback onToggleExpand;
  final void Function(String groupId, bool selected) onGroupToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            onTap: onToggleExpand,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              child: Row(
                children: [
                  _CommunityAvatar(
                    imageUrl: community.imageUrl,
                    size: 44.w,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          community.name,
                          style: TextStyle(
                            fontFamily: 'Pridi',
                            fontSize: AppSizes.fontSizeMedium,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mainDark,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          l10n.shareMembersGroupsCount(
                            community.memberCount,
                            community.groupCount,
                          ),
                          style: TextStyle(
                            fontFamily: 'Pridi',
                            fontSize: AppSizes.fontSizeSmall,
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.chevron_right_rounded,
                    color: AppColors.mainDark,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            Divider(height: 1, color: AppColors.stroke),
            ...community.groups.map(
              (group) => _GroupShareRow(
                group: group,
                selected: selectedGroupIds.contains(group.id),
                onChanged: (value) => onGroupToggle(group.id, value),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GroupShareRow extends StatelessWidget {
  const _GroupShareRow({
    required this.group,
    required this.selected,
    required this.onChanged,
  });

  final CommunityGroup group;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () => onChanged(!selected),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: [
            _CommunityAvatar(
              imageUrl: group.imageUrl,
              size: 36.w,
              fallbackIcon: Icons.groups_outlined,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: AppSizes.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mainDark,
                    ),
                  ),
                  if (group.memberCount > 0) ...[
                    SizedBox(height: 2.h),
                    Text(
                      l10n.shareGroupMembersCount(group.memberCount),
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: AppSizes.fontSizeSmall,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _GoldShareCheckbox(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _GoldShareCheckbox extends StatelessWidget {
  const _GoldShareCheckbox({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        color: selected ? AppColors.mainGold : AppColors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(
          color: selected ? AppColors.mainGold : AppColors.stroke,
          width: 1.5,
        ),
      ),
      child: selected
          ? Icon(Icons.check, size: 16.sp, color: AppColors.white)
          : null,
    );
  }
}

class _CommunityAvatar extends StatelessWidget {
  const _CommunityAvatar({
    required this.imageUrl,
    required this.size,
    this.fallbackIcon = Icons.nightlight_round,
  });

  final String? imageUrl;
  final double size;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
  return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: AppColors.lightFrameBackground,
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Icon(
      fallbackIcon,
      color: AppColors.mainGold,
      size: size * 0.5,
    );
  }
}
