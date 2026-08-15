/// Onboarding image paths (add files under [assets/images/]).
class OnboardingAssets {
  OnboardingAssets._();

  static const String splashLogo = 'assets/images/logo.png';

  /// Intro hero — phone (portrait, 780×1206).
  static const String onboarding1Phone = 'assets/images/onboarding1.png';

  /// Intro hero — tablet (wide composition, 1488×1486).
  static const String onboarding1Tablet = 'assets/images/onboarding1-tablet.png';

  /// @deprecated Use [onboarding1Phone] or [OnboardingHeroResolver].
  static const String onboarding1 = onboarding1Phone;

  static const String arrowBackground = 'assets/images/arrow_background.png';
  static const String welcomePics = 'assets/images/pics.png';
}
