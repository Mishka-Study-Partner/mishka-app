import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/ctegory/utils/ai_tool_ui_helper.dart';

enum CardCornerPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class AiToolCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;
  final CardCornerPosition cornerPosition;

  const AiToolCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.onTap,
    required this.cornerPosition,
  });

  BorderRadius get _borderRadius {
    final radius = Radius.circular(AppSizes.radiusLarge);

    return BorderRadius.only(
      topLeft:
          cornerPosition == CardCornerPosition.topLeft ? radius : Radius.zero,
      topRight:
          cornerPosition == CardCornerPosition.topRight ? radius : Radius.zero,
      bottomLeft:
          cornerPosition == CardCornerPosition.bottomLeft ? radius : Radius.zero,
      bottomRight: cornerPosition == CardCornerPosition.bottomRight
          ? radius
          : Radius.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageWidth = constraints.maxWidth * 0.4;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.mainGold.withValues(alpha: 0.7),
                  AppColors.mainDark.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: _borderRadius,
              border: Border.all(color: AppColors.stroke),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.paddingSmall),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Pridi',
                          fontSize: AppSizes.fontSizeSmall,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                          height: 1.2,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: _borderRadius.topRight,
                    bottomRight: _borderRadius.bottomRight,
                  ),
                  child: SizedBox(
                    width: imageWidth,
                    height: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 6.h,
                      ),
                      child: Image.asset(
                        imagePath,
                        key: ValueKey(
                          '$imagePath-${AiToolUiHelper.homeCardAssetRevision}',
                        ),
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        filterQuality: FilterQuality.high,
                        gaplessPlayback: false,
                        excludeFromSemantics: true,
                      ),
                    ),
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
