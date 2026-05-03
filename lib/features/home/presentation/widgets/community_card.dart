import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class CommunityCard extends StatelessWidget {
  final String icon;
  final String text;
  final AppLocalizations l10n;
  final VoidCallback? onStart;
  final bool isRowLayout; // true for row layout, false for column layout

  const CommunityCard({
    super.key,
    required this.icon,
    required this.text,
    required this.l10n,
    this.onStart,
    this.isRowLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isRowLayout) {
      // Full width card with row layout
      return Container(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.mainGold,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Iconify(
                  icon,
                  size: 21.w,
                  color: AppColors.white,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: "Pridi",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mainDark,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            ElevatedButton(
              onPressed: onStart ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainGold,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
              ),
              child: Text(
                l10n.start,
                style: TextStyle(
                  fontFamily: "Pridi",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Column layout for cards in row
      return Container(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.mainGold,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Iconify(
                  icon,
                  size:21.w,
                  color: AppColors.white,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              text,
              style: TextStyle(
                fontFamily: "Pridi",
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.mainDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: onStart ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainGold,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
              ),
              child: Text(
                l10n.start,
                style: TextStyle(
                  fontFamily: "Pridi",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
