import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/generated/assets.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class TipOfTheDayCard extends StatelessWidget {
  final AppLocalizations l10n;

  const TipOfTheDayCard({
    super.key,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background: 3 images in a row at the bottom
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Image.asset(
                  Assets.imagesTipBackground,
                  height: 261.h,
                  width: 122.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width:AppSizes.paddingSmall ,),
              Expanded(
                child: Image.asset(
                  Assets.imagesTipBackground,
                  height: 261.h,
                  width: 122.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width:AppSizes.paddingSmall ,),
              Expanded(
                child: Image.asset(
                  Assets.imagesTipBackground,
                  height: 261.h,
                  width: 122.w,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),

        // White card centered on top
        Container(
          width: double.infinity,
          height: 181.h,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title with line
              Row(
                children: [
                    Text(
                      l10n.tipOfTheDay,
                      style: TextStyle(
                        fontFamily: "Pridi",
                        fontSize: AppSizes.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mainDark,
                      ),
                    ),
                  Expanded(
                    child: Container(
                      height: 1.h,
                      margin: EdgeInsets.only(left: 8.w),
                      color: AppColors.mainDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              // Quote text
              Text(
                l10n.tipQuote,
                style: TextStyle(
                  fontFamily: "Pridi",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mainDark,
                ),
              ),
              SizedBox(height: 12.h),
              // Line and image at bottom
              Row(
                crossAxisAlignment: CrossAxisAlignment.end
                ,
                children: [
                  Expanded(
                    child: Container(
                      height: 1.h,
                      color: AppColors.mainDark,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Image.asset(
                    Assets.imagesTipPhoto,
                    width: 26.w,
                    height: 34.w,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
