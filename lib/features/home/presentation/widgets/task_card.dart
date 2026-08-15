import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_sizes.dart';
enum TodoStatus { done, upcoming, passed }


class TodoTaskCard extends StatelessWidget {
  const TodoTaskCard({
    super.key,
    required this.taskTitle,
    required this.listTitle,
    required this.dateText,
    required this.timeText,
    required this.status,
  });

  final String taskTitle;
  final String listTitle;
  final String dateText;
  final String timeText;
  final TodoStatus status;

  bool get isDone => status == TodoStatus.done;
  bool get isPassed => status == TodoStatus.passed;

  Color get backgroundColor {
    if (isDone) return AppColors.mainGold.withOpacity(0.08);
    if (isPassed) return AppColors.red.withOpacity(0.08);
    return AppColors.white;
  }

  Color get leftLineColor {
    if (isDone) return AppColors.mainGold;
    if (isPassed) return AppColors.red;
    return AppColors.stroke;
  }

  Color get deadlineColor {
    if (isDone) return AppColors.green;
    if (isPassed) return AppColors.red;
    return AppColors.blue;
  }

  Color get checkboxColor {
    if (isPassed) return AppColors.red;
    return AppColors.mainGold;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left vertical line
          Container(
            width: 1.5.w,
            height: 230.h,
            decoration: BoxDecoration(
              color: leftLineColor,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          SizedBox(width: AppSizes.paddingMedium),


          SizedBox(width: AppSizes.paddingMedium),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
    Container(
    width: 16.w,
    height: 16.w,
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(6.r),
    border: Border.all(color: checkboxColor, width: 2),
    color: isDone
    ? checkboxColor.withOpacity(0.15)
        : AppColors.white,
    ),
    child: isDone
    ? Icon(
    Icons.check,
    size: 10.sp,
    color: checkboxColor,
    )
        : null,
    ),
                // Task
                Text(
                  l10n.task,
                  style: textTheme.titleMedium,
                ),
                SizedBox(height: 4.h),
                Text(
                  taskTitle,
                  style: textTheme.bodyMedium?.copyWith(
                    decoration: isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: isPassed
                        ? AppColors.red
                        : AppColors.mainDark,
                  ),
                ),

                SizedBox(height: AppSizes.paddingSmall),

                // List
                Text(
                  l10n.list,
                  style: textTheme.titleMedium,
                ),
                SizedBox(height: 4.h),
                Text(
                  listTitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightText,
                  ),
                ),

                SizedBox(height: AppSizes.paddingSmall),

                // Deadline
                Text(
                  l10n.deadline,
                  style: textTheme.titleMedium,
                ),
                SizedBox(height: 4.h),
                Text(
                  dateText,
                  style: textTheme.bodyMedium?.copyWith(
                    color: deadlineColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  timeText,
                  style: textTheme.bodySmall?.copyWith(
                    color: deadlineColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
