import 'package:flutter/material.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/layout/app_scale.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/button_label.dart';
import 'package:mishka_app/features/Auth/presentation/screens/login_screen.dart';
import 'package:mishka_app/features/Auth/presentation/screens/sign_up_screen.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/features/onboarding/onboarding_assets.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Sharper corners for welcome CTA buttons (design: near-rectangular).
const _kWelcomeButtonRadius = 6.0;

/// Welcome hub: collage image, copy, Sign In / Create Account.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  double _welcomeImageHeight(BuildContext context) {
    final viewportH = MediaQuery.sizeOf(context).height;
    final isTablet = AppBreakpoints.isTablet(context);
    if (isTablet) {
      return (viewportH * 0.48).clamp(AppScale.h(320), AppScale.h(480));
    }
    return (viewportH * 0.42).clamp(AppScale.h(240), AppScale.h(420));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final imageHeight = _welcomeImageHeight(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppScale.h(12)),
              Image.asset(
                OnboardingAssets.welcomePics,
                width: double.infinity,
                height: imageHeight,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => SizedBox(
                  height: imageHeight,
                  child: ColoredBox(
                    color: AppColors.lightFrameBackground,
                    child: Icon(
                      Icons.image_outlined,
                      size: AppScale.w(48),
                      color: AppColors.greyText,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppScale.h(24)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppBreakpoints.isTablet(context)
                      ? AppScale.w(28)
                      : AppSizes.paddingLarge,
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.welcomeToMishka,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                            fontFamily: 'Pridi',
                            fontSize: AppSizes.fontSizeTitle,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mainGold,
                          ),
                    ),
                    SizedBox(height: AppScale.h(12)),
                    Text(
                      l10n.welcomeToMishkaSubtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                            fontFamily: 'Pridi',
                            fontSize: AppSizes.fontSizeTitle,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mainDark,
                            height: 1.25,
                          ),
                    ),
                    SizedBox(height: AppScale.h(32)),
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
                    SizedBox(height: AppScale.h(14)),
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
                    SizedBox(height: AppScale.h(24)),
                    const ScreenEndSpacer(),
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mainGold,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: AppScale.w(16),
            vertical: AppScale.h(12),
          ),
          minimumSize: Size(double.infinity, AppSizes.buttonHeight),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppScale.r(_kWelcomeButtonRadius)),
          ),
        ),
        child: ButtonLabel(
          label,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: AppSizes.fontSizeLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
            height: 1.2,
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
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mainGold,
          side: const BorderSide(color: AppColors.mainGold, width: 1.5),
          padding: EdgeInsets.symmetric(
            horizontal: AppScale.w(16),
            vertical: AppScale.h(12),
          ),
          minimumSize: Size(double.infinity, AppSizes.buttonHeight),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppScale.r(_kWelcomeButtonRadius)),
          ),
        ),
        child: ButtonLabel(
          label,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: AppSizes.fontSizeLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.mainGold,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
