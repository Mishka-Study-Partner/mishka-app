import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_sizes.dart';

class MishkaSearchBar extends StatelessWidget {
  final String hintText;
  
  const MishkaSearchBar({super.key, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.mainGold),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 16.w,
            color: AppColors.lightText,
          ),
          SizedBox(width: 8.w),
          Text(
            hintText,
            style: TextStyle(
              fontFamily: "Pridi",
              fontSize: AppSizes.fontSizeSmall,
              color: AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }
}
