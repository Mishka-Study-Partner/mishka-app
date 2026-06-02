import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_display_helper.dart';
import '../../community_styles.dart';
import '../../data/community_discover_models.dart';
import '../../data/community_json_helpers.dart';
import 'community_avatar.dart';

class DiscoverCommunityTile extends StatelessWidget {
  const DiscoverCommunityTile({
    super.key,
    required this.card,
    this.subtitle,
    this.onTap,
    this.onJoin,
    this.joinLabel,
    this.compact = false,
  });

  final CommunityDiscoverCard card;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;
  final String? joinLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final joinText = joinLabel ?? l10n.communityDiscoverJoin;
    final community = card.toCommunityModel(subtitleOverride: subtitle);
    final displaySubtitle = subtitle ??
        (card.primarySubjectLabel.isNotEmpty
            ? '${card.primarySubjectLabel} · ${memberCountLabel(card.memberCount)}'
            : memberCountLabel(card.memberCount));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: compact ? 260.w : null,
        margin: EdgeInsets.only(bottom: compact ? 0 : 10.h, right: compact ? 10.w : 0),
        padding: EdgeInsets.all(compact ? 12.w : 10.w),
        decoration: CommunityStyles.goldBorderCardDecoration,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: Image(
                image: communityImageProvider(community),
                width: compact ? 48.w : 40.w,
                height: compact ? 48.w : 40.w,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  community.imageAsset,
                  width: compact ? 48.w : 40.w,
                  height: compact ? 48.w : 40.w,
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
                    communityDisplayName(card.name, l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CommunityStyles.sectionLabel,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    displaySubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CommunityStyles.caption,
                  ),
                ],
              ),
            ),
            if (onJoin != null) ...[
              SizedBox(width: 8.w),
              TextButton(
                onPressed: onJoin,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.mainGold,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                ),
                child: Text(
                  joinText,
                  style: CommunityStyles.bodySemiBold.copyWith(
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ] else
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
