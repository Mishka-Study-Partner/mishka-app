import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';

import '../../community_styles.dart';
import '../../data/community_models.dart';

class MemberTile extends StatelessWidget {
  const MemberTile({super.key, required this.member});

  final CommunityMemberModel member;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14.r,
            backgroundColor: AppColors.mainDark.withValues(alpha: 0.1),
            child: Icon(Icons.person, size: 16.w, color: AppColors.mainDark),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(member.name, style: CommunityStyles.body),
          ),
          Text(member.role, style: CommunityStyles.roleLabel),
        ],
      ),
    );
  }
}

class ManageMemberCard extends StatelessWidget {
  const ManageMemberCard({
    super.key,
    required this.member,
    required this.expanded,
    required this.onExpand,
    required this.onAddToGroup,
    required this.onRemoveFromCommunity,
    required this.onRemoveFromGroup,
    this.canChangeRole = false,
    this.promoteLabel,
    this.demoteLabel,
    this.onPromoteToAdmin,
    this.onDemoteToMember,
  });

  final CommunityMemberModel member;
  final bool expanded;
  final VoidCallback onExpand;
  final VoidCallback onAddToGroup;
  final VoidCallback onRemoveFromCommunity;
  final void Function(String group) onRemoveFromGroup;
  final bool canChangeRole;
  final String? promoteLabel;
  final String? demoteLabel;
  final VoidCallback? onPromoteToAdmin;
  final VoidCallback? onDemoteToMember;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      color: AppColors.white,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.mainDark.withValues(alpha: 0.08),
              child: Icon(Icons.person, size: 20.w, color: AppColors.mainDark),
            ),
            title: Text(member.name, style: CommunityStyles.body),
            subtitle: Text(member.role, style: CommunityStyles.caption),
            trailing: IconButton(
              icon: Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColors.mainDark,
              ),
              onPressed: onExpand,
            ),
          ),
          if (expanded) ...[
            Divider(height: 1, color: AppColors.stroke),
            ...member.groups.map(
              (group) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                child: Row(
                  children: [
                    Expanded(child: Text(group, style: CommunityStyles.body)),
                    TextButton(
                      onPressed: () => onRemoveFromGroup(group),
                      child: Text('Remove', style: CommunityStyles.body.copyWith(color: AppColors.red)),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                children: [
                  if (canChangeRole &&
                      member.role != 'Owner' &&
                      onPromoteToAdmin != null &&
                      member.role == 'Member') ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onPromoteToAdmin,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.mainGold,
                          side: const BorderSide(color: AppColors.mainGold),
                        ),
                        child: Text(promoteLabel ?? 'Make Admin'),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                  if (canChangeRole &&
                      member.role == 'Admin' &&
                      onDemoteToMember != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onDemoteToMember,
                        child: Text(demoteLabel ?? 'Make Member'),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: CommunityStyles.goldButtonStyle(),
                      onPressed: onAddToGroup,
                      child: const Text('Add To Group'),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onRemoveFromCommunity,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.red,
                        side: const BorderSide(color: AppColors.red),
                        textStyle: CommunityStyles.body,
                      ),
                      child: const Text('Remove From Community'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
