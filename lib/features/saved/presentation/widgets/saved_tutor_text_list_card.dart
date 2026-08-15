import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_focus_metrics.dart';
import 'package:mishka_app/features/saved/presentation/widgets/saved_library_card_theme.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

enum SavedTutorTextCardKind { summary, mindMap }

/// Saved summary / mind map list row — matches Mishka mockup.
class SavedTutorTextListCard extends StatelessWidget {
  const SavedTutorTextListCard({
    super.key,
    required this.kind,
    required this.index,
    required this.title,
    required this.sourceFileName,
    required this.createdAtLabel,
    required this.snippet,
    required this.onViewDetails,
    this.onRename,
    this.onShare,
  });

  final SavedTutorTextCardKind kind;
  final int index;
  final String title;
  final String sourceFileName;
  final String createdAtLabel;
  final String snippet;
  final VoidCallback onViewDetails;
  final VoidCallback? onRename;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trailingIcon = switch (kind) {
      SavedTutorTextCardKind.summary => Icons.description_outlined,
      SavedTutorTextCardKind.mindMap => Icons.account_tree_outlined,
    };
    final snippetMinHeight = ToolFocusMetrics.listPreviewTileHeight(context) * 0.55;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: SavedLibraryCardTheme.gold, width: 1),
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
                    color: SavedLibraryCardTheme.navy,
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
                      color: SavedLibraryCardTheme.navy,
                      size: ToolFocusMetrics.chromeIconSize(context),
                    ),
                  ),
                ),
              if (onShare != null)
                GestureDetector(
                  onTap: onShare,
                  child: Padding(
                    padding: EdgeInsets.only(left: 6.w, top: 1.h),
                    child: Icon(
                      Icons.share_outlined,
                      color: SavedLibraryCardTheme.gold,
                      size: ToolFocusMetrics.chromeIconSize(context),
                    ),
                  ),
                ),
              Icon(
                trailingIcon,
                color: SavedLibraryCardTheme.gold,
                size: ToolFocusMetrics.chromeIconSize(context),
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
              color: SavedLibraryCardTheme.navy,
            ),
          ),
          SizedBox(height: 3.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: SavedLibraryCardTheme.gold.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.picture_as_pdf_outlined,
                  color: SavedLibraryCardTheme.gold,
                  size: ToolFocusMetrics.chromeIconSize(context),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    sourceFileName.isNotEmpty ? sourceFileName : '—',
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: ToolFocusMetrics.chromeBodySize(context),
                      color: SavedLibraryCardTheme.muted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (snippet.isNotEmpty) ...[
            SizedBox(height: ToolFocusMetrics.chromeGap(context)),
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: snippetMinHeight),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: SavedLibraryCardTheme.gold.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: SavedLibraryCardTheme.gold.withValues(alpha: 0.3),
                  ),
                ),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: ToolFocusMetrics.chromeBodySize(context),
                      color: SavedLibraryCardTheme.navy,
                      height: 1.45,
                    ),
                    children: [
                      TextSpan(text: snippet),
                      if (snippet.endsWith('...'))
                        TextSpan(
                          text: ' ${l10n.savedSnippetMore}',
                          style: TextStyle(
                            color: SavedLibraryCardTheme.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
                    color: SavedLibraryCardTheme.orange,
                  ),
                ),
              ),
              Material(
                color: SavedLibraryCardTheme.gold,
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
