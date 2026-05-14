import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_sizes.dart';
import '../../../../core/utils/app_colors.dart';
import '../../data/models/task_api_model.dart';

class CustomTaskCard extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final TaskStatus taskStatus;
  final String? listName;

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const CustomTaskCard({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.taskStatus,
    this.listName,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = taskStatus == TaskStatus.completed;
    final isMissed = taskStatus == TaskStatus.missed;

    // Side bar color
    final sideBarColor = isCompleted
        ? AppColors.mainGold
        : isMissed
            ? AppColors.red
            : AppColors.greyText;

    // Card background
    final cardBg = isCompleted
        ? const Color(0xFFFFFDF5) // warm cream for completed
        : AppColors.white;

    // Checkbox
    final checkboxBorderColor = isCompleted ? AppColors.mainGold : AppColors.greyText;
    final checkboxFillColor = isCompleted
        ? AppColors.mainGold.withValues(alpha: 0.15)
        : Colors.transparent;

    // Date/time colors
    final dateColor = isCompleted
        ? AppColors.mainGold
        : isMissed
            ? AppColors.red
            : AppColors.greyText;
    final timeColor = isCompleted
        ? AppColors.mainGold
        : isMissed
            ? AppColors.red
            : AppColors.greyText;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left color stripe
          Container(
            width: 4.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: sideBarColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: checkbox + action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Checkbox
                    InkWell(
                      onTap: onToggle,
                      borderRadius: BorderRadius.circular(6.r),
                      child: Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          color: checkboxFillColor,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: checkboxBorderColor),
                        ),
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                size: 18.w,
                                color: AppColors.mainGold,
                              )
                            : null,
                      ),
                    ),
                    // Edit & Delete buttons
                    Row(
                      children: [
                        _actionButton(
                          bgColor: AppColors.blue.withValues(alpha: 0.1),
                          iconColor: AppColors.blue,
                          icon: Icons.edit,
                          onTap: onEdit,
                        ),
                        SizedBox(width: 8.w),
                        _actionButton(
                          bgColor: AppColors.red.withValues(alpha: 0.1),
                          iconColor: AppColors.red,
                          icon: Icons.delete,
                          onTap: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                // Task title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppSizes.fontSizeLarge,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Pridi",
                    color: AppColors.mainDark,
                  ),
                ),
                if (listName != null && listName!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    listName!,
                    style: TextStyle(
                      fontSize: AppSizes.fontSizeSmall,
                      fontFamily: "Pridi",
                      color: AppColors.greyText,
                    ),
                  ),
                ],
                SizedBox(height: 6.h),
                // Date & time row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeSmall,
                        fontFamily: "Pridi",
                        color: dateColor,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeSmall,
                        fontFamily: "Pridi",
                        color: timeColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required Color bgColor,
    required Color iconColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: iconColor, size: 18.w),
      ),
    );
  }
}
