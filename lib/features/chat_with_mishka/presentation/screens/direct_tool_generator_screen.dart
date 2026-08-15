import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/chat_with_mishka/data/ai_service_logger.dart';
import 'package:mishka_app/features/chat_with_mishka/data/ai_response_helpers.dart';
import 'package:mishka_app/features/chat_with_mishka/data/chat_pdf_cache.dart';
import 'package:mishka_app/features/chat_with_mishka/data/generated_material_helper.dart';
import 'package:mishka_app/features/chat_with_mishka/data/tool_data_normalizer.dart';
import 'package:mishka_app/features/chat_with_mishka/data/ai_service_config.dart';
import 'package:mishka_app/features/chat_with_mishka/data/controller/chat_flow_controller.dart';
import 'package:mishka_app/features/chat_with_mishka/data/data_sources/saved_library_remote_data_source.dart';
import 'package:mishka_app/features/chat_with_mishka/data/service/mishka_ai_service.dart'
    as ai_service;
import 'package:mishka_app/features/chat_with_mishka/data/tool_save_metadata.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/screens/flashcards_screen.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/screens/mindmap_screen.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/screens/quiz_screen.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/formatted_study_text.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_preview_renderer.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

enum DirectToolKind { summarize, quiz, flashcards, mindmap }

class DirectToolGeneratorScreen extends StatefulWidget {
  const DirectToolGeneratorScreen({
    super.key,
    required this.kind,
    required this.title,
  });

  final DirectToolKind kind;
  final String title;

  @override
  State<DirectToolGeneratorScreen> createState() =>
      _DirectToolGeneratorScreenState();
}

class _DirectToolGeneratorScreenState extends State<DirectToolGeneratorScreen> {
  late final ai_service.MishkaAiService _ai;
  late final SavedLibraryRemoteDataSource _savedLibrary;
  bool _isLoading = false;
  bool _isBusy = false;
  String? _uploadedFileName;
  String? _summaryText;
  Map<String, dynamic>? _toolData;
  String? _savedLibraryId;
  String? _sharedEntityId;

  @override
  void initState() {
    super.initState();
    _ai = ai_service.MishkaAiService();
    _savedLibrary = SavedLibraryRemoteDataSource(ApiService());
    if (kDebugMode) {
      debugPrint(
        'DirectToolGenerator (${widget.kind.name}) → AI ${AiServiceConfig.baseUrl}',
      );
    }
  }

  GeneratedMaterialHelper get _helper =>
      GeneratedMaterialHelper(context, _savedLibrary);

  StudyAction get _studyAction => switch (widget.kind) {
        DirectToolKind.quiz => StudyAction.quiz,
        DirectToolKind.flashcards => StudyAction.flashcards,
        DirectToolKind.mindmap => StudyAction.mindmap,
        DirectToolKind.summarize => StudyAction.summarize,
      };

  Map<String, dynamic> _normalizedData() {
    if (widget.kind == DirectToolKind.summarize) {
      final text = (_summaryText ?? '').trim();
      if (text.isEmpty) return const {};
      return buildSummaryToolData(
        summary: text,
        title: widget.title,
      );
    }
    if (_toolData == null) return const {};
    return _normalizeToolData(_toolData!);
  }

  Map<String, dynamic> _normalizeToolData(Map<String, dynamic> raw) {
    final withType = Map<String, dynamic>.from(raw);
    withType['tool_type'] = switch (widget.kind) {
      DirectToolKind.quiz => 'quizzes',
      DirectToolKind.flashcards => 'flashcards',
      DirectToolKind.mindmap => 'mind_maps',
      DirectToolKind.summarize => 'summaries',
    };
    final data = normalizeToolData(withType);
    data.putIfAbsent('title', () => widget.title);
    attachSourceFileMetadata(
      data,
      uploadOriginalFilename: _uploadedFileName,
    );
    return data;
  }

  Future<void> _pickAndGenerate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );
    if (result == null) return;
    final file = result.files.single;

    String stagedPath;
    try {
      stagedPath = await ChatPdfCache.stagePickedPdf(
        sourcePath: file.path,
        bytes: file.bytes,
      );
    } catch (_) {
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadedFileName = file.name;
      _summaryText = null;
      _toolData = null;
      _savedLibraryId = null;
      _sharedEntityId = null;
    });

    try {
      final explain = await _ai.explainPdf(
        pdfPath: stagedPath,
        summaryLevel: widget.kind == DirectToolKind.summarize
            ? 'simple'
            : 'detailed',
      );
      if (explain.sessionId.isEmpty) {
        throw Exception('Upload succeeded but AI returned no session_id');
      }

      if (widget.kind == DirectToolKind.summarize) {
        final summary = explain.explanation.trim();
        if (summary.isEmpty) {
          throw Exception('Upload returned empty summary');
        }
        setState(() {
          _summaryText = summary;
          _toolData = buildSummaryToolData(
            summary: summary,
            title: widget.title,
          );
          attachSourceFileMetadata(
            _toolData!,
            uploadOriginalFilename: _uploadedFileName,
          );
        });
        return;
      }

      final tool = await _ai.generateTool(
        sessionId: explain.sessionId,
        action: _studyAction,
        complexity: 'Intermediate',
      );
      setState(() => _toolData = _normalizeToolData(tool.toolData));
    } catch (e, st) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final message = e is AiSessionNotFoundException ||
              e is ChatSessionNotFoundException
          ? l10n.chatAiSessionExpired
          : AiResponseHelpers.looksLikeConnectionFailure(e)
              ? l10n.chatAiServerUnreachable
              : e is AiServiceException ||
                  AiResponseHelpers.looksLikeProviderError(e.toString())
              ? (e is AiServiceException &&
                      e.detail?.toLowerCase().contains('ngrok') == true
                  ? e.detail!
                  : l10n.chatAiServiceUnavailable)
              : l10n.generationFailed(_formatError(e));
      logAiServiceError(
        operation: 'DirectToolGenerator ${widget.kind.name}',
        error: e,
        stackTrace: st,
        baseUrl: _ai.baseUrl,
        userFacingMessage: message,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatError(Object error) {
    if (error is ApiException) return error.userMessage;
    return error.toString();
  }

  Future<void> _copyGenerated() async {
    if (_isBusy) return;
    final data = _normalizedData();
    if (data.isEmpty) return;

    setState(() => _isBusy = true);
    try {
      await _helper.shareTool(
        toolData: data,
        savedLibraryId: _savedLibraryId,
        sharedEntityId: _sharedEntityId,
        onEntityId: (id) => setState(() => _sharedEntityId = id),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _saveGenerated() async {
    if (_isBusy || _savedLibraryId != null) return;
    final data = _normalizedData();
    if (data.isEmpty) return;

    setState(() => _isBusy = true);
    try {
      final ref = await _helper.saveTool(data);
      if (!mounted || ref == null) return;
      final type = savedTypeForToolData(data);
      final updated = applySaveMetadata(
        toolData: data,
        ref: ref,
        type: type,
      );
      setState(() {
        _toolData = updated;
        _savedLibraryId = ref.savedId;
        _sharedEntityId = ref.entityId;
      });
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _expandGenerated() {
    final data = _normalizedData();
    if (data.isEmpty) return;

    final route = switch (widget.kind) {
      DirectToolKind.flashcards => MaterialPageRoute<void>(
          builder: (_) => FlashcardsScreen(toolData: data),
        ),
      DirectToolKind.quiz => MaterialPageRoute<void>(
          builder: (_) => QuizScreen(toolData: data),
        ),
      DirectToolKind.mindmap => MaterialPageRoute<void>(
          builder: (_) => MindmapScreen(toolData: data),
        ),
      DirectToolKind.summarize => null,
    };
    if (route != null) {
      Navigator.of(context).push(route);
    }
  }

  String _uploadPrompt() {
    final l10n = AppLocalizations.of(context)!;
    return switch (widget.kind) {
      DirectToolKind.summarize => l10n.uploadMaterialToGenerateSummary,
      DirectToolKind.quiz => l10n.uploadMaterialToGenerateQuiz,
      DirectToolKind.flashcards => l10n.uploadMaterialToGenerateFlashcards,
      DirectToolKind.mindmap => l10n.uploadMaterialToGenerateMindMap,
    };
  }

  Widget _buildPreview() {
    if (_summaryText != null && widget.kind == DirectToolKind.summarize) {
      return Padding(
        padding: EdgeInsets.all(14.r),
        child: FormattedStudyText(
          text: _summaryText!,
          textAlign: TextAlign.justify,
          baseStyle: TextStyle(
            fontFamily: 'Pridi',
            fontSize: AppSizes.fontSizeMedium,
            color: AppColors.mainDark,
            height: 1.45,
          ),
        ),
      );
    }
    return ToolPreviewRenderer(
      toolData: _normalizedData(),
      layout: widget.kind == DirectToolKind.quiz
          ? ToolPreviewLayout.embedded
          : widget.kind == DirectToolKind.flashcards
              ? ToolPreviewLayout.embedded
              : ToolPreviewLayout.embedded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasGenerated = _summaryText != null || _toolData != null;
    final canExpand = widget.kind != DirectToolKind.summarize;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: widget.title,
        showBack: true,
        showBottomBar: false,
      ),
      body: SingleChildScrollView(
        padding: AppScrollInsets.page(
          horizontal: AppSizes.paddingMedium,
          top: AppSizes.paddingMedium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.stroke),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _uploadPrompt(),
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: AppSizes.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainDark,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (_uploadedFileName != null)
                    Text(
                      AppLocalizations.of(context)!
                          .fileLabel(_uploadedFileName!),
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: AppSizes.fontSizeSmall,
                        color: AppColors.lightText,
                      ),
                    ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickAndGenerate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainGold,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                      ),
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        _isLoading
                            ? AppLocalizations.of(context)!.generating
                            : AppLocalizations.of(context)!.uploadMaterial,
                        style: TextStyle(
                          fontFamily: 'Pridi',
                          fontSize: AppSizes.fontSizeMedium,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (hasGenerated)
              _GeneratedBubble(
                onShareTap: _copyGenerated,
                onExpandTap: canExpand ? _expandGenerated : null,
                onSaveTap: _saveGenerated,
                isSaved: _savedLibraryId != null,
                isBusy: _isBusy,
                child: _buildPreview(),
              ),
            const ScreenEndSpacer(),
          ],
        ),
      ),
    );
  }
}

class _GeneratedBubble extends StatelessWidget {
  const _GeneratedBubble({
    required this.child,
    required this.onShareTap,
    required this.onSaveTap,
    this.onExpandTap,
    this.isSaved = false,
    this.isBusy = false,
  });

  final Widget child;
  final VoidCallback onShareTap;
  final VoidCallback? onExpandTap;
  final Future<void> Function() onSaveTap;
  final bool isSaved;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.mainDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 8.h, right: 8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: isBusy ? null : onShareTap,
                  icon: const Icon(Icons.share_outlined),
                  color: AppColors.mainDark,
                ),
                if (onExpandTap != null)
                  IconButton(
                    onPressed: isBusy ? null : onExpandTap,
                    icon: const Icon(Icons.open_in_full),
                    color: AppColors.mainDark,
                  ),
                IconButton(
                  onPressed: isBusy || isSaved ? null : () => onSaveTap(),
                  icon: isBusy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved ? AppColors.mainGold : AppColors.mainDark,
                        ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
            child: child,
          ),
        ],
      ),
    );
  }
}
