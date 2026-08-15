import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_preview_renderer.dart';
import 'package:mishka_app/features/our_community/data/community_material_ref.dart';
import 'package:mishka_app/features/our_community/data/community_shared_material_loader.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Full-screen study view for a shared community material message.
class CommunitySharedMaterialPlayScreen extends StatefulWidget {
  const CommunitySharedMaterialPlayScreen({
    super.key,
    required this.materialRef,
    this.title,
  });

  final CommunityMaterialRef materialRef;
  final String? title;

  @override
  State<CommunitySharedMaterialPlayScreen> createState() =>
      _CommunitySharedMaterialPlayScreenState();
}

class _CommunitySharedMaterialPlayScreenState
    extends State<CommunitySharedMaterialPlayScreen> {
  final _loader = CommunitySharedMaterialLoader();
  Map<String, dynamic>? _toolData;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
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
        if (data == null) _error = 'unavailable';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'failed';
      });
    }
  }

  String _defaultTitle(AppLocalizations l10n) {
    return switch (widget.materialRef.materialType) {
      'quiz' || 'quizzes' => l10n.savedQuizzes,
      'flashcard_set' || 'flashcards' => l10n.savedFlashCards,
      'summary' || 'summaries' => l10n.savedSummary,
      _ => l10n.savedMindMap,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = widget.title ??
        widget.materialRef.note ??
        _defaultTitle(l10n);

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: title,
        showBack: true,
        showBottomBar: true,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null || _toolData == null
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Text(
                        l10n.savedDetailNotFound,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Pridi',
                          color: AppColors.greyText,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
                          child: ToolPreviewRenderer(
                            toolData: _toolData!,
                            layout: ToolPreviewLayout.expanded,
                          ),
                        ),
                      ),
                      const ScreenEndSpacer(),
                    ],
                  ),
      ),
    );
  }
}
