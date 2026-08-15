import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_sizes.dart';
import '../../../../core/widgets/button_label.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 8.h),
      child: Row(
        children: [
          Expanded(child: _buildButton(l10n.addNewTask, onAddTask)),
          SizedBox(width: 8.w),
          Expanded(child: _buildButton(l10n.addNewList, onAddList)),
        ],
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.mainGold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        minimumSize: Size(0, AppSizes.buttonHeightSmall),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: AppColors.white, size: 16.w),
          SizedBox(width: 4.w),
          Flexible(
            child: ButtonLabel(
              label,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 12.sp,
                fontFamily: 'Pridi',
                height: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
