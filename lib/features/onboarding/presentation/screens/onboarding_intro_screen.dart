import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/onboarding/onboarding_assets.dart';
import 'package:mishka_app/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Aspect ratio of [OnboardingAssets.onboarding1] (780×1206).
const _kOnboarding1AspectRatio = 780 / 1206;

/// White-button center on [OnboardingAssets.arrowBackground] (231×231).
/// Measured from the asset: gray arc centroid ≈ (54.1%, 54.1%), not image center.
const _kArrowTapCenterFraction = Offset(0.554, 0.554);

/// One-time intro: Mishka illustration, quote, next arrow.
class OnboardingIntroScreen extends StatelessWidget {
  const OnboardingIntroScreen({super.key});

  Future<void> _goToWelcome(BuildContext context) async {
    await AppPreferences.setOnboardingIntroCompleted(true);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Hero image — edge-to-edge at top.
          AspectRatio(
            aspectRatio: _kOnboarding1AspectRatio,
            child: Image.asset(
              OnboardingAssets.onboarding1,
              fit: BoxFit.fill,
              width: double.infinity,
              errorBuilder: (_, __, ___) => ColoredBox(
                color: AppColors.lightFrameBackground,
                child: Icon(
                  Icons.image_outlined,
                  size: 48.w,
                  color: AppColors.greyText,
                ),
              ),
            ),
          ),
          // 2. Text, then 3. arrow — stacked vertically (not beside each other).
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.paddingLarge,
                    16.h,
                    AppSizes.paddingLarge,
                    0,
                  ),
                  child: _OnboardingIntroText(l10n: l10n),
                ),
                const Spacer(),
                Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: _NextArrowButton(
                    onTap: () => _goToWelcome(context),
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

class _OnboardingIntroText extends StatelessWidget {
  const _OnboardingIntroText({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontFamily: 'Pridi',
          fontSize: AppSizes.fontSizeLarge,
          fontWeight: FontWeight.w400,
          color: AppColors.mainDark,
          height: 1.35,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.onboardingIntroLine1, style: style, textAlign: TextAlign.start),
        Text(l10n.onboardingIntroLine2, style: style, textAlign: TextAlign.start),
        Text(l10n.onboardingIntroLine3, style: style, textAlign: TextAlign.start),
      ],
    );
  }
}

class _NextArrowButton extends StatelessWidget {
  const _NextArrowButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = 151.w;
    final tapSize = 60.w;

    final tapLeft = size * _kArrowTapCenterFraction.dx - tapSize / 2;
    final tapTop = size * _kArrowTapCenterFraction.dy - tapSize / 2;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset(
            OnboardingAssets.arrowBackground,
            width: size,
            height: size,
            fit: BoxFit.fill,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          Positioned(
            left: tapLeft,
            top: tapTop,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: Container(
                  width: tapSize,
                  height: tapSize,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: AppColors.mainDark,
                    size: 28.w,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
