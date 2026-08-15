import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/layout/app_scale.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';

/// Saved hub list row — layout/colors from `Mishka.md` “# all saved” (`SavedItemCard`).
///
/// Prefer [primaryImageAsset] paths from the markdown (`flashcards.png`, etc.);
/// falls back to [fallbackImageAsset] when missing.
class SavedLibraryMishkaCard extends StatelessWidget {
  const SavedLibraryMishkaCard({
    super.key,
    required this.title,
    required this.primaryImageAsset,
    required this.fallbackImageAsset,
    required this.imageLeft,
    required this.actionLabel,
    required this.onView,
    /// Hub: tap image/title to filter; does not fire when [onView] is pressed.
    this.onSurfaceTap,
    this.onShare,
    this.onDelete,
    this.onRename,
    this.tabletCardHeight,
  });

  final String title;
  final String primaryImageAsset;
  final String fallbackImageAsset;
  final bool imageLeft;
  final String actionLabel;
  final VoidCallback onView;
  final VoidCallback? onSurfaceTap;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final VoidCallback? onRename;

  /// Tablet only — splits list height across cards (phone ignores this).
  final double? tabletCardHeight;

  /// Mishka.md theme (do not substitute app colors — preserves prototype look).
  static const Color kNavy = Color(0xFF1A2A3A);
  static const Color kGold = Color(0xFFC9A66B);
  static const Color kWhite = Color(0xFFFFFFFF);

  bool _isTablet(BuildContext context) => AppBreakpoints.isTablet(context);

  /// Phone-only sizing — unchanged from original design.
  double _cardHeight(BuildContext context) {
    if (!_isTablet(context)) return 180.h;
    return tabletCardHeight ?? AppScale.h(168);
  }

  double _imageStripWidth(BuildContext context, double cardHeight) {
    if (!_isTablet(context)) return 140.w;
    return AppScale.w((cardHeight * 1.12).clamp(140.0, 230.0));
  }

  double _titleFontSize(BuildContext context) =>
      _isTablet(context) ? AppSizes.fontSizeXLarge : 22.sp;

  static double _actionFontSize(BuildContext context) =>
      AppSizes.fontSizeMedium;

  double _actionIconSize(BuildContext context) =>
      _isTablet(context) ? AppSizes.iconSmall : 18.sp;

  BoxFit _imageFit(BuildContext context) =>
      _isTablet(context) ? BoxFit.contain : BoxFit.cover;

  /// Optional category image paths from Mishka.md (add files under `assets/images/`).
  static String prototypePrimaryAsset(SavedContentKind kind) {
    return switch (kind) {
      SavedContentKind.flashcards => 'assets/images/flashcards.png',
      SavedContentKind.quiz => 'assets/images/quizzes.png',
      SavedContentKind.summary => 'assets/images/summary.png',
      SavedContentKind.mindmap => 'assets/images/mind_map.png',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final cardH = _cardHeight(context);
    final stripW = _imageStripWidth(context, cardH);

    return Container(
      height: cardH,
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: kGold.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          if (imageLeft)
            _wrapSurface(
              child: _ImageSection(
                primary: primaryImageAsset,
                fallback: fallbackImageAsset,
                cardHeight: cardH,
                stripWidth: stripW,
                imageFit: _imageFit(context),
                isTablet: isTablet,
              ),
            ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: imageLeft
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _wrapSurface(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      title,
                      textAlign:
                          imageLeft ? TextAlign.right : TextAlign.left,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: kNavy,
                        fontSize: _titleFontSize(context),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pridi',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onView,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGold,
                            foregroundColor: kWhite,
                            elevation: 2,
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? AppScale.w(20) : 24.w,
                              vertical: isTablet ? AppScale.h(10) : 8.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            textStyle: TextStyle(
                              fontFamily: 'Pridi',
                              fontSize: _actionFontSize(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                actionLabel,
                                style: TextStyle(
                                  fontFamily: 'Pridi',
                                  fontSize: _actionFontSize(context),
                                  fontWeight: FontWeight.w600,
                                  color: kWhite,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.chevron_right,
                                size: _actionIconSize(context),
                                color: kWhite,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (onShare != null || onDelete != null || onRename != null) ...[
                        SizedBox(width: 4.w),
                        if (onRename != null)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(
                              minWidth: 40.w,
                              minHeight: 40.h,
                            ),
                            icon: Icon(
                              Icons.drive_file_rename_outline,
                              color: kNavy,
                              size: 22.sp,
                            ),
                            onPressed: onRename,
                          ),
                        if (onShare != null)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(
                              minWidth: 40.w,
                              minHeight: 40.h,
                            ),
                            icon: Icon(
                              Icons.share_outlined,
                              color: kNavy,
                              size: 22.sp,
                            ),
                            onPressed: onShare,
                          ),
                        if (onDelete != null)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(
                              minWidth: 40.w,
                              minHeight: 40.h,
                            ),
                            icon: Icon(
                              Icons.delete_outline,
                              color: kNavy,
                              size: 22.sp,
                            ),
                            onPressed: onDelete,
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!imageLeft)
            _wrapSurface(
              child: _ImageSection(
                primary: primaryImageAsset,
                fallback: fallbackImageAsset,
                cardHeight: cardH,
                stripWidth: stripW,
                imageFit: _imageFit(context),
                isTablet: isTablet,
              ),
            ),
        ],
      ),
    );
  }

  Widget _wrapSurface({required Widget child}) {
    if (onSurfaceTap == null) {
      return child;
    }
    return GestureDetector(
      onTap: onSurfaceTap,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

class _ImageSection extends StatelessWidget {
  const _ImageSection({
    required this.primary,
    required this.fallback,
    required this.cardHeight,
    required this.stripWidth,
    required this.imageFit,
    required this.isTablet,
  });

  final String primary;
  final String fallback;
  final double cardHeight;
  final double stripWidth;
  final BoxFit imageFit;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final inset = isTablet ? AppScale.w(10) : 12.r;

    return SizedBox(
      width: stripWidth,
      child: Padding(
        padding: EdgeInsets.all(inset),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: ColoredBox(
            color: isTablet
                ? SavedLibraryMishkaCard.kGold.withValues(alpha: 0.08)
                : SavedLibraryMishkaCard.kWhite,
            child: SizedBox(
              height: cardHeight - inset * 2,
              width: double.infinity,
              child: _FallbackAssetImage(
                primary: primary,
                fallback: fallback,
                fit: imageFit,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackAssetImage extends StatelessWidget {
  const _FallbackAssetImage({
    required this.primary,
    required this.fallback,
    required this.fit,
  });

  final String primary;
  final String fallback;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      primary,
      fit: fit,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        if (primary != fallback) {
          return Image.asset(
            fallback,
            fit: fit,
            alignment: Alignment.center,
            filterQuality: FilterQuality.high,
            errorBuilder: (c, e2, s2) => _brokenImagePlaceholder(),
          );
        }
        return _brokenImagePlaceholder();
      },
    );
  }

  Widget _brokenImagePlaceholder() {
    return ColoredBox(
      color: SavedLibraryMishkaCard.kGold.withValues(alpha: 0.12),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: SavedLibraryMishkaCard.kNavy.withValues(alpha: 0.35),
          size: 40.sp,
        ),
      ),
    );
  }
}
