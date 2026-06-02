import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';

class GeneratedMaterialToolbar extends StatelessWidget {
  const GeneratedMaterialToolbar({
    super.key,
    required this.onShare,
    required this.onSave,
    this.isBusy = false,
  });

  final VoidCallback onShare;
  final VoidCallback onSave;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h, right: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: isBusy ? null : onShare,
            icon: const Icon(Icons.share_outlined),
            color: AppColors.mainDark,
          ),
          IconButton(
            onPressed: isBusy ? null : onSave,
            icon: isBusy
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.bookmark_border),
            color: AppColors.mainDark,
          ),
        ],
      ),
    );
  }
}
