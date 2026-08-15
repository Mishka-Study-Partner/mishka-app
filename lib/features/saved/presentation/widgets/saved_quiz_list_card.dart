import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_focus_metrics.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Saved quiz list row — matches Mishka “Saved Quizzes” mockup.
class SavedQuizListCard extends StatelessWidget {
  const SavedQuizListCard({
    super.key,
    required this.index,
    required this.title,
    required this.sourceFileName,
    required this.questionCount,
    required this.createdAtLabel,
    required this.onViewDetails,
    this.onRename,
  });

  final int index;
  final String title;
  final String sourceFileName;
  final int questionCount;
  final String createdAtLabel;
  final VoidCallback onViewDetails;
  final VoidCallback? onRename;

  static const Color kNavy = Color(0xFF1A2A3A);
  static const Color kGold = Color(0xFFC9A66B);
  static const Color kMuted = Color(0xFF8A8A8A);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: kGold, width: 1),
      ),
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${index + 1}. $title',
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: ToolFocusMetrics.chromeTitleSize(context),
                    fontWeight: FontWeight.w700,
                    color: kNavy,
                    height: 1.2,
                  ),
                ),
              ),
              if (onRename != null)
                GestureDetector(
                  onTap: onRename,
                  child: Padding(
                    padding: EdgeInsets.only(left: 6.w, top: 1.h),
                    child: Icon(
                      Icons.edit_note_outlined,
                      color: kNavy,
                      size: ToolFocusMetrics.chromeIconSize(context),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: ToolFocusMetrics.chromeGap(context)),
          Text(
            l10n.savedQuizUploadedFileLabel,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: ToolFocusMetrics.chromeLabelSize(context),
              fontWeight: FontWeight.w600,
              color: kNavy,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Icon(
                Icons.picture_as_pdf_outlined,
                color: kGold,
                size: ToolFocusMetrics.chromeIconSize(context),
              ),
              if (sourceFileName.isNotEmpty) ...[
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    sourceFileName,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: ToolFocusMetrics.chromeBodySize(context),
                      color: kMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: ToolFocusMetrics.chromeGap(context)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: kGold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: kGold.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.savedQuizTypeMcq,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: ToolFocusMetrics.chromeLabelSize(context),
                    fontWeight: FontWeight.w600,
                    color: kNavy,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  l10n.savedQuizQuestionsCount(questionCount),
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: ToolFocusMetrics.chromeBodySize(context),
                    color: kMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ToolFocusMetrics.chromeGap(context)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  l10n.savedQuizCreatedOn(createdAtLabel),
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: ToolFocusMetrics.footerMetaSize(context),
                    color: kMuted,
                  ),
                ),
              ),
              Material(
                color: kGold,
                borderRadius: BorderRadius.circular(6.r),
                child: InkWell(
                  onTap: onViewDetails,
                  borderRadius: BorderRadius.circular(6.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 5.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.viewDetails,
                          style: TextStyle(
                            fontFamily: 'Pridi',
                            fontSize: ToolFocusMetrics.actionButtonFontSize(context),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: ToolFocusMetrics.chromeIconSize(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
