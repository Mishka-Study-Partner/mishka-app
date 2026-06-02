import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/generated/assets.dart';

import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_display_helper.dart';
import '../../community_styles.dart';
import '../../data/community_json_helpers.dart';
import '../../data/community_models.dart';
import 'community_avatar.dart';

/// Chat screen app bar: navy top row (back + logo only) and community info strip.
class CommunityChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommunityChatAppBar({
    super.key,
    required this.community,
    this.onBackTap,
    this.onMenuTap,
  });

  final CommunityModel community;
  final VoidCallback? onBackTap;
  final VoidCallback? onMenuTap;

  static double get _bottomStripHeight => 76.h;

  @override
  Size get preferredSize {
    final topInset = _topSafeInset();
    return Size.fromHeight(topInset + AppSizes.appBarHeight + 8.h + _bottomStripHeight);
  }

  double _topSafeInset() {
    try {
      final views = WidgetsBinding.instance.platformDispatcher.views;
      if (views.isEmpty) return 0;
      return MediaQueryData.fromView(views.first).padding.top;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topInset = MediaQuery.paddingOf(context).top;
    final memberLabel = memberCountLabel(community.memberCount);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          color: AppColors.appBarBackground,
          padding: EdgeInsets.only(
            top: topInset,
            left: AppSizes.paddingMedium,
            right: AppSizes.paddingMedium,
          ),
          child: SizedBox(
            height: AppSizes.appBarHeight,
            child: Row(
              children: [
                GestureDetector(
                  onTap: onBackTap ?? () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.mainGold,
                    size: AppSizes.iconMedium,
                  ),
                ),
                const Spacer(),
                Image.asset(
                  Assets.imagesLogoNoName,
                  height: 64.h,
                  width: 61.w,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          height: _bottomStripHeight,
          color: AppColors.white,
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
          child: Row(
            children: [
              CommunityAvatar(community: community, radius: 26),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      communityDisplayName(community.name, l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CommunityStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      memberLabel,
                      style: CommunityStyles.caption,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onMenuTap,
                icon: Icon(
                  Icons.more_horiz,
                  color: AppColors.mainGold,
                  size: 28.w,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
