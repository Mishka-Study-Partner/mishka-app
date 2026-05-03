import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_sizes.dart';
import '../view/calender_Screen.dart';
import 'calender.dart';

class TodoListItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;

   TodoListItem({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
  });
  final List<DateTime> taskDates = [
    DateTime(2025, 12, 3),
    DateTime(2025, 12, 7),
    DateTime(2025, 12, 18),
  ];


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 57.h,
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: AppSizes.iconSmall),
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
          GestureDetector(
              onTap: (){ Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  TaskScreen(),
                ),
              );},
              child: Icon(Icons.arrow_forward_ios, size: 14.w)),
        ],
      ),
    );
  }
}
