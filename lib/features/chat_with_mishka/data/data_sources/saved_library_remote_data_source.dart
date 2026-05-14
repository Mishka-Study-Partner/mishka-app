import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_service.dart';

enum SavedMaterialType { quiz, flashcards, summary, mindmap }

class CommunityChannel {
  const CommunityChannel({required this.id, required this.name});

  final String id;
  final String name;
}

class SavedMaterialRef {
  const SavedMaterialRef({required this.entityId, required this.savedId});

  final String entityId;
  final String savedId;
}

class SavedLibraryRemoteDataSource {
  SavedLibraryRemoteDataSource(this._api);

  final ApiService _api;

  Future<SavedMaterialRef> saveGeneratedMaterial({
    required SavedMaterialType type,
    required Map<String, dynamic> toolData,
  }) async {
    final existingId = _extractEntityId(type, toolData);
    final entityId =
        existingId ?? await _createEntity(type: type, toolData: toolData);
    final savedId = await _saveEntity(type: type, entityId: entityId);
    return SavedMaterialRef(entityId: entityId, savedId: savedId);
  }

  Future<List<CommunityChannel>> getShareChannels() async {
    final userCommunitiesEnv = await _api.get<List<CommunityChannel>>(
      ApiEndpoints.userCommunities,
      dataFromJson: _channelsFromRaw,
    );
    final userChannels = userCommunitiesEnv.data ?? const <CommunityChannel>[];
    if (userChannels.isNotEmpty) {
      return userChannels;
    }
    final communitiesEnv = await _api.get<List<CommunityChannel>>(
      ApiEndpoints.communities,
      dataFromJson: _channelsFromRaw,
    );
    return communitiesEnv.data ?? const <CommunityChannel>[];
  }

  Future<void> shareSavedMaterialToChannels({
    required SavedMaterialType type,
    required String savedRowId,
    required List<String> channelIds,
    String? note,
  }) async {
    final path = switch (type) {
      SavedMaterialType.quiz => ApiEndpoints.savedQuizShareById(savedRowId),
      SavedMaterialType.flashcards => ApiEndpoints.savedFlashcardSetShareById(
        savedRowId,
      ),
      SavedMaterialType.summary => ApiEndpoints.savedSummaryShareById(
        savedRowId,
      ),
      SavedMaterialType.mindmap => ApiEndpoints.savedMindMapShareById(
        savedRowId,
      ),
    };
    await _api.post<void>(
      path,
      data: {
        'channelIds': channelIds,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
  }

  Future<String> ensureGeneratedMaterialEntity({
    required SavedMaterialType type,
    required Map<String, dynamic> toolData,
  }) async {
    final existingId = _extractEntityId(type, toolData);
    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }
    return _createEntity(type: type, toolData: toolData);
  }

  Future<void> shareGeneratedMaterialToChannels({
    required SavedMaterialType type,
    required String entityId,
    required List<String> channelIds,
    String? note,
  }) async {
    final path = switch (type) {
      SavedMaterialType.quiz => ApiEndpoints.quizShareById(entityId),
      SavedMaterialType.flashcards => ApiEndpoints.flashcardSetShareById(
        entityId,
      ),
      SavedMaterialType.summary => ApiEndpoints.summaryShareById(entityId),
      SavedMaterialType.mindmap => ApiEndpoints.mindMapShareById(entityId),
    };
    await _api.post<void>(
      path,
      data: {
        'channelIds': channelIds,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
  }

  Future<String> _createEntity({
    required SavedMaterialType type,
    required Map<String, dynamic> toolData,
  }) async {
    switch (type) {
      case SavedMaterialType.quiz:
        final env = await _api.post<Map<String, dynamic>>(
          ApiEndpoints.quizzes,
          data: {
            'title': (toolData['title'] ?? 'Generated Quiz').toString(),
            if (toolData['questions'] is List)
              'questions': toolData['questions'],
            'raw': toolData,
          },
          dataFromJson: _mapFromRaw,
        );
        return _extractFirstId(env.data);
      case SavedMaterialType.flashcards:
        final setEnv = await _api.post<Map<String, dynamic>>(
          ApiEndpoints.flashcardSets,
          data: {
            'title': (toolData['title'] ?? 'Generated Flashcards').toString(),
            'raw': toolData,
          },
          dataFromJson: _mapFromRaw,
        );
        final setId = _extractFirstId(setEnv.data);
        final cards = (toolData['cards'] as List?) ?? const [];
        for (final card in cards.whereType<Map>()) {
          await _api.post<void>(
            ApiEndpoints.flashcards,
            data: {
              'flashcardSetId': setId,
              'front': (card['front'] ?? '').toString(),
              'back': (card['back'] ?? '').toString(),
              if (card['title'] != null) 'title': card['title'].toString(),
              if (card['image'] != null) 'image': card['image'].toString(),
            },
          );
        }
        return setId;
      case SavedMaterialType.summary:
        final env = await _api.post<Map<String, dynamic>>(
          ApiEndpoints.summaries,
          data: {
            'title': (toolData['title'] ?? 'Generated Summary').toString(),
            'content': (toolData['summary'] ?? toolData['text'] ?? '')
                .toString(),
            'raw': toolData,
          },
          dataFromJson: _mapFromRaw,
        );
        return _extractFirstId(env.data);
      case SavedMaterialType.mindmap:
        final env = await _api.post<Map<String, dynamic>>(
          ApiEndpoints.mindMaps,
          data: {
            'title': (toolData['title'] ?? 'Generated Mind Map').toString(),
            if (toolData['root'] != null) 'root': toolData['root'],
            if (toolData['nodes'] != null) 'nodes': toolData['nodes'],
            'raw': toolData,
          },
          dataFromJson: _mapFromRaw,
        );
        return _extractFirstId(env.data);
    }
  }

  Future<String> _saveEntity({
    required SavedMaterialType type,
    required String entityId,
  }) async {
    switch (type) {
      case SavedMaterialType.quiz:
        final env = await _api.post<Map<String, dynamic>>(
          ApiEndpoints.savedQuizzes,
          data: {'quizId': entityId},
          dataFromJson: _mapFromRaw,
        );
        return _extractFirstId(env.data);
      case SavedMaterialType.flashcards:
        final env = await _api.post<Map<String, dynamic>>(
          ApiEndpoints.savedFlashcardSets,
          data: {'flashcardSetId': entityId},
          dataFromJson: _mapFromRaw,
        );
        return _extractFirstId(env.data);
      case SavedMaterialType.summary:
        final env = await _api.post<Map<String, dynamic>>(
          ApiEndpoints.savedSummaries,
          data: {'summaryId': entityId},
          dataFromJson: _mapFromRaw,
        );
        return _extractFirstId(env.data);
      case SavedMaterialType.mindmap:
        final env = await _api.post<Map<String, dynamic>>(
          ApiEndpoints.savedMindMaps,
          data: {'mindMapId': entityId},
          dataFromJson: _mapFromRaw,
        );
        return _extractFirstId(env.data);
    }
  }

  String? _extractEntityId(
    SavedMaterialType type,
    Map<String, dynamic> toolData,
  ) {
    final candidates = switch (type) {
      SavedMaterialType.quiz => const ['quizId', 'id'],
      SavedMaterialType.flashcards => const ['flashcardSetId', 'id'],
      SavedMaterialType.summary => const ['summaryId', 'id'],
      SavedMaterialType.mindmap => const ['mindMapId', 'id'],
    };
    for (final key in candidates) {
      final value = toolData[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  String _extractFirstId(Map<String, dynamic>? map) {
    if (map == null) {
      throw const FormatException('Invalid create response');
    }
    for (final key in const [
      'id',
      'quizId',
      'flashcardSetId',
      'summaryId',
      'mindMapId',
    ]) {
      final value = map[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    throw const FormatException('Created entity id is missing');
  }

  Map<String, dynamic> _mapFromRaw(Object? raw) {
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is List && raw.isNotEmpty && raw.first is Map) {
      return Map<String, dynamic>.from(raw.first as Map);
    }
    throw const FormatException('Invalid response data');
  }

  List<CommunityChannel> _channelsFromRaw(Object? raw) {
    final list = (raw as List?) ?? const [];
    return list.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      final nestedCommunity = map['community'];
      final source = nestedCommunity is Map
          ? Map<String, dynamic>.from(nestedCommunity)
          : map;
      final id = (source['id'] ?? map['communityId'] ?? '').toString();
      final name =
          (source['name'] ??
                  source['title'] ??
                  map['communityName'] ??
                  map['name'] ??
                  map['title'] ??
                  '')
              .toString();
      if (id.isEmpty) {
        throw const FormatException('Invalid community channel response');
      }
      return CommunityChannel(id: id, name: name.isEmpty ? 'Community' : name);
    }).toList();
  }
}
