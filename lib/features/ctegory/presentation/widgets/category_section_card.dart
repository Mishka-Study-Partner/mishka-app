import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/layout/app_scale.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_sizes.dart';

class SectionCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isSaved;
  final VoidCallback? onToggleSaved;

  /// When set on tablet, distributes list height across cards (phone ignores this).
  final double? tabletCardHeight;

  const SectionCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isSaved = false,
    this.onToggleSaved,
    this.tabletCardHeight,
  });

  bool _isTablet(BuildContext context) => AppBreakpoints.isTablet(context);

  /// Phone-only sizing — unchanged from original design.
  double _cardHeight(BuildContext context) {
    if (!_isTablet(context)) return 107.h;
    return tabletCardHeight ?? AppScale.h(120);
  }

  double _imageWidth(BuildContext context, double cardHeight) {
    if (!_isTablet(context)) return 126.w;
    return AppScale.w((cardHeight * 1.12).clamp(130.0, 210.0));
  }

  BoxFit _imageFit(BuildContext context) => BoxFit.contain;

  EdgeInsets _imagePadding(BuildContext context) {
    if (!_isTablet(context)) {
      return EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h);
    }
    return EdgeInsets.symmetric(horizontal: AppScale.w(8), vertical: AppScale.h(8));
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final height = _cardHeight(context);
    final imageW = _imageWidth(context, height);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusMedium),
                bottomLeft: Radius.circular(AppSizes.radiusMedium),
              ),
              child: SizedBox(
                width: imageW,
                height: double.infinity,
                child: ColoredBox(
                  color: isTablet
                      ? AppColors.lightFrameBackground
                      : AppColors.white,
                  child: Padding(
                    padding: _imagePadding(context),
                    child: Image.asset(
                      imagePath,
                      fit: _imageFit(context),
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.lightFrameBackground,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: isTablet
                          ? AppSizes.fontSizeXLarge
                          : AppSizes.fontSizeXXLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: AppSizes.fontSizeSmall,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightText,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(end: 8.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onToggleSaved != null)
                    GestureDetector(
                      onTap: onToggleSaved,
                      child: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        size: 22.w,
                        color:
                            isSaved ? AppColors.mainGold : AppColors.lightText,
                      ),
                    ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20.w,
                    color: AppColors.mainDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
