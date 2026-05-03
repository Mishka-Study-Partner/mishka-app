import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';

/// Placeholder screen for Quiz tool
/// Receives generated tool JSON from ChatWithMishkaScreen
class QuizScreen extends StatelessWidget {
  final Map<String, dynamic> toolData;

  const QuizScreen({
    super.key,
    required this.toolData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const MishkaAppBar(
        title: "Quiz",
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
                "Quiz Screen",
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

