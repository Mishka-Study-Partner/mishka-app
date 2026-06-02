import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/Auth/presentation/screens/login_screen.dart';
import 'package:mishka_app/features/Auth/presentation/screens/sign_up_screen.dart';
import 'package:mishka_app/features/onboarding/onboarding_assets.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Sharper corners for welcome CTA buttons (design: near-rectangular).
const _kWelcomeButtonRadius = 6.0;

/// Welcome hub: collage image, copy, Sign In / Create Account.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 12.h),
              Image.asset(
                OnboardingAssets.welcomePics,
                width: double.infinity,
                height: 377.h,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => SizedBox(
                  height: 377.h,
                  child: ColoredBox(
                    color: AppColors.lightFrameBackground,
                    child: Icon(
                      Icons.image_outlined,
                      size: 48.w,
                      color: AppColors.greyText,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
                child: Column(
                  children: [
                    Text(
                      l10n.welcomeToMishka,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                            fontFamily: 'Pridi',
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mainGold,
                          ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      l10n.welcomeToMishkaSubtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                            fontFamily: 'Pridi',
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mainDark,
                            height: 1.25,
                          ),
                    ),
                    SizedBox(height: 32.h),
                    _WelcomePrimaryButton(
                      label: l10n.signIn,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 14.h),
                    _WelcomeOutlinedButton(
                      label: l10n.createAccount,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomePrimaryButton extends StatelessWidget {
  const _WelcomePrimaryButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 358.w,
        height: 50.h,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mainGold,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_kWelcomeButtonRadius.r),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: AppSizes.fontSizeLarge,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeOutlinedButton extends StatelessWidget {
  const _WelcomeOutlinedButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 358.w,
        height: 50.h,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.mainGold,
            side: const BorderSide(color: AppColors.mainGold, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_kWelcomeButtonRadius.r),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: AppSizes.fontSizeLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.mainGold,
            ),
          ),
        ),
      ),
    );
  }
}
