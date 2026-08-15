import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/chat_with_mishka/data/data_sources/saved_library_remote_data_source.dart';
import 'package:mishka_app/features/saved/data/data_sources/saved_remote_data_source.dart';
import 'package:mishka_app/features/saved/data/models/quiz_submit_outcome.dart';
import 'package:mishka_app/features/saved/data/models/saved_detail_model.dart';
import 'package:mishka_app/features/saved/data/models/saved_list_models.dart';
import 'package:mishka_app/features/saved/data/saved_detail_cache.dart';
import 'package:mishka_app/features/saved/data/saved_upload_filename_resolver.dart';
import 'package:mishka_app/features/saved/data/saved_tutor_detail_helpers.dart';
import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';

class SavedRepository {
  SavedRepository({
    SavedRemoteDataSource? remote,
    SavedLibraryRemoteDataSource? savedLibrarySharing,
    SavedUploadFilenameResolver? uploadFilenameResolver,
  })  : _remote = remote ?? SavedRemoteDataSource(ApiService()),
        _sharing =
            savedLibrarySharing ?? SavedLibraryRemoteDataSource(ApiService()),
        _uploadFilenameResolver =
            uploadFilenameResolver ?? SavedUploadFilenameResolver();

  final SavedRemoteDataSource _remote;
  final SavedLibraryRemoteDataSource _sharing;
  final SavedUploadFilenameResolver _uploadFilenameResolver;

  /// Original uploaded PDF name (e.g. `notes.pdf`) for any saved payload.
  Future<String?> resolveUploadFilename(Map<String, dynamic> raw) =>
      _uploadFilenameResolver.resolve(raw);

  SavedMaterialType _materialType(SavedContentKind kind) {
    return switch (kind) {
      SavedContentKind.flashcards => SavedMaterialType.flashcards,
      SavedContentKind.quiz => SavedMaterialType.quiz,
      SavedContentKind.summary => SavedMaterialType.summary,
      SavedContentKind.mindmap => SavedMaterialType.mindmap,
    };
  }

  Future<List<CommunityChannel>> getShareChannels() =>
      _sharing.getShareChannels();

  Future<void> shareSavedLibraryRow({
    required SavedContentKind kind,
    required String savedListRowId,
    required List<String> channelIds,
    String? note,
  }) =>
      _sharing.shareSavedMaterialToChannels(
        type: _materialType(kind),
        savedRowId: savedListRowId,
        channelIds: channelIds,
        note: note,
      );

  /// Tutor entity id (`flashcardSetId`, `quizId`, etc.) for a saved-library row.
  Future<String?> tutorEntityIdForSavedRow(
    SavedContentKind kind,
    String savedListRowId,
  ) async {
    if (savedListRowId.isEmpty) return null;
    try {
      final detail = switch (kind) {
        SavedContentKind.flashcards =>
          await getSavedFlashcardSetDetail(savedListRowId),
        SavedContentKind.quiz => await getSavedQuizDetail(savedListRowId),
        SavedContentKind.summary => await getSavedSummaryDetail(savedListRowId),
        SavedContentKind.mindmap => await getSavedMindMapDetail(savedListRowId),
      };
      return detail.tutorEntityId(kind) ?? savedListRowId;
    } catch (_) {
      return savedListRowId;
    }
  }

  Future<void> deleteSavedLibraryRow(
    SavedContentKind kind,
    String savedListRowId,
  ) =>
      _remote.deleteSavedLibraryRow(kind, savedListRowId);

  Future<List<SavedQuizListItem>> getSavedQuizzes() async {
    final rows = await _remote.getSavedQuizzes();
    return Future.wait(rows.map(_enrichQuizListItem));
  }

  Future<List<SavedFlashcardSetListItem>> getSavedFlashcardSets() async {
    final rows = await _remote.getSavedFlashcardSets();
    return Future.wait(rows.map(_enrichFlashcardListItem));
  }

  Future<List<SavedSummaryListItem>> getSavedSummaries() async {
    final rows = await _remote.getSavedSummaries();
    return Future.wait(rows.map(_enrichSummaryListItem));
  }

  Future<List<SavedMindMapListItem>> getSavedMindMaps() async {
    final rows = await _remote.getSavedMindMaps();
    return Future.wait(rows.map(_enrichMindMapListItem));
  }

  /// `{id}` = each list item’s `id` (saved row).
  Future<SavedLibraryDetail> getSavedQuizDetail(String savedListRowId) =>
      _remote.getSavedQuizDetail(savedListRowId);

  Future<SavedLibraryDetail> getSavedFlashcardSetDetail(
    String savedListRowId,
  ) =>
      _remote.getSavedFlashcardSetDetail(savedListRowId);

  Future<SavedLibraryDetail> getSavedSummaryDetail(String savedListRowId) =>
      _remote.getSavedSummaryDetail(savedListRowId);

  Future<SavedLibraryDetail> getSavedMindMapDetail(String savedListRowId) =>
      _remote.getSavedMindMapDetail(savedListRowId);

  Future<List<Map<String, dynamic>>> getQuizQuestions(String quizId) =>
      _remote.getQuizQuestions(quizId);

  Future<int?> getQuizBestScorePercent(String quizId) =>
      _remote.getQuizBestScorePercent(quizId);

  Future<QuizSubmitOutcome?> submitQuizAttempt({
    required String quizId,
    required List<Map<String, dynamic>> questions,
    required Map<int, int> selectedAnswers,
  }) =>
      _remote.submitQuizAttempt(
        quizId: quizId,
        questions: questions,
        selectedAnswers: selectedAnswers,
      );

  Future<void> renameTutorEntity({
    required SavedContentKind kind,
    required String entityId,
    required String title,
  }) =>
      _remote.renameTutorEntity(
        kind: kind,
        entityId: entityId,
        title: title,
      );

  Future<SavedFlashcardSetListItem> _enrichFlashcardListItem(
    SavedFlashcardSetListItem row,
  ) async {
    final needsCards = row.previewLabels.isEmpty;
    final needsPdf =
        row.sourceFileName == null || row.sourceFileName!.trim().isEmpty;
    if (!needsCards && !needsPdf) return row;
    if (row.savedRowId.isEmpty) return row;

    final detail = await _readCachedOrFetchDetail(
      SavedContentKind.flashcards,
      row.savedRowId,
      _remote.getSavedFlashcardSetDetail,
      cacheIsComplete: _flashcardDetailHasCards,
    );
    if (detail == null) return row;

    return row.copyWith(
      previewLabels:
          needsCards ? extractFlashcardPreviewLabels(detail.raw) : null,
      sourceFileName:
          needsPdf ? await _uploadFilenameResolver.resolve(detail.raw) : null,
    );
  }

  Future<SavedQuizListItem> _enrichQuizListItem(SavedQuizListItem row) async {
    if (row.sourceFileName != null && row.sourceFileName!.trim().isNotEmpty) {
      return row;
    }
    if (row.savedRowId.isEmpty) return row;

    final detail = await _readCachedOrFetchDetail(
      SavedContentKind.quiz,
      row.savedRowId,
      _remote.getSavedQuizDetail,
    );
    if (detail == null) return row;

    final pdf = await _uploadFilenameResolver.resolve(detail.raw);
    if (pdf == null) return row;
    return row.copyWith(sourceFileName: pdf);
  }

  Future<SavedSummaryListItem> _enrichSummaryListItem(
    SavedSummaryListItem row,
  ) async {
    final needsPdf =
        row.sourceFileName == null || row.sourceFileName!.trim().isEmpty;
    final needsSnippet = row.snippet.isEmpty;
    if (!needsPdf && !needsSnippet) return row;
    if (row.savedRowId.isEmpty) return row;

    final detail = await _readCachedOrFetchDetail(
      SavedContentKind.summary,
      row.savedRowId,
      _remote.getSavedSummaryDetail,
    );
    if (detail == null) return row;

    return row.copyWith(
      sourceFileName:
          needsPdf ? await _uploadFilenameResolver.resolve(detail.raw) : null,
      snippet: needsSnippet
          ? snippetFromSummaryText(extractSummaryTextFromRaw(detail.raw))
          : null,
    );
  }

  Future<SavedMindMapListItem> _enrichMindMapListItem(
    SavedMindMapListItem row,
  ) async {
    final needsPdf =
        row.sourceFileName == null || row.sourceFileName!.trim().isEmpty;
    final needsSnippet = row.snippet.isEmpty;
    if (!needsPdf && !needsSnippet) return row;
    if (row.savedRowId.isEmpty) return row;

    final detail = await _readCachedOrFetchDetail(
      SavedContentKind.mindmap,
      row.savedRowId,
      _remote.getSavedMindMapDetail,
    );
    if (detail == null) return row;

    return row.copyWith(
      sourceFileName:
          needsPdf ? await _uploadFilenameResolver.resolve(detail.raw) : null,
      snippet: needsSnippet ? snippetFromMindMapRaw(detail.raw) : null,
    );
  }

  Future<SavedLibraryDetail?> _readCachedOrFetchDetail(
    SavedContentKind kind,
    String savedRowId,
    Future<SavedLibraryDetail> Function(String id) fetch, {
    bool Function(Map<String, dynamic> raw)? cacheIsComplete,
  }) async {
    final cached = await SavedDetailCache.read(kind, savedRowId);
    if (cached != null &&
        cached.raw.isNotEmpty &&
        (cacheIsComplete == null || cacheIsComplete(cached.raw))) {
      return cached;
    }

    try {
      final detail = await fetch(savedRowId);
      await SavedDetailCache.write(kind, savedRowId, detail.raw);
      return detail;
    } catch (_) {
      return null;
    }
  }

  bool _flashcardDetailHasCards(Map<String, dynamic> raw) {
    return extractFlashcardPreviewLabels(raw).isNotEmpty;
  }
}
