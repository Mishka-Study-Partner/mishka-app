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
    return Container(
      width: double.infinity,
      height: 32.h,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.mainGold),
      ),
      child: Row(
        children: List.generate(segments.length, (index) {
          final bool isSelected = index == selectedIndex;

          BorderRadius radius = BorderRadius.zero;
          if (segments.length == 2) {
            if (index == 0) {
              radius = BorderRadius.only(
                topLeft: Radius.circular(4.r),
                bottomLeft: Radius.circular(4.r),
                topRight: Radius.circular(8.r),
                bottomRight: Radius.circular(8.r),
              );
            } else {
              radius = BorderRadius.only(
                topLeft: Radius.circular(8.r),
                bottomLeft: Radius.circular(8.r),
                topRight: Radius.circular(4.r),
                bottomRight: Radius.circular(4.r),
              );
            }
          }

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
                child: Text(
                  segments[index],
                  style: TextStyle(
                    fontSize: AppSizes.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Pridi",
                    decoration: TextDecoration.none,
                    color: isSelected ? AppColors.white : AppColors.mainGold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
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