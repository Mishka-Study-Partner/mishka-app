import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_sizes.dart';

class FeatureAiSectionCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const FeatureAiSectionCard({
    super.key,
    required this.imagePath,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 101.h,
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: AppColors.mainGold.withOpacity(0.35),
          ),
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.topLeft,
            colors: [
              AppColors.mainGold.withOpacity(0.70),
              AppColors.mainGold.withOpacity(0.45),
              AppColors.mainGold.withOpacity(0.22),
              AppColors.mainGold.withOpacity(0.08),
              AppColors.mainGold.withOpacity(0.03),
              AppColors.white,
            ],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusMedium),
                bottomLeft: Radius.circular(AppSizes.radiusMedium),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.stroke),
                ),
                child: Image.asset(
                  imagePath,
                  width: 104.w,
                  height: double.infinity,
                  fit: BoxFit.fitHeight,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 104.w,
                      height: double.infinity,
                      color: AppColors.lightFrameBackground,
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: "Pridi",
                      fontSize: AppSizes.fontSizeTitle,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainDark,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontFamily: "Pridi",
                        fontSize: AppSizes.fontSizeSmall,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(
              width: 48.w,
              child: Icon(
                Icons.arrow_forward_ios,
                size: 20.w,
                color: AppColors.mainDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
