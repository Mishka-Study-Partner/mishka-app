import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/chat_with_mishka/data/tool_data_normalizer.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/formatted_study_text.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_preview_renderer.dart';
import 'package:mishka_app/features/saved/data/models/saved_detail_model.dart';
import 'package:mishka_app/features/saved/data/repositories/saved_repository.dart';
import 'package:mishka_app/features/saved/data/saved_detail_cache.dart';
import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';
import 'package:mishka_app/features/saved/presentation/saved_rename_actions.dart';
import 'package:mishka_app/features/saved/presentation/saved_share_delete_actions.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class SavedItemDetailScreen extends StatefulWidget {
  const SavedItemDetailScreen({
    super.key,
    required this.kind,
    /// Same as list row `id` → `GET /saved-*/{id}`.
    required this.savedListItemId,
    required this.title,
  });

  final SavedContentKind kind;
  final String savedListItemId;
  final String title;

  @override
  State<SavedItemDetailScreen> createState() => _SavedItemDetailScreenState();
}

class _SavedItemDetailScreenState extends State<SavedItemDetailScreen> {
  final SavedRepository _repository = SavedRepository();

  bool _loading = true;
  SavedLibraryDetail? _detail;
  Object? _error;
  String? _displayTitle;

  @override
  void initState() {
    super.initState();
    _displayTitle = widget.title;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _load();
      }
    });
  }

  String _userFacingError(AppLocalizations l10n, Object error) {
    if (error is ApiException) {
      final friendly = _friendlyMessageForErrorCode(l10n, error.error);
      if (friendly != null) {
        return friendly;
      }
      return error.message;
    }
    return error.toString();
  }

  String? _friendlyMessageForErrorCode(AppLocalizations l10n, String? code) {
    switch (code) {
      case 'QUIZ_NOT_FOUND':
      case 'FLASHCARD_SET_NOT_FOUND':
      case 'SUMMARY_NOT_FOUND':
      case 'MIND_MAP_NOT_FOUND':
        return l10n.savedDetailItemUnavailable;
      case 'SAVED_LIBRARY_NOT_SAVED':
        return l10n.savedDetailNotInLibraryAnymore;
      case 'NOT_FOUND':
        return l10n.savedDetailNotFound;
      default:
        return null;
    }
  }

  Future<void> _load() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _error = null;
    });

    SavedLibraryDetail? cached;
    if (widget.savedListItemId.isNotEmpty) {
      cached = await SavedDetailCache.read(widget.kind, widget.savedListItemId);
    }

    if (!mounted) return;

    final hasUsefulCache = cached != null && cached.raw.isNotEmpty;
    if (hasUsefulCache) {
      setState(() {
        _detail = cached;
        _loading = false;
      });
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

      final detail = await switch (widget.kind) {
        SavedContentKind.flashcards =>
          _repository.getSavedFlashcardSetDetail(widget.savedListItemId),
        SavedContentKind.quiz =>
          _repository.getSavedQuizDetail(widget.savedListItemId),
        SavedContentKind.summary =>
          _repository.getSavedSummaryDetail(widget.savedListItemId),
        SavedContentKind.mindmap =>
          _repository.getSavedMindMapDetail(widget.savedListItemId),
      };

      await SavedDetailCache.write(
        widget.kind,
        widget.savedListItemId,
        detail.raw,
      );

      if (!mounted) return;
      setState(() {
        _detail = detail;
        _displayTitle = detail.resolvedTitle(widget.title);
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = _userFacingError(l10n, e);

      if (e is ApiException && e.error == 'SAVED_LIBRARY_NOT_SAVED') {
        await SavedDetailCache.clear(widget.kind, widget.savedListItemId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorPrefix}: $msg')),
        );
        Navigator.of(context).pop(true);
        return;
      }

      if (hasUsefulCache) {
        setState(() {
          _loading = false;
          _error = null;
        });
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorPrefix}: $msg')),
      );
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final resolvedTitle =
        _displayTitle ?? _detail?.resolvedTitle(widget.title) ?? widget.title;
    final entityId = _detail?.tutorEntityId(widget.kind) ?? '';

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: resolvedTitle,
        topTitle: l10n.saved,
        showBack: true,
        showBottomBar: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _kindLabel(l10n),
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.mainDark,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '${l10n.view} · id: ${widget.savedListItemId}',
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeSmall,
                color: AppColors.greyText,
              ),
            ),
            if (widget.savedListItemId.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: entityId.isEmpty
                        ? null
                        : () async {
                            final renamed = await showRenameSavedItemDialog(
                              context: context,
                              repository: _repository,
                              kind: widget.kind,
                              entityId: entityId,
                              currentTitle: resolvedTitle,
                            );
                            if (!context.mounted || !renamed) return;
                            setState(() => _loading = true);
                            await _load();
                          },
                    icon: Icon(
                      Icons.drive_file_rename_outline,
                      size: 18.sp,
                      color: AppColors.mainGold,
                    ),
                    label: Text(
                      l10n.renameSavedItem,
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        color: AppColors.mainDark,
                        fontSize: AppSizes.fontSizeSmall,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      shareSavedLibraryItem(
                        context: context,
                        repository: _repository,
                        kind: widget.kind,
                        savedListItemId: widget.savedListItemId,
                      );
                    },
                    icon: Icon(
                      Icons.share_outlined,
                      size: 18.sp,
                      color: AppColors.mainGold,
                    ),
                    label: Text(
                      l10n.share,
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        color: AppColors.mainDark,
                        fontSize: AppSizes.fontSizeSmall,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final removed = await confirmAndDeleteSavedLibraryItem(
                        context: context,
                        repository: _repository,
                        kind: widget.kind,
                        savedListItemId: widget.savedListItemId,
                      );
                      if (!context.mounted) return;
                      if (removed) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      size: 18.sp,
                      color: AppColors.red,
                    ),
                    label: Text(
                      l10n.delete,
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        color: AppColors.mainDark,
                        fontSize: AppSizes.fontSizeSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 24.h),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: AppSizes.screenEndPadding),
                child: _buildBody(l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                _userFacingError(l10n, _error!),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: AppSizes.fontSizeMedium,
                  color: AppColors.greyText,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              tooltip: MaterialLocalizations.of(context)
                  .refreshIndicatorSemanticLabel,
              color: AppColors.mainGold,
            ),
          ],
        ),
      );
    }
    final detail = _detail;
    if (detail == null || detail.raw.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: SingleChildScrollView(
            child: Text(
              l10n.savedDetailPlaceholder,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeMedium,
                color: AppColors.mainDark,
                height: 1.4,
              ),
            ),
          ),
        ),
      );
    }

    final toolData = _extractToolData(detail);
    if (toolData != null) {
      return SingleChildScrollView(
        child: ToolPreviewRenderer(toolData: toolData),
      );
    }

    // Fallback: summary text or plain readable content
    final summaryText = _extractSummaryText(detail);
    if (summaryText != null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: SingleChildScrollView(
            child: FormattedStudyText(
              text: summaryText,
              textAlign: TextAlign.justify,
              baseStyle: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeMedium,
                color: AppColors.mainDark,
                height: 1.5,
              ),
            ),
          ),
        ),
      );
    }

    // Last resort: formatted JSON
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: SingleChildScrollView(
          child: SelectableText(
            detail.formattedJson,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: AppSizes.fontSizeSmall,
              color: AppColors.mainDark,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }

  /// Extracts tool data formatted for [ToolPreviewRenderer] from the saved detail.
  Map<String, dynamic>? _extractToolData(SavedLibraryDetail detail) {
    final raw = detail.raw;

    switch (widget.kind) {
      case SavedContentKind.flashcards:
        final nested = raw['flashcardSet'] ?? raw['flashcard_set'] ?? raw['set'];
        final content = nested is Map ? Map<String, dynamic>.from(nested) : raw;
        final cards = content['cards'] ?? content['flashcards'];
        if (cards is List && cards.isNotEmpty) {
          return {
            'tool_type': 'flashcards',
            'title': content['title'] ?? content['name'] ?? '',
            'cards': cards,
          };
        }
        return null;

      case SavedContentKind.quiz:
        return buildQuizToolDataFromSavedDetail(
          raw,
          fallbackTitle: widget.title,
        );

      case SavedContentKind.mindmap:
        final nested = raw['mindMap'] ?? raw['mind_map'];
        final content = nested is Map ? Map<String, dynamic>.from(nested) : raw;
        final apiTree = content['content'];
        if (apiTree is Map && (apiTree['children'] as List?)?.isNotEmpty == true) {
          return normalizeToolData({
            'tool_type': 'mind_maps',
            'title': content['title'] ?? content['name'] ?? '',
            'content': apiTree,
          });
        }
        final nodes = content['nodes'];
        final root = content['root'] ?? content['centralTopic'] ?? content['title'];
        if (nodes is List && nodes.isNotEmpty && root != null) {
          return {
            'tool_type': 'mind_maps',
            'title': content['title'] ?? content['name'] ?? '',
            'root': root.toString(),
            'nodes': nodes,
          };
        }
        return null;

      case SavedContentKind.summary:
        return null; // Summaries render as plain text
    }
  }

  /// Extracts human-readable summary text from the saved detail.
  String? _extractSummaryText(SavedLibraryDetail detail) {
    if (widget.kind != SavedContentKind.summary) return null;
    final raw = detail.raw;
    final nested = raw['summary'];
    if (nested is Map) {
      final content = Map<String, dynamic>.from(nested);
      final text = content['summaryText'] ??
          content['text'] ??
          content['content'] ??
          content['summary'];
      if (text is String && text.isNotEmpty) return text;
    }
    if (nested is String && nested.isNotEmpty) return nested;
    final text = raw['summaryText'] ?? raw['text'] ?? raw['content'];
    if (text is String && text.isNotEmpty) return text;
    return null;
  }

  String _kindLabel(AppLocalizations l10n) {
    return switch (widget.kind) {
      SavedContentKind.flashcards => l10n.savedFlashCards,
      SavedContentKind.quiz => l10n.savedQuizes,
      SavedContentKind.summary => l10n.savedSummary,
      SavedContentKind.mindmap => l10n.savedMindMap,
    };
  }
}
