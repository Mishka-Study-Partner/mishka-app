import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_sizes.dart';
import '../../../../core/utils/app_colors.dart';

class CustomTaskCard extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final bool isCompleted;

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const CustomTaskCard({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.isCompleted,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.screenBackground : AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.mainGold : AppColors.red,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: onToggle,
                      borderRadius: BorderRadius.circular(6.r),
                      child: Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.mainGold.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.mainGold
                                : AppColors.greyText,
                          ),
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
                    Row(
                      children: [
                        _actionButton(
                          bgColor: AppColors.blue.withOpacity(0.1),
                          iconColor: AppColors.blue,
                          icon: Icons.edit,
                          onTap: onEdit,
                        ),
                        SizedBox(width: 8.w),
                        _actionButton(
                          bgColor: AppColors.red.withOpacity(0.1),
                          iconColor: AppColors.red,
                          icon: Icons.delete,
                          onTap: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppSizes.fontSizeLarge,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Pridi",
                    decoration:
                        isCompleted ? TextDecoration.lineThrough : null,
                    color: AppColors.mainDark,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeSmall,
                        fontFamily: "Pridi",
                        color: isCompleted
                            ? AppColors.mainGold
                            : AppColors.greyText,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeSmall,
                        fontFamily: "Pridi",
                        color: isCompleted
                            ? AppColors.mainGold
                            : AppColors.red,
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