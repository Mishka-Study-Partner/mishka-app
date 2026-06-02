import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/features/onboarding/onboarding_assets.dart';

/// Brand splash — dark background, centered logo with name.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkMain,
      body: Center(
        child: Image.asset(
          OnboardingAssets.splashLogo,
          width: 204.w,
          height: 275.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
