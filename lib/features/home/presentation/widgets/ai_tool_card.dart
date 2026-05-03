import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';

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
      topLeft: cornerPosition == CardCornerPosition.topLeft ? radius : Radius.zero,
      topRight: cornerPosition == CardCornerPosition.topRight ? radius : Radius.zero,
      bottomLeft:
      cornerPosition == CardCornerPosition.bottomLeft ? radius : Radius.zero,
      bottomRight:
      cornerPosition == CardCornerPosition.bottomRight ? radius : Radius.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 98.h,
          width: 173,
          decoration: BoxDecoration(
            gradient:  LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.mainGold.withOpacity(0.7),
                AppColors.mainDark.withOpacity(0.7),

              ],
            ),
            borderRadius: _borderRadius,
            border: Border.all(color: AppColors.stroke),
          ),
          child: Row(
            children: [
              // Text
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingSmall),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: AppSizes.fontSizeSmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // Image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: _borderRadius.topRight,
                  bottomRight: _borderRadius.bottomRight,
                ),
                child: Image.asset(
                  imagePath,
                  width: 70.w,
                  height: double.infinity,
                  fit: BoxFit.fill, // 👈 important to match screenshot
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
