import 'package:flutter/material.dart';

import 'package:mishka_app/core/layout/app_scale.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/features/onboarding/onboarding_assets.dart';

/// Brand splash — dark background, centered logo with name.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logoWidth = AppScale.w(204).clamp(160.0, 220.0);
    final logoHeight = AppScale.h(275).clamp(200.0, 300.0);

    return Scaffold(
      backgroundColor: AppColors.darkMain,
      body: Center(
        child: Image.asset(
          OnboardingAssets.splashLogo,
          width: logoWidth,
          height: logoHeight,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
