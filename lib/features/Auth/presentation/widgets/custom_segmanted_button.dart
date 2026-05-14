import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_sizes.dart';

class CustomSegmentedButton extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;
  final List<String> segments;

  const CustomSegmentedButton({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    final n = segments.length;
    final fontSize =
        n > 3 ? AppSizes.fontSizeSmall : AppSizes.fontSizeMedium;
    final barHeight = n > 3 ? 38.h : 32.h;

    return Container(
      width: double.infinity,
      height: barHeight,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.mainGold),
      ),
      child: Row(
        children: List.generate(n, (index) {
          final bool isSelected = index == selectedIndex;
          final radius = _radiusForSegment(index, n);

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.mainGold : Colors.transparent,
                  borderRadius: radius,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      segments[index],
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Pridi",
                        decoration: TextDecoration.none,
                        color:
                            isSelected ? AppColors.white : AppColors.mainGold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Outer corners only on first/last segment; preserves the 2-tab shape.
  BorderRadius _radiusForSegment(int index, int length) {
    if (length <= 1) {
      return BorderRadius.circular(4.r);
    }
    if (length == 2) {
      if (index == 0) {
        return BorderRadius.only(
          topLeft: Radius.circular(4.r),
          bottomLeft: Radius.circular(4.r),
          topRight: Radius.circular(8.r),
          bottomRight: Radius.circular(8.r),
        );
      }
      return BorderRadius.only(
        topLeft: Radius.circular(8.r),
        bottomLeft: Radius.circular(8.r),
        topRight: Radius.circular(4.r),
        bottomRight: Radius.circular(4.r),
      );
    }
    final corner = 4.r;
    if (index == 0) {
      return BorderRadius.only(
        topLeft: Radius.circular(corner),
        bottomLeft: Radius.circular(corner),
      );
    }
    if (index == length - 1) {
      return BorderRadius.only(
        topRight: Radius.circular(corner),
        bottomRight: Radius.circular(corner),
      );
    }
    return BorderRadius.zero;
  }
}


// to use it
/*
child:  CustomSegmentedButton(
selectedIndex: selectedIndex,
onChanged: (i) => setState(() => selectedIndex = i),
segments: const ['Email', 'phone Number'],
),

),
const SizedBox(height: 20),
/*
        // Here content changes
        Expanded(
          child: selectedIndex == 0
              ? const EmailLoginForm()
              : const PhoneLoginForm(),
        ),
*/
*/