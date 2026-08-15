import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_focus_metrics.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class SavedTutorPlayHeader extends StatelessWidget {
  const SavedTutorPlayHeader({
    super.key,
    required this.title,
    required this.sourceFileName,
    this.trailingIcon = Icons.description_outlined,
    this.compact = true,
    this.onShare,
  });

  final String title;
  final String sourceFileName;
  final IconData trailingIcon;

  /// Smaller title/file chrome so the tool preview gets more space.
  final bool compact;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final file = sourceFileName.trim();

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: ToolFocusMetrics.chromeTitleSize(context),
                    fontWeight: FontWeight.w700,
                    color: AppColors.mainDark,
                    height: 1.2,
                  ),
                ),
              ),
              if (onShare != null) ...[
                IconButton(
                  onPressed: onShare,
                  tooltip: l10n.share,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: ToolFocusMetrics.chromeIconSize(context) + 8,
                    minHeight: ToolFocusMetrics.chromeIconSize(context) + 8,
                  ),
                  icon: Icon(
                    Icons.share_outlined,
                    color: AppColors.mainGold,
                    size: ToolFocusMetrics.chromeIconSize(context),
                  ),
                ),
                SizedBox(width: 4.w),
              ],
              Icon(
                trailingIcon,
                color: AppColors.mainGold,
                size: ToolFocusMetrics.chromeIconSize(context),
              ),
            ],
          ),
          if (file.isNotEmpty) ...[
            SizedBox(height: ToolFocusMetrics.chromeGap(context)),
            Row(
              children: [
                Icon(
                  Icons.picture_as_pdf_outlined,
                  color: AppColors.mainGold,
                  size: ToolFocusMetrics.chromeIconSize(context),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    file,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: ToolFocusMetrics.chromeBodySize(context),
                      fontWeight: FontWeight.w500,
                      color: AppColors.greyText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                '$title:',
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mainDark,
                ),
              ),
            ),
            Icon(
              trailingIcon,
              color: AppColors.mainGold,
              size: 26.sp,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          l10n.savedQuizUploadedFileLabel,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.mainDark,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.picture_as_pdf_outlined,
                color: AppColors.mainGold,
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (file.isNotEmpty)
                      Text(
                        file,
                        style: TextStyle(
                          fontFamily: 'Pridi',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainDark,
                        ),
                      ),
                    if (file.isNotEmpty) SizedBox(height: 4.h),
                    Text(
                      l10n.savedFlashcardFileTypePdf,
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: 13.sp,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
