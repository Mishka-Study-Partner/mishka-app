import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_styles.dart';

/// Full-width, multi-line copy field for invite links and codes (no ellipsis).
class CommunityShareCopyField extends StatelessWidget {
  const CommunityShareCopyField({
    super.key,
    required this.value,
    this.icon = Icons.link,
  });

  final String value;
  final IconData icon;

  void _copy(BuildContext context) {
    if (value.isEmpty || value == '…') return;
    Clipboard.setData(ClipboardData(text: value));
    CommunityStyles.showSnackBar(
      context,
      AppLocalizations.of(context)!.linkCopied,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(6.r),
      child: InkWell(
        onTap: () => _copy(context),
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: AppColors.mainGold),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Icon(icon, color: AppColors.green, size: 18.w),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: SelectableText(
                  value,
                  style: CommunityStyles.body.copyWith(
                    color: AppColors.mainDark,
                    height: 1.35,
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.copy, color: AppColors.green, size: 20.w),
                onPressed: () => _copy(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
