import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/generated/assets.dart';


class MishkaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? topTitle;
  final bool showBack;
  final bool showBottomBar;
  final VoidCallback? onMenuTap;
  final VoidCallback? onBackTap;

  const MishkaAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.showBottomBar = true,
    this.onMenuTap,
    this.onBackTap,
    this.topTitle,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(showBottomBar ? 120.h : AppSizes.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: AppSizes.appBarHeight,
          decoration: const BoxDecoration(
            color: AppColors.appBarBackground,
          ),
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onBackTap ?? () => Navigator.pop(context),
                child: showBack
                    ? Icon(
                        Icons.arrow_back,
                        color: AppColors.mainGold,
                        size: AppSizes.iconMedium,
                      )
                    : SizedBox(width: 24.w),
              ),
              if (topTitle != null)
                Text(
                  topTitle!,
                  style: TextStyle(
                    color: AppColors.mainGold,
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.fontSizeXXLarge,
                    fontFamily: "Pridi",
                  ),
                )
              else
                SizedBox(width: 24.w),
              Image.asset(
                Assets.imagesLogoNoName,
                height: 64.h,
                width: 61.w,
              ),
            ],
          ),
        ),
        if (showBottomBar) SizedBox(height: 8.h),
        if (showBottomBar)
          Container(
            height: AppSizes.appBarBottomHeight,
            color: AppColors.screenBackground,
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onMenuTap,
                  child: Icon(
                    Icons.menu,
                    size: AppSizes.iconLarge,
                    color: AppColors.mainDark,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: "Pridi",
                    fontSize: AppSizes.fontSizeXLarge,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mainDark,
                  ),
                ),
                CircleAvatar(
                  radius: 16.r,
                  backgroundImage: AssetImage(Assets.imagesLogoNoName),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
