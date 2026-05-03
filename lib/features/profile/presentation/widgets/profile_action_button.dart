import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_colors.dart';

class ProfileActionButton extends StatelessWidget {
  final String text;
  final bool selected;

  const ProfileActionButton({
    super.key,
    required this.text,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28.h,
      width: 118.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.mainGold : AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "Pridi",
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color:
          selected ? AppColors.white : AppColors.mainDark,
        ),
      ),
    );
  }
}
