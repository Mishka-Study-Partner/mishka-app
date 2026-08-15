import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_focus_metrics.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_preview_renderer.dart';
import 'package:mishka_app/features/our_community/data/community_material_ref.dart';
import 'package:mishka_app/features/our_community/data/community_shared_material_loader.dart';
import 'package:mishka_app/features/our_community/presentation/screens/community_shared_material_play_screen.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Inline preview for a shared Mishka tutor item in community group chat.
class CommunitySharedMaterialPreview extends StatefulWidget {
  const CommunitySharedMaterialPreview({
    super.key,
    required this.materialRef,
    this.note,
  });

  final CommunityMaterialRef materialRef;
  final String? note;

  @override
  State<CommunitySharedMaterialPreview> createState() =>
      _CommunitySharedMaterialPreviewState();
}

class _CommunitySharedMaterialPreviewState
    extends State<CommunitySharedMaterialPreview> {
  final _loader = CommunitySharedMaterialLoader();
  Map<String, dynamic>? _toolData;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant CommunitySharedMaterialPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.materialRef.materialId != widget.materialRef.materialId ||
        oldWidget.materialRef.materialType != widget.materialRef.materialType) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _toolData = null;
    });
    try {
      final data = await _loader.loadToolData(widget.materialRef);
      if (!mounted) return;
      setState(() {
        _toolData = data;
        _loading = false;
        if (data == null) {
          _error = 'unavailable';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'failed';
      });
    }
  }

  String _materialLabel(AppLocalizations l10n) {
    final note = widget.note ?? widget.materialRef.note;
    if (note != null && note.isNotEmpty) return note;

    return switch (widget.materialRef.materialType) {
      'quiz' || 'quizzes' => l10n.savedQuizzes,
      'flashcard_set' || 'flashcards' => l10n.savedFlashCards,
      'summary' || 'summaries' => l10n.savedSummary,
      _ => l10n.savedMindMap,
    };
  }

  void _openFullScreen() {
    if (_toolData == null) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => CommunitySharedMaterialPlayScreen(
          materialRef: widget.materialRef,
          title: _materialLabel(AppLocalizations.of(context)!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _materialLabel(l10n),
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: ToolFocusMetrics.chromeBodySize(context),
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainDark,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.mainGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(color: AppColors.mainGold),
              ),
              child: Text(
                l10n.communityChatSharedFromMishka,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: ToolFocusMetrics.chromeLabelSize(context),
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainDark,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (_loading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_error != null || _toolData == null)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              l10n.savedDetailNotFound,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeSmall,
                color: AppColors.greyText,
              ),
            ),
          )
        else
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openFullScreen,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ToolPreviewRenderer(
                    toolData: _toolData!,
                    layout: ToolPreviewLayout.communityChat,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    l10n.communitySharedMaterialTapToOpen,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: AppSizes.fontSizeSmall,
                      color: AppColors.mainGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
