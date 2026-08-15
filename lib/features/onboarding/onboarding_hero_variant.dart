import 'package:flutter/material.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/features/onboarding/onboarding_assets.dart';

/// Phone vs tablet intro hero asset and its width÷height ratio.
class OnboardingHeroVariant {
  const OnboardingHeroVariant({
    required this.assetPath,
    required this.aspectRatio,
  });

  /// Asset path under [assets/images/].
  final String assetPath;

  /// Width divided by height (e.g. 780÷1206 for portrait phone art).
  final double aspectRatio;
}

/// Picks the intro hero image for the current device class.
class OnboardingHeroResolver {
  OnboardingHeroResolver._();

  /// Portrait phone art (780×1206).
  static const phone = OnboardingHeroVariant(
    assetPath: OnboardingAssets.onboarding1Phone,
    aspectRatio: 780 / 1206,
  );

  /// Wide tablet art (1488×1486) — shorter hero band, full width.
  static const tablet = OnboardingHeroVariant(
    assetPath: OnboardingAssets.onboarding1Tablet,
    aspectRatio: 1488 / 1486,
  );

  static OnboardingHeroVariant forContext(BuildContext context) {
    return AppBreakpoints.isTablet(context) ? tablet : phone;
  }
}
