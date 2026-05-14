import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_sizes.dart';

class MishkaSearchBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const MishkaSearchBar({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hintStyle = TextStyle(
      fontFamily: "Pridi",
      fontSize: AppSizes.fontSizeSmall,
      color: AppColors.lightText,
    );
    final textStyle = TextStyle(
      fontFamily: "Pridi",
      fontSize: AppSizes.fontSizeSmall,
      color: AppColors.mainDark,
    );

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
          if (controller != null)
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: textStyle,
                cursorColor: AppColors.mainGold,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: hintStyle,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            )
          else
            Text(
              hintText,
              style: hintStyle,
            ),
        ],
      ),
    );
  }
}
