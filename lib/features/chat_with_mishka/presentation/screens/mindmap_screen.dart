import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';

/// Placeholder screen for Mindmap tool
/// Receives generated tool JSON from ChatWithMishkaScreen
class MindmapScreen extends StatelessWidget {
  final Map<String, dynamic> toolData;

  const MindmapScreen({
    super.key,
    required this.toolData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const MishkaAppBar(
        title: "Mind Map",
        showBack: true,
        showBottomBar: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Mind Map Screen",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainDark,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Tool Data: ${toolData.toString()}",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.lightText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

