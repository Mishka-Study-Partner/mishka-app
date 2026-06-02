import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/chat_with_mishka/data/controller/chat_flow_controller.dart';
import 'package:mishka_app/features/chat_with_mishka/data/data_sources/saved_library_remote_data_source.dart';
import 'package:mishka_app/features/chat_with_mishka/data/service/mishka_ai_service.dart'
    as ai_service;
import 'package:mishka_app/features/community/presentation/share_community_flow.dart';
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
  bool _isSaving = false;
  bool _isSharing = false;
  String? _uploadedFileName;
  String? _summaryText;
  Map<String, dynamic>? _toolData;
  String? _sharedEntityId;

  @override
  void initState() {
    super.initState();
    _ai = ai_service.MishkaAiService();
    _savedLibrary = SavedLibraryRemoteDataSource(ApiService());
  }

  Future<void> _pickAndGenerate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: false,
    );
    if (result == null) return;
    final file = result.files.single;
    final path = file.path;
    if (path == null || path.isEmpty) return;

    setState(() {
      _isLoading = true;
      _uploadedFileName = file.name;
      _summaryText = null;
      _toolData = null;
      _sharedEntityId = null;
    });

    try {
      final action = switch (widget.kind) {
        DirectToolKind.quiz => StudyAction.quiz,
        DirectToolKind.flashcards => StudyAction.flashcards,
        DirectToolKind.mindmap => StudyAction.mindmap,
        DirectToolKind.summarize => StudyAction.summarize,
      };
      final explain = await _ai.explainPdf(
        pdfPath: path,
        summaryLevel: widget.kind == DirectToolKind.summarize
            ? 'simple'
            : 'detailed',
      );

      final tool = await _ai.generateTool(
        sessionId: explain.sessionId,
        action: action,
        complexity: 'Intermediate',
      );
      if (widget.kind == DirectToolKind.summarize) {
        setState(() {
          _summaryText = (tool['summary'] ?? explain.explanation).toString();
          _toolData = tool;
        });
      } else {
        setState(() => _toolData = tool);
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.generationFailed(e.toString()))));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

  Future<void> _copyGenerated() async {
    if (_isSharing) return;
    final selection = await pickCommunityGroupsForShare(context);
    if (selection == null || selection.groups.isEmpty) return;
    final data = _savePayload();
    if (data == null) return;

    setState(() => _isSharing = true);
    try {
      var entityId = _sharedEntityId;
      if (entityId == null || entityId.isEmpty) {
        entityId = await _savedLibrary.ensureGeneratedMaterialEntity(
          type: _savedType(),
          toolData: data,
        );
        _sharedEntityId = entityId;
      }

      await _savedLibrary.shareGeneratedMaterialToChannels(
        type: _savedType(),
        entityId: entityId,
        channelIds: selection.channelIds,
      );
      if (!mounted) return;
      await showShareCompletedFeedback(
        context: context,
        selection: selection,
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.shareFailed(e.toString()))));
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _saveGenerated() async {
    final data = _savePayload();
    if (data == null || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      await _savedLibrary.saveGeneratedMaterial(
        type: _savedType(),
        toolData: data,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.savedToYourLibrary)));
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.saveFailed(e.toString()))));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  SavedMaterialType _savedType() {
    return switch (widget.kind) {
      DirectToolKind.quiz => SavedMaterialType.quiz,
      DirectToolKind.flashcards => SavedMaterialType.flashcards,
      DirectToolKind.mindmap => SavedMaterialType.mindmap,
      DirectToolKind.summarize => SavedMaterialType.summary,
    };
  }

  Map<String, dynamic>? _savePayload() {
    final data = Map<String, dynamic>.from(_toolData ?? const {});
    if (widget.kind == DirectToolKind.summarize &&
        (_summaryText ?? '').isNotEmpty) {
      data['summary'] = _summaryText;
      data.putIfAbsent('title', () => widget.title);
    }
    return data.isEmpty ? null : data;
  }

  @override
  Widget build(BuildContext context) {
    final hasGenerated = _summaryText != null || _toolData != null;
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: widget.title,
        showBack: true,
        showBottomBar: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
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
                      AppLocalizations.of(context)!.fileLabel(_uploadedFileName!),
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
                child: _summaryText != null
                    ? Padding(
                        padding: EdgeInsets.all(14.r),
                        child: Text(
                          _summaryText!,
                          style: TextStyle(
                            fontFamily: 'Pridi',
                            fontSize: AppSizes.fontSizeMedium,
                            color: AppColors.mainDark,
                          ),
                        ),
                      )
                    : ToolPreviewRenderer(toolData: _toolData!),
                onShareTap: _copyGenerated,
                onSaveTap: _saveGenerated,
                isSaving: _isSaving || _isSharing,
              ),
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
    required this.isSaving,
  });

  final Widget child;
  final VoidCallback onShareTap;
  final Future<void> Function() onSaveTap;
  final bool isSaving;

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
                  onPressed: onShareTap,
                  icon: const Icon(Icons.share_outlined),
                  color: AppColors.mainDark,
                ),
                IconButton(
                  onPressed: isSaving ? null : onSaveTap,
                  icon: isSaving
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
          ),
          child,
        ],
      ),
    );
  }
}
