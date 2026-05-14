import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/saved/data/models/saved_detail_model.dart';
import 'package:mishka_app/features/saved/data/models/saved_list_models.dart';
import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';

class SavedRemoteDataSource {
  SavedRemoteDataSource(this._api);

  final ApiService _api;

  Future<List<SavedQuizListItem>> getSavedQuizzes() async {
    final env = await _api.get<List<SavedQuizListItem>>(
      ApiEndpoints.savedQuizzes,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => SavedQuizListItem.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList();
      },
    );
    return env.data ?? const [];
  }

  Future<List<SavedFlashcardSetListItem>> getSavedFlashcardSets() async {
    final env = await _api.get<List<SavedFlashcardSetListItem>>(
      ApiEndpoints.savedFlashcardSets,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => SavedFlashcardSetListItem.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList();
      },
    );
    return env.data ?? const [];
  }

  Future<List<SavedSummaryListItem>> getSavedSummaries() async {
    final env = await _api.get<List<SavedSummaryListItem>>(
      ApiEndpoints.savedSummaries,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => SavedSummaryListItem.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList();
      },
    );
    return env.data ?? const [];
  }

  Future<List<SavedMindMapListItem>> getSavedMindMaps() async {
    final env = await _api.get<List<SavedMindMapListItem>>(
      ApiEndpoints.savedMindMaps,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => SavedMindMapListItem.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList();
      },
    );
    return env.data ?? const [];
  }

  Map<String, dynamic> _mapDataFromJson(Object? raw) {
    if (raw == null) {
      return {};
    }
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return {};
  }

  Future<SavedLibraryDetail> getSavedQuizDetail(String savedListRowId) =>
      _fetchSavedLibraryDetail(ApiEndpoints.savedQuizDetailById(savedListRowId));

  Future<SavedLibraryDetail> getSavedFlashcardSetDetail(
    String savedListRowId,
  ) =>
      _fetchSavedLibraryDetail(
        ApiEndpoints.savedFlashcardSetDetailById(savedListRowId),
      );

  Future<SavedLibraryDetail> getSavedSummaryDetail(String savedListRowId) =>
      _fetchSavedLibraryDetail(ApiEndpoints.savedSummaryDetailById(
        savedListRowId,
      ));

  Future<SavedLibraryDetail> getSavedMindMapDetail(String savedListRowId) =>
      _fetchSavedLibraryDetail(ApiEndpoints.savedMindMapDetailById(
        savedListRowId,
      ));

  Future<SavedLibraryDetail> _fetchSavedLibraryDetail(String path) async {
    final env = await _api.get<Map<String, dynamic>>(
      path,
      dataFromJson: _mapDataFromJson,
    );
    final data = env.data;
    if (data == null || data.isEmpty) {
      throw ApiException(
        message: 'No data for this saved item',
        error: 'EMPTY_DATA',
      );
    }
    return SavedLibraryDetail(data);
  }

  /// `DELETE /saved-*/{id}` — [savedListRowId] is the list row `id`.
  Future<void> deleteSavedLibraryRow(
    SavedContentKind kind,
    String savedListRowId,
  ) async {
    final path = switch (kind) {
      SavedContentKind.flashcards =>
        ApiEndpoints.savedFlashcardSetDetailById(savedListRowId),
      SavedContentKind.quiz =>
        ApiEndpoints.savedQuizDetailById(savedListRowId),
      SavedContentKind.summary =>
        ApiEndpoints.savedSummaryDetailById(savedListRowId),
      SavedContentKind.mindmap =>
        ApiEndpoints.savedMindMapDetailById(savedListRowId),
    };
    await _api.delete<void>(path);
  }
}
