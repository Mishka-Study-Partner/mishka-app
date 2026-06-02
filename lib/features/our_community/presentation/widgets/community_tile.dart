import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';

import '../../community_styles.dart';
import '../../data/community_models.dart';
import 'community_avatar.dart';

class CommunityTile extends StatelessWidget {
  const CommunityTile({
    super.key,
    required this.community,
    this.onTap,
  });

  final CommunityModel community;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(10.w),
        decoration: CommunityStyles.goldBorderCardDecoration,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: Image(
                image: communityImageProvider(community),
                width: 40.w,
                height: 40.w,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  community.imageAsset,
                  width: 40.w,
                  height: 40.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    community.name,
                    style: CommunityStyles.sectionLabel,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    community.subtitle,
                    maxLines: community.isLongSubtitle ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: CommunityStyles.caption,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.w,
              color: AppColors.mainDark,
            ),
          ],
        ),
      ),
    );
  }
}
