import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_preview_renderer.dart';
import 'package:mishka_app/features/saved/data/models/saved_detail_model.dart';
import 'package:mishka_app/features/saved/data/repositories/saved_repository.dart';
import 'package:mishka_app/features/saved/data/saved_detail_cache.dart';
import 'package:mishka_app/features/saved/data/saved_tutor_detail_helpers.dart';
import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';
import 'package:mishka_app/features/saved/presentation/screens/mind_map_result_screen.dart';
import 'package:mishka_app/features/saved/presentation/saved_share_delete_actions.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_focus_metrics.dart';
import 'package:mishka_app/features/saved/presentation/widgets/saved_tool_footer.dart';
import 'package:mishka_app/features/saved/presentation/widgets/saved_tutor_play_header.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class SavedMindMapPlayScreen extends StatefulWidget {
  const SavedMindMapPlayScreen({
    super.key,
    required this.savedListItemId,
    required this.title,
    this.sourceFileName,
    this.createdAt,
  });

  final String savedListItemId;
  final String title;
  final String? sourceFileName;
  final DateTime? createdAt;

  @override
  State<SavedMindMapPlayScreen> createState() => _SavedMindMapPlayScreenState();
}

class _SavedMindMapPlayScreenState extends State<SavedMindMapPlayScreen> {
  final SavedRepository _repository = SavedRepository();

  bool _loading = true;
  Object? _error;
  Map<String, dynamic>? _toolData;
  String? _displayTitle;
  String? _sourceFileName;
  DateTime? _createdAt;

  @override
  void initState() {
    super.initState();
    _displayTitle = widget.title;
    _sourceFileName = widget.sourceFileName;
    _createdAt = widget.createdAt;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _error = null);

    SavedLibraryDetail? cached;
    if (widget.savedListItemId.isNotEmpty) {
      cached = await SavedDetailCache.read(
        SavedContentKind.mindmap,
        widget.savedListItemId,
      );
    }

    if (!mounted) return;

    final hasUsefulCache = cached != null && cached.raw.isNotEmpty;
    if (hasUsefulCache) {
      await _applyDetail(cached);
      setState(() => _loading = false);
    } else {
      setState(() => _loading = true);
    }

    try {
      if (widget.savedListItemId.isEmpty) {
        throw ApiException(
          message: l10n.savedDetailMissingListId,
          error: 'MISSING_SAVED_LIST_ID',
        );
      }

      final detail =
          await _repository.getSavedMindMapDetail(widget.savedListItemId);
      await SavedDetailCache.write(
        SavedContentKind.mindmap,
        widget.savedListItemId,
        detail.raw,
      );

      if (!mounted) return;
      await _applyDetail(detail);
      setState(() {
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (hasUsefulCache) {
        setState(() {
          _loading = false;
          _error = null;
        });
        return;
      }
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _applyDetail(SavedLibraryDetail detail) async {
    _displayTitle = detail.resolvedTitle(widget.title);
    _sourceFileName ??=
        await _repository.resolveUploadFilename(detail.raw) ??
        widget.sourceFileName;
    _createdAt ??= readSavedCreatedAt(
      detail.raw,
      nestedKey: 'mindMap',
      nestedAliases: const ['mind_map'],
    ) ??
        widget.createdAt;
    _toolData = buildMindMapToolDataFromSavedDetail(
      detail.raw,
      fallbackTitle: widget.title,
    );
  }

  Future<void> _finishMindMap() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MindMapResultScreen(sourceId: widget.savedListItemId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = _displayTitle ?? widget.title;
    final fileName = _sourceFileName?.trim() ?? '';
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.savedMindMapTitle,
        topTitle: l10n.saved,
        showBack: true,
        showBottomBar: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(l10n)
              : _toolData == null
                  ? _buildEmpty(l10n)
                  : Padding(
                      padding: ToolFocusMetrics.playScreenPadding(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SavedTutorPlayHeader(
                            title: title,
                            sourceFileName: fileName,
                            trailingIcon: Icons.account_tree_outlined,
                            onShare: widget.savedListItemId.isEmpty
                                ? null
                                : () => shareSavedLibraryItem(
                                      context: context,
                                      repository: _repository,
                                      kind: SavedContentKind.mindmap,
                                      savedListItemId: widget.savedListItemId,
                                    ),
                          ),
                          SizedBox(height: ToolFocusMetrics.sectionGap(context)),
                          Expanded(
                            child: ToolPreviewRenderer(
                              toolData: _toolData!,
                              layout: ToolPreviewLayout.saved,
                            ),
                          ),
                          SizedBox(height: ToolFocusMetrics.sectionGap(context)),
                          SavedToolFooter(
                            onDone: _finishMindMap,
                            createdAt: _createdAt,
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.savedDetailNotFound,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeMedium,
                color: AppColors.greyText,
              ),
            ),
            SizedBox(height: 16.h),
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              color: AppColors.mainGold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Text(
          l10n.savedDetailPlaceholder,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: AppSizes.fontSizeMedium,
            color: AppColors.greyText,
          ),
        ),
      ),
    );
  }
}
