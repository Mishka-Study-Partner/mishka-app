import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';

class SupportBadgeCard extends StatelessWidget {
  final String imagePath;
  final String title1;


  const SupportBadgeCard({
    super.key,
    required this.imagePath,
    required this.title1,

  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Card
        Container(
          margin: EdgeInsets.only(top: 40.h),
          padding: EdgeInsets.only(
            top: 140.h,
            left: AppSizes.paddingMedium,
            right: AppSizes.paddingMedium,
            bottom: AppSizes.paddingMedium,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: AppColors.stroke,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //SizedBox(height: AppSizes.paddingSmall,),
              Text(
                title1,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: AppSizes.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainDark,
                ),
                textAlign: TextAlign.center,
              ),

            ],
          ),
        ),

        // Floating Image
        Positioned(
          top: 0,
          child: Container(
            width: 116.w,
            height: 114.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
            ),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
