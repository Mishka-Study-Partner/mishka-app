import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/navigation/safe_navigation.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/generated/assets.dart';

/// Status bar inset for [MishkaAppBar.preferredSize] (no [BuildContext] available there).
double _topSafeInsetForPreferredSize() {
  try {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return 0;
    return MediaQueryData.fromView(views.first).padding.top;
  } catch (_) {
    return 0;
  }
}

class MishkaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? topTitle;
  final bool showBack;
  final bool showBottomBar;
  final VoidCallback? onMenuTap;
  final VoidCallback? onBackTap;
  /// Shown before the Mishka logo in the top navy bar (e.g. edit / save actions).
  final Widget? topTrailingAction;

  const MishkaAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.showBottomBar = true,
    this.onMenuTap,
    this.onBackTap,
    this.topTitle,
    this.topTrailingAction,
  });

  double get _contentHeight =>
      showBottomBar ? 120.h : AppSizes.appBarHeight;

  @override
  Size get preferredSize => Size.fromHeight(
        _contentHeight + _topSafeInsetForPreferredSize(),
      );

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.appBarBackground,
          ),
          padding: EdgeInsets.only(
            top: topInset,
            left: AppSizes.paddingMedium,
            right: AppSizes.paddingMedium,
          ),
          child: SizedBox(
            height: AppSizes.appBarHeight,
            child: Row(
              children: [
                if (showBack)
                  _DebouncedBackButton(onBackTap: onBackTap)
                else
                  SizedBox(width: 24.w),
                if (topTitle != null)
                  Expanded(
                    child: Center(
                      child: Text(
                        topTitle!,
                        style: TextStyle(
                          color: AppColors.mainGold,
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.fontSizeXXLarge,
                          fontFamily: "Pridi",
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (topTrailingAction != null) topTrailingAction!,
                    if (topTrailingAction != null) SizedBox(width: 8.w),
                    Image.asset(
                      Assets.imagesLogoNoName,
                      height: 64.h,
                      width: 61.w,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (showBottomBar) SizedBox(height: 8.h),
        if (showBottomBar)
          Container(
            height: AppSizes.appBarBottomHeight,
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onMenuTap,
                  child: Icon(
                    Icons.menu,
                    size: AppSizes.iconLarge,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: "Pridi",
                    fontSize: AppSizes.fontSizeXLarge,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                CircleAvatar(
                  radius: 16.r,
                  backgroundImage: AssetImage(Assets.imagesLogoNoName),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DebouncedBackButton extends StatefulWidget {
  const _DebouncedBackButton({this.onBackTap});

  final VoidCallback? onBackTap;

  @override
  State<_DebouncedBackButton> createState() => _DebouncedBackButtonState();
}

class _DebouncedBackButtonState extends State<_DebouncedBackButton> {
  DateTime? _lastTap;
  static const _debounce = Duration(milliseconds: 350);

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!) < _debounce) return;
    _lastTap = now;

    if (widget.onBackTap != null) {
      widget.onBackTap!();
      return;
    }
    SafeNavigator.popIfPossible(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Icon(
        Icons.arrow_back,
        color: AppColors.mainGold,
        size: AppSizes.iconMedium,
      ),
    );
  }
}
