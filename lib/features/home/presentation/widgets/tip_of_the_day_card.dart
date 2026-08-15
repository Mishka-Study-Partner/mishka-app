import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/layout/app_scale.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/generated/assets.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class TipOfTheDayCard extends StatelessWidget {
  final AppLocalizations l10n;
  final String? tipText;

  const TipOfTheDayCard({
    super.key,
    required this.l10n,
    this.tipText,
  });

  static const _tileCount = 3;

  @override
  Widget build(BuildContext context) {
    final isTablet = AppBreakpoints.isTablet(context);
    final quote = (tipText == null || tipText!.trim().isEmpty)
        ? l10n.tipQuote
        : tipText!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final horizontalBleed = (screenWidth - constraints.maxWidth) / 2;
        final bgHeight = isTablet ? AppScale.h(176) : 180.h;
        final tileGap = isTablet ? AppScale.w(10) : 10.w;
        final cardHorizontalInset = isTablet ? AppScale.w(28) : 16.w;

        return Transform.translate(
          offset: Offset(-horizontalBleed, 0),
          child: SizedBox(
            width: screenWidth,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: screenWidth,
                  height: bgHeight,
                  child: Row(
                    children: [
                      for (var i = 0; i < _tileCount; i++) ...[
                        if (i > 0) SizedBox(width: tileGap),
                        Expanded(
                          child: Image.asset(
                            Assets.imagesTipBackground,
                            height: bgHeight,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: cardHorizontalInset),
                  child: _TipCardContent(
                    l10n: l10n,
                    quote: quote,
                    isTablet: isTablet,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TipCardContent extends StatelessWidget {
  const _TipCardContent({
    required this.l10n,
    required this.quote,
    required this.isTablet,
  });

  final AppLocalizations l10n;
  final String quote;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isTablet ? AppScale.w(14) : AppSizes.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                l10n.tipOfTheDay,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: isTablet
                      ? AppScale.sp(15)
                      : AppSizes.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainDark,
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  margin: EdgeInsets.only(left: 8.w),
                  color: AppColors.mainDark,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 10.h : 12.h),
          Text(
            quote,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: isTablet ? AppScale.sp(12) : 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.mainDark,
              height: 1.35,
            ),
          ),
          SizedBox(height: isTablet ? 10.h : 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.mainDark,
                ),
              ),
              SizedBox(width: 8.w),
              Image.asset(
                Assets.imagesTipPhoto,
                width: isTablet ? 22.w : 26.w,
                height: isTablet ? 28.w : 34.w,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
