import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';

import '../../community_styles.dart';
import '../../data/community_models.dart';
import 'community_avatar.dart';

class GroupListItemCard extends StatelessWidget {
  const GroupListItemCard({
    super.key,
    required this.group,
    this.onTap,
  });

  final CommunityGroupModel group;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.stroke),
        boxShadow: [
          BoxShadow(
            color: AppColors.mainDark.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: SizedBox(
          width: 48.w,
          height: 48.w,
          child: GroupAvatar(group: group, radius: 24),
        ),
        title: Text(group.name, style: CommunityStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(group.memberLabel, style: CommunityStyles.caption),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.w,
          color: AppColors.lightText,
        ),
        onTap: onTap,
      ),
    );
  }
}

class EditableGroupCard extends StatelessWidget {
  const EditableGroupCard({
    super.key,
    required this.group,
    this.onDelete,
  });

  final CommunityGroupModel group;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.h),
      decoration: CommunityStyles.cardDecoration,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        leading: SizedBox(
          width: 44.w,
          height: 44.w,
          child: GroupAvatar(group: group, radius: 22),
        ),
        title: Text(
          group.name,
          style: CommunityStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(group.memberLabel, style: CommunityStyles.caption),
        trailing: IconButton(
          icon: Icon(Icons.delete_forever_rounded, color: AppColors.red, size: 26.w),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
