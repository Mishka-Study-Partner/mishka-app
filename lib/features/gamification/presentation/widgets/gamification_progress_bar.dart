import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';

class GamificationProgressBar extends StatelessWidget {
  const GamificationProgressBar({
    super.key,
    required this.progress,
    required this.label,
  });

  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 10.h,
            backgroundColor: AppColors.lightFrameBackground,
            color: const Color(0xFF4A90D9),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.lightText,
          ),
        ),
      ],
    );
  }
}
