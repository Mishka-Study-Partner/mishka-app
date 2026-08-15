import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/onboarding/onboarding_assets.dart';
import 'package:mishka_app/features/onboarding/onboarding_hero_variant.dart';
import 'package:mishka_app/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// White-button center on arrow background (231×231).
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
    final media = MediaQuery.of(context);
    final hero = OnboardingHeroResolver.forContext(context);
    final isTablet = AppBreakpoints.isTablet(context);

    // iOS home-indicator inset otherwise reserves a white band at the bottom
    // and keeps all content (text + arrow) above it.
    return MediaQuery(
      data: media.copyWith(
        padding: media.padding.copyWith(bottom: 0),
        viewPadding: media.viewPadding.copyWith(bottom: 0),
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: isTablet
            ? _buildTabletBody(context, hero, l10n)
            : _buildPhoneBody(context, hero, l10n),
      ),
    );
  }

  Widget _buildHeroImage(OnboardingHeroVariant hero) {
    return Image.asset(
      hero.assetPath,
      fit: BoxFit.fill,
      width: double.infinity,
      alignment: Alignment.topCenter,
      errorBuilder: (_, __, ___) => ColoredBox(
        color: AppColors.lightFrameBackground,
        child: Icon(
          Icons.image_outlined,
          size: 48.w,
          color: AppColors.greyText,
        ),
      ),
    );
  }

  Widget _buildLowerPanel(BuildContext context, AppLocalizations l10n) {
    return Column(
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
    );
  }

  /// Phone: full-width hero height from aspect ratio, then flexible lower panel.
  Widget _buildPhoneBody(
    BuildContext context,
    OnboardingHeroVariant hero,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: hero.aspectRatio,
          child: _buildHeroImage(hero),
        ),
        Expanded(child: _buildLowerPanel(context, l10n)),
      ],
    );
  }

  /// Tablet: full hero (no crop), full width, height trimmed slightly when needed.
  Widget _buildTabletBody(
    BuildContext context,
    OnboardingHeroVariant hero,
    AppLocalizations l10n,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const heightTrim = 0.97;
        const lowerPanelReserve = 300.0;
        final naturalHeight = constraints.maxWidth / hero.aspectRatio;
        final trimmedHeight = naturalHeight * heightTrim;
        final maxHeroHeight =
            (constraints.maxHeight - lowerPanelReserve).clamp(0.0, naturalHeight);
        final heroHeight = trimmedHeight.clamp(0.0, maxHeroHeight);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: double.infinity,
              height: heroHeight,
              child: _buildHeroImage(hero),
            ),
            Expanded(child: _buildLowerPanel(context, l10n)),
          ],
        );
      },
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
    final isTablet = AppBreakpoints.isTablet(context);
    // Fixed tablet size — .w over-scales on iPad; slightly larger than before.
    final size = isTablet ? 172.0 : 151.w;
    final tapSize = isTablet ? 68.0 : 60.w;

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
                    size: isTablet ? 30.0 : 28.w,
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
