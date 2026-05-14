import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_sizes.dart';

class SectionCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isSaved;
  final VoidCallback? onToggleSaved;

  const SectionCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isSaved = false,
    this.onToggleSaved,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 107.h,
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusMedium),
                bottomLeft: Radius.circular(AppSizes.radiusMedium),
              ),
              child: SizedBox(
                width: 126.w,
                height: double.infinity,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.fitHeight,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
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
                      fontSize: AppSizes.fontSizeXXLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: "Pridi",
                      fontSize: AppSizes.fontSizeSmall,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightText,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(end: 8.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onToggleSaved != null)
                    GestureDetector(
                      onTap: onToggleSaved,
                      child: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        size: 22.w,
                        color: isSaved ? AppColors.mainGold : AppColors.lightText,
                      ),
                    ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20.w,
                    color: AppColors.mainDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
