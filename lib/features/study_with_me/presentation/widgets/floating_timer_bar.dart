import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';

import '../../data/study_session_manager.dart';
import '../../data/timer_model.dart';
import '../screens/timer_session_screen.dart';

/// A small floating bar that shows when a study session is active.
/// Tap it to navigate back to the timer screen.
class FloatingTimerBar extends StatelessWidget {
  const FloatingTimerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: StudySessionManager.instance,
      builder: (context, _) {
        final manager = StudySessionManager.instance;
        if (!manager.hasActiveSession) return const SizedBox.shrink();

        final controller = manager.controller!;
        final mode = controller.currentMode;
        final color = mode == TimerMode.shortBreak
            ? AppColors.blue
            : AppColors.mainGold;

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TimerSessionScreen(
                  model: controller.model,
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.mainDark,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  controller.isRunning ? Icons.timer : Icons.pause_circle,
                  color: color,
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  controller.model.title,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: 12.sp,
                    color: AppColors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  controller.formattedTime,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.white,
                  size: 12.w,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
