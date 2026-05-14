import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';

class TodoBottomActions extends StatelessWidget {
  final VoidCallback onAddTask;
  final VoidCallback onAddList;

  const TodoBottomActions({
    super.key,
    required this.onAddTask,
    required this.onAddList,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 8.h),
      child: Row(
        children: [
          Expanded(child: _buildButton("Add New Task", onAddTask)),
          SizedBox(width: 8.w),
          Expanded(child: _buildButton("Add New List", onAddList)),
        ],
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return SizedBox(
      height: 44.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mainGold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.white, size: 16.w),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 12.sp,
                  fontFamily: 'Pridi',
                  height: 1.0,
                ),
                strutStyle: StrutStyle(
                  fontFamily: 'Pridi',
                  fontSize: 12.sp,
                  height: 1.4,
                  leading: 0,
                  forceStrutHeight: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
