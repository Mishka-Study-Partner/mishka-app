import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/chat_with_mishka/data/data_sources/saved_library_remote_data_source.dart';
import 'package:mishka_app/features/saved/data/data_sources/saved_remote_data_source.dart';
import 'package:mishka_app/features/saved/data/models/saved_detail_model.dart';
import 'package:mishka_app/features/saved/data/models/saved_list_models.dart';
import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';

class SavedRepository {
  SavedRepository({
    SavedRemoteDataSource? remote,
    SavedLibraryRemoteDataSource? savedLibrarySharing,
  })  : _remote = remote ?? SavedRemoteDataSource(ApiService()),
        _sharing =
            savedLibrarySharing ?? SavedLibraryRemoteDataSource(ApiService());

  final SavedRemoteDataSource _remote;
  final SavedLibraryRemoteDataSource _sharing;

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

  Future<void> deleteSavedLibraryRow(
    SavedContentKind kind,
    String savedListRowId,
  ) =>
      _remote.deleteSavedLibraryRow(kind, savedListRowId);

  Future<List<SavedQuizListItem>> getSavedQuizzes() => _remote.getSavedQuizzes();

  Future<List<SavedFlashcardSetListItem>> getSavedFlashcardSets() =>
      _remote.getSavedFlashcardSets();

  Future<List<SavedSummaryListItem>> getSavedSummaries() =>
      _remote.getSavedSummaries();

  Future<List<SavedMindMapListItem>> getSavedMindMaps() =>
      _remote.getSavedMindMaps();

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
}
