import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_focus_metrics.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Saved flashcard list row — matches Mishka “Saved Flash Cards” mockup.
class SavedFlashcardListCard extends StatelessWidget {
  const SavedFlashcardListCard({
    super.key,
    required this.index,
    required this.title,
    required this.sourceFileName,
    required this.createdAtLabel,
    required this.previewLabels,
    required this.onViewDetails,
    this.onRename,
  });

  final int index;
  final String title;
  final String sourceFileName;
  final String createdAtLabel;
  final List<String> previewLabels;
  final VoidCallback onViewDetails;
  final VoidCallback? onRename;

  static const Color kNavy = Color(0xFF1A2A3A);
  static const Color kGold = Color(0xFFC9A66B);
  static const Color kMuted = Color(0xFF8A8A8A);
  static const Color kOrange = Color(0xFFD4845A);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final previewHeight = ToolFocusMetrics.listPreviewTileHeight(context);

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
                )
              else
                Icon(
                  Icons.folder_copy_outlined,
                  color: kGold,
                  size: ToolFocusMetrics.chromeIconSize(context),
                ),
            ],
          ),
          SizedBox(height: ToolFocusMetrics.chromeGap(context)),
          SizedBox(
            height: previewHeight,
            child: Row(
              children: List.generate(3, (i) {
                final label = i < previewLabels.length ? previewLabels[i] : '';
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 6.w : 0),
                    child: _FlashcardPreviewTile(label: label),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: ToolFocusMetrics.chromeGap(context)),
          Text(
            l10n.savedFlashcardSourcePrompt,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: ToolFocusMetrics.chromeLabelSize(context),
              fontWeight: FontWeight.w600,
              color: kNavy,
            ),
          ),
          SizedBox(height: 3.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: kGold.withValues(alpha: 0.45)),
            ),
            child: Row(
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
                    color: kOrange,
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

/// Mini flip-card preview — image area is the focus.
class _FlashcardPreviewTile extends StatelessWidget {
  const _FlashcardPreviewTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: SavedFlashcardListCard.kGold, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(5.w, 5.w, 5.w, 2.h),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: ToolFocusMetrics.flashcardIconContainerSize(
                  context,
                  large: false,
                ),
                height: ToolFocusMetrics.flashcardIconContainerSize(
                  context,
                  large: false,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightFrameBackground,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.menu_book_outlined,
                  color: SavedFlashcardListCard.kGold,
                  size: ToolFocusMetrics.flashcardPreviewTileIconSize(context),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 5.h),
              child: Center(
                child: Text(
                  label.isNotEmpty ? label : '—',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: ToolFocusMetrics.footerMetaSize(context),
                    fontWeight: FontWeight.w600,
                    color: SavedFlashcardListCard.kNavy,
                    height: 1.15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
