import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/generated/assets.dart';


import '../../data/community_models.dart';

class CommunityAvatar extends StatelessWidget {
  const CommunityAvatar({
    super.key,
    required this.community,
    this.radius = 20,
    this.backgroundColor,
  });

  final CommunityModel community;
  final double radius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final url = community.imageUrl;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: radius.r,
        backgroundColor: backgroundColor ?? AppColors.mainDark,
        backgroundImage: NetworkImage(url),
      );
    }
    return CircleAvatar(
      radius: radius.r,
      backgroundColor: backgroundColor ?? AppColors.mainDark,
      backgroundImage: AssetImage(community.imageAsset),
    );
  }
}

class GroupAvatar extends StatelessWidget {
  const GroupAvatar({
    super.key,
    required this.group,
    this.radius = 16,
  });

  final CommunityGroupModel group;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = group.imageUrl;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: radius.r,
        backgroundImage: NetworkImage(url),
      );
    }
    return CircleAvatar(
      radius: radius.r,
      backgroundColor: group.iconColor.withValues(alpha: 0.15),
      child: Icon(group.icon, color: group.iconColor, size: (radius * 1.1).w),
    );
  }
}

ImageProvider communityImageProvider(CommunityModel community) {
  final url = community.imageUrl;
  if (url != null && url.isNotEmpty) return NetworkImage(url);
  return AssetImage(community.imageAsset);
}

ImageProvider groupImageProvider(CommunityGroupModel group) {
  final url = group.imageUrl;
  if (url != null && url.isNotEmpty) return NetworkImage(url);
  return const AssetImage(Assets.imagesOurCommunity);
}
