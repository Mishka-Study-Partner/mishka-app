import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/ctegory/presentation/widgets/search_bar.dart';
import 'package:mishka_app/features/saved/data/models/saved_list_models.dart';
import 'package:mishka_app/features/saved/data/repositories/saved_repository.dart';
import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';
import 'package:mishka_app/features/saved/presentation/saved_rename_actions.dart';
import 'package:mishka_app/features/saved/presentation/saved_share_delete_actions.dart';
import 'package:mishka_app/features/saved/presentation/screens/saved_item_detail_screen.dart';
import 'package:mishka_app/features/saved/presentation/widgets/saved_library_mishka_card.dart';
import 'package:mishka_app/generated/assets.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// One saved category: search + list for [kind] only (after opening from the hub).
class SavedCategoryListScreen extends StatefulWidget {
  const SavedCategoryListScreen({super.key, required this.kind});

  final SavedContentKind kind;

  @override
  State<SavedCategoryListScreen> createState() => _SavedCategoryListScreenState();
}

class _SavedCategoryListScreenState extends State<SavedCategoryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SavedRepository _repository = SavedRepository();

  bool _loading = true;
  List<SavedFlashcardSetListItem> _flashApi = const [];
  List<SavedQuizListItem> _quizApi = const [];
  List<SavedSummaryListItem> _summaryApi = const [];
  List<SavedMindMapListItem> _mindApi = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      switch (widget.kind) {
        case SavedContentKind.flashcards:
          final rows = await _repository.getSavedFlashcardSets();
          if (mounted) setState(() => _flashApi = rows);
          break;
        case SavedContentKind.quiz:
          final rows = await _repository.getSavedQuizzes();
          if (mounted) setState(() => _quizApi = rows);
          break;
        case SavedContentKind.summary:
          final rows = await _repository.getSavedSummaries();
          if (mounted) setState(() => _summaryApi = rows);
          break;
        case SavedContentKind.mindmap:
          final rows = await _repository.getSavedMindMaps();
          if (mounted) setState(() => _mindApi = rows);
          break;
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorPrefix}: ${_formatApiError(e)}')),
      );
      setState(() {
        _flashApi = const [];
        _quizApi = const [];
        _summaryApi = const [];
        _mindApi = const [];
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _formatApiError(Object error) {
    if (error is ApiException) {
      final buffer = StringBuffer();
      if (error.statusCode != null) {
        buffer.write('[${error.statusCode}] ');
      }
      if (error.error != null && error.error!.isNotEmpty) {
        buffer.write('[${error.error}] ');
      }
      buffer.write(error.message);
      if (error.details != null) {
        buffer.write('\n${error.details}');
      }
      return buffer.toString();
    }
    return error.toString();
  }

  String _screenTitle(AppLocalizations l10n) {
    return switch (widget.kind) {
      SavedContentKind.flashcards => l10n.savedFlashCards,
      SavedContentKind.quiz => l10n.savedQuizes,
      SavedContentKind.summary => l10n.savedSummary,
      SavedContentKind.mindmap => l10n.mindMap,
    };
  }

  List<_SavedRow> _mappedEntries() {
    return switch (widget.kind) {
      SavedContentKind.flashcards => _flashApi.asMap().entries.map((e) {
          final i = e.key;
          final row = e.value;
          return _SavedRow(
            savedListItemId: row.savedRowId,
            tutorEntityId: row.flashcardSetId,
            title: row.title,
            imageFallbackAsset: _assetForIndex(i),
            imageOnLeft: i % 2 == 0,
          );
        }).toList(),
      SavedContentKind.quiz => _quizApi.asMap().entries.map((e) {
          final i = e.key;
          final row = e.value;
          return _SavedRow(
            savedListItemId: row.savedRowId,
            tutorEntityId: row.quizId,
            title: row.title,
            imageFallbackAsset: _assetForIndex(i),
            imageOnLeft: i % 2 == 0,
          );
        }).toList(),
      SavedContentKind.summary => _summaryApi.asMap().entries.map((e) {
          final i = e.key;
          final row = e.value;
          return _SavedRow(
            savedListItemId: row.savedRowId,
            tutorEntityId: row.summaryId,
            title: row.title,
            imageFallbackAsset: _assetForIndex(i),
            imageOnLeft: i % 2 == 0,
          );
        }).toList(),
      SavedContentKind.mindmap => _mindApi.asMap().entries.map((e) {
          final i = e.key;
          final row = e.value;
          return _SavedRow(
            savedListItemId: row.savedRowId,
            tutorEntityId: row.mindMapId,
            title: row.title,
            imageFallbackAsset: _assetForIndex(i),
            imageOnLeft: i % 2 == 0,
          );
        }).toList(),
    };
  }

  String _assetForIndex(int index) {
    switch (index % 3) {
      case 0:
        return Assets.imagesSavedCard1;
      case 1:
        return Assets.imagesSavedCard2;
      default:
        return Assets.imagesSavedCard3;
    }
  }

  List<_SavedRow> _filtered(List<_SavedRow> all, String q) {
    final t = q.trim().toLowerCase();
    if (t.isEmpty) return all;
    return all.where((e) => e.title.toLowerCase().contains(t)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = _filtered(_mappedEntries(), _searchController.text);

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: _screenTitle(l10n),
        showBack: true,
        showBottomBar: false,
        topTitle: l10n.saved,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            MishkaSearchBar(
              hintText: l10n.savedSearchHint,
              controller: _searchController,
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: _buildList(l10n, entries),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(AppLocalizations l10n, List<_SavedRow> items) {
    final query = _searchController.text.trim();
    if (items.isEmpty) {
      final isSearch = query.isNotEmpty;
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                isSearch ? l10n.savedNoSearchResults : l10n.savedLibraryEmpty,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: AppSizes.fontSizeMedium,
                  color: AppColors.greyText,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: 20.h),
      itemBuilder: (context, index) {
        final item = items[index];
        return SavedLibraryMishkaCard(
          title: item.title,
          primaryImageAsset:
              SavedLibraryMishkaCard.prototypePrimaryAsset(widget.kind),
          fallbackImageAsset: item.imageFallbackAsset,
          imageLeft: item.imageOnLeft,
          actionLabel: l10n.view,
          onShare: () {
            shareSavedLibraryItem(
              context: context,
              repository: _repository,
              kind: widget.kind,
              savedListItemId: item.savedListItemId,
            );
          },
          onDelete: () async {
            final removed = await confirmAndDeleteSavedLibraryItem(
              context: context,
              repository: _repository,
              kind: widget.kind,
              savedListItemId: item.savedListItemId,
            );
            if (!context.mounted) return;
            if (removed) {
              _load();
            }
          },
          onRename: () async {
            final renamed = await showRenameSavedItemDialog(
              context: context,
              repository: _repository,
              kind: widget.kind,
              entityId: item.tutorEntityId,
              currentTitle: item.title,
            );
            if (renamed) _load();
          },
          onView: () async {
            if (item.savedListItemId.isEmpty) {
              final loc = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${loc.errorPrefix}: ${loc.savedDetailMissingListId}',
                  ),
                ),
              );
              return;
            }
            final refresh = await Navigator.of(context).push<bool>(
              MaterialPageRoute<bool>(
                builder: (_) => SavedItemDetailScreen(
                  kind: widget.kind,
                  savedListItemId: item.savedListItemId,
                  title: item.title,
                ),
              ),
            );
            if (!context.mounted) return;
            if (refresh == true) {
              _load();
            }
          },
        );
      },
    );
  }
}

class _SavedRow {
  const _SavedRow({
    required this.savedListItemId,
    required this.tutorEntityId,
    required this.title,
    required this.imageFallbackAsset,
    required this.imageOnLeft,
  });

  final String savedListItemId;
  final String tutorEntityId;
  final String title;
  final String imageFallbackAsset;
  final bool imageOnLeft;
}
