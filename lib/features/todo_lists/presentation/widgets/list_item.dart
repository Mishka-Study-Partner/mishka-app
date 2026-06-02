import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_sizes.dart';
import 'package:mishka_app/features/todo_lists/utils/todo_icon_catalog.dart';
import 'todo_list_icon_widget.dart';

class TodoListItem extends StatelessWidget {
  final String title;
  final TodoIconOption icon;
  final VoidCallback onTap;
  final VoidCallback? onRename;

  const TodoListItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onRename,
      child: Container(
        height: 57.h,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Row(
          children: [
            TodoListIconWidget(option: icon, size: AppSizes.iconSmall),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: "Pridi",
                  fontSize: AppSizes.fontSizeMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14.w),
          ],
        ),
      ),
    );
  }
}
