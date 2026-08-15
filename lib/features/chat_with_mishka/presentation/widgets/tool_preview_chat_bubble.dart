import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/features/chat_with_mishka/data/data_sources/saved_library_remote_data_source.dart';
import 'package:mishka_app/features/chat_with_mishka/data/generated_material_helper.dart';
import 'package:mishka_app/features/chat_with_mishka/data/quiz_progress_cache.dart';
import 'package:mishka_app/features/chat_with_mishka/data/quiz_progress_metadata.dart';
import 'package:mishka_app/features/chat_with_mishka/data/tool_data_normalizer.dart';
import 'package:mishka_app/features/chat_with_mishka/data/tool_save_metadata.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/screens/flashcards_screen.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/screens/mindmap_screen.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/screens/quiz_screen.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/generated_material_card.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/study_text_utils.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_preview_renderer.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class ToolPreviewChatBubble extends StatefulWidget {
  const ToolPreviewChatBubble({
    super.key,
    required this.toolData,
    required this.savedLibrary,
    this.messageTime,
    this.storageMessageId,
    this.onToolDataUpdated,
  });

  final Map<String, dynamic> toolData;
  final SavedLibraryRemoteDataSource savedLibrary;
  final DateTime? messageTime;
  final String? storageMessageId;
  final ValueChanged<Map<String, dynamic>>? onToolDataUpdated;

  @override
  State<ToolPreviewChatBubble> createState() => _ToolPreviewChatBubbleState();
}

class _ToolPreviewChatBubbleState extends State<ToolPreviewChatBubble> {
  bool _isBusy = false;
  String? _savedLibraryId;
  String? _sharedEntityId;

  Map<String, dynamic> get _data => QuizProgressCache.mergeStoredProgress(
        normalizeToolData(widget.toolData),
        widget.storageMessageId,
      );

  GeneratedMaterialHelper get _helper =>
      GeneratedMaterialHelper(context, widget.savedLibrary);

  @override
  void initState() {
    super.initState();
    _hydrateSavedState(from: _data);
  }

  @override
  void didUpdateWidget(covariant ToolPreviewChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.toolData != widget.toolData) {
      _hydrateSavedState(from: _data);
    }
  }

  void _hydrateSavedState({required Map<String, dynamic> from}) {
    final type = savedTypeForToolData(from);
    _savedLibraryId = readSavedLibraryId(from);
    _sharedEntityId = readEntityIdFromToolData(from, type);
    if (_savedLibraryId == null) {
      _resolveSavedStateFromBackend(type);
    }
  }

  Future<void> _resolveSavedStateFromBackend(SavedMaterialType type) async {
    final entityId = _sharedEntityId;
    if (entityId == null || entityId.isEmpty) return;

    final rowId = await widget.savedLibrary.lookupSavedRowId(
      type: type,
      entityId: entityId,
    );
    if (!mounted || rowId == null) return;
    setState(() => _savedLibraryId = rowId);
  }

  String _title(AppLocalizations l10n) {
    final type = (_data['tool_type'] ?? '').toString();
    return switch (type) {
      'flashcards' => l10n.thisIsYourFlashcards,
      'quizzes' || 'quiz' => l10n.hereIsYourQuiz,
      'summaries' || 'summary' || 'summarize' => l10n.hereIsYourSummarizedArticle,
      'mind_maps' || 'mindmap' => l10n.chatToolMindMap,
      _ => l10n.hereIsYourSummarizedArticle,
    };
  }

  Future<void> _onShare() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await _helper.shareTool(
        toolData: _data,
        savedLibraryId: _savedLibraryId,
        sharedEntityId: _sharedEntityId,
        onEntityId: (id) => _sharedEntityId = id,
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _onSave() async {
    if (_isBusy || _savedLibraryId != null) return;
    setState(() => _isBusy = true);
    try {
      final ref = await _helper.saveTool(_data);
      if (!mounted || ref == null) return;

      final type = savedTypeForToolData(_data);
      final updated = applySaveMetadata(
        toolData: _data,
        ref: ref,
        type: type,
      );
      setState(() {
        _savedLibraryId = ref.savedId;
        _sharedEntityId = ref.entityId;
      });
      widget.onToolDataUpdated?.call(updated);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _onExpand() {
    final type = (_data['tool_type'] ?? '').toString();
    final route = switch (type) {
      'flashcards' => MaterialPageRoute<void>(
          builder: (_) => FlashcardsScreen(toolData: _data),
        ),
      'quizzes' || 'quiz' => MaterialPageRoute<void>(
          builder: (_) => QuizScreen(
            toolData: _data,
            storageMessageId: widget.storageMessageId,
            onToolDataUpdated: widget.onToolDataUpdated,
          ),
        ),
      'mind_maps' || 'mindmap' => MaterialPageRoute<void>(
          builder: (_) => MindmapScreen(toolData: _data),
        ),
      _ => null,
    };
    if (route != null) Navigator.of(context).push(route);
  }

  void _onQuizRetry() {
    if (!isQuizToolData(_data)) return;
    final messageId = widget.storageMessageId;
    if (messageId != null && messageId.isNotEmpty) {
      unawaited(QuizProgressCache.clear(messageId));
    }
    widget.onToolDataUpdated?.call(clearQuizProgress(_data));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final time = widget.messageTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GeneratedMaterialCard(
          title: _title(l10n),
          isBusy: _isBusy,
          isSaved: _savedLibraryId != null,
          onShare: _onShare,
          onExpand: _onExpand,
          onSave: _onSave,
          onRefresh: isQuizToolData(_data) ? _onQuizRetry : null,
          child: ToolPreviewRenderer(
            toolData: _data,
            embedded: true,
            storageMessageId: widget.storageMessageId,
            onToolDataUpdated: widget.onToolDataUpdated,
          ),
        ),
        if (time != null)
          Padding(
            padding: EdgeInsets.only(left: 16.w, bottom: 4.h),
            child: Text(
              formatChatTime(time),
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: 11.sp,
                color: AppColors.greyText,
              ),
            ),
          ),
      ],
    );
  }
}
