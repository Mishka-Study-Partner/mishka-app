import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/chat_with_mishka/data/tool_data_normalizer.dart';
import 'package:flutter/foundation.dart';

enum SavedMaterialType { quiz, flashcards, summary, mindmap }

/// Required by Mishka backend Prisma models when persisting AI-generated tutor rows.
const String generatedMaterialSourceType = 'ai';

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
    final normalized = normalizeToolData(toolData);
    _validateForSave(type: type, normalized: normalized);
    final existingId = _extractEntityId(type, normalized);
    final entityId =
        existingId ?? await _createEntity(type: type, toolData: normalized);
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
    final normalized = normalizeToolData(toolData);
    _validateForSave(type: type, normalized: normalized);
    final existingId = _extractEntityId(type, normalized);
    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }
    return _createEntity(type: type, toolData: normalized);
  }

  void _validateForSave({
    required SavedMaterialType type,
    required Map<String, dynamic> normalized,
  }) {
    switch (type) {
      case SavedMaterialType.quiz:
        final questions = (normalized['questions'] as List?) ?? const [];
        if (questions.isEmpty) {
          throw const FormatException('Quiz has no questions to save');
        }
      case SavedMaterialType.flashcards:
        final cards = (normalized['cards'] as List?) ?? const [];
        if (cards.isEmpty) {
          throw const FormatException('Flashcard set has no cards to save');
        }
      case SavedMaterialType.summary:
        final text = (normalized['summaryText'] ??
                normalized['summary'] ??
                normalized['text'] ??
                '')
            .toString()
            .trim();
        if (text.isEmpty) {
          throw const FormatException('Summary is empty');
        }
      case SavedMaterialType.mindmap:
        if (!mindMapHasSaveableContent(normalized)) {
          throw const FormatException('Mind map has no nodes to save');
        }
    }
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
    final normalized = normalizeToolData(toolData);
    switch (type) {
      case SavedMaterialType.quiz:
        final questions = (normalized['questions'] as List?) ?? const [];
        final env = await _api.post<Map<String, dynamic>>(
          ApiEndpoints.quizzes,
          data: {
            'title': (normalized['title'] ?? 'Generated Quiz').toString(),
            'sourceType': generatedMaterialSourceType,
            if (questions.isNotEmpty) 'totalQuestions': questions.length,
            ...chatSessionFieldForCreate(normalized),
            ...sourceReferenceFieldsForCreate(normalized),
          },
          dataFromJson: _mapFromRaw,
        );
        final quizId = _extractFirstId(env.data);
        await _createQuizQuestions(
          quizId: quizId,
          questions: questions,
        );
        return quizId;
      case SavedMaterialType.flashcards:
        final setEnv = await _api.post<Map<String, dynamic>>(
          ApiEndpoints.flashcardSets,
          data: {
            'title': (normalized['title'] ?? 'Generated Flashcards').toString(),
            'sourceType': generatedMaterialSourceType,
            ...chatSessionFieldForCreate(normalized),
            ...sourceReferenceFieldsForCreate(normalized),
          },
          dataFromJson: _mapFromRaw,
        );
        final setId = _extractFirstId(setEnv.data);
        final cards = (normalized['cards'] as List?) ?? const [];
        for (final card in cards.whereType<Map>()) {
          final row = Map<String, dynamic>.from(card);
          final front =
              (row['front'] ?? row['term'] ?? row['question'] ?? '').toString();
          final back = (row['back'] ??
                  row['answer'] ??
                  row['definition'] ??
                  '')
              .toString();
          await _api.post<void>(
            ApiEndpoints.flashcardSetFlashcards(setId),
            data: {
              'question': front,
              'answer': back,
            },
          );
        }
        return setId;
      case SavedMaterialType.summary:
        final summaryText = (normalized['summaryText'] ??
                normalized['summary'] ??
                normalized['text'] ??
                '')
            .toString()
            .trim();
        final env = await _api.post<Map<String, dynamic>>(
          ApiEndpoints.summaries,
          data: {
            'summaryText': summaryText,
            'sourceType': generatedMaterialSourceType,
            ...chatSessionFieldForCreate(normalized),
            ...sourceReferenceFieldsForCreate(normalized),
          },
          dataFromJson: _mapFromRaw,
        );
        return _extractFirstId(env.data);
      case SavedMaterialType.mindmap:
        final content = mindMapContentForApi(normalized);
        final payload = <String, dynamic>{
          'sourceType': generatedMaterialSourceType,
          'content': content,
          ...chatSessionFieldForCreate(normalized),
          ...sourceReferenceFieldsForCreate(normalized),
        };
        final topTitle =
            (normalized['title'] ?? content['title'] ?? 'Generated Mind Map')
                .toString()
                .trim();
        if (topTitle.isNotEmpty) {
          payload['title'] = topTitle;
        }
        if (kDebugMode) {
          debugPrint('🧠 SAVE mind-map payload: $payload');
        }
        final env = await _api.post<Map<String, dynamic>>(
          ApiEndpoints.mindMaps,
          data: payload,
          dataFromJson: _mapFromRaw,
        );
        return _extractFirstId(env.data);
    }
  }

  Future<void> _createQuizQuestions({
    required String quizId,
    required List<dynamic> questions,
  }) async {
    var order = 0;
    for (final item in questions) {
      if (item is! Map) continue;
      final row = Map<String, dynamic>.from(item);
      final options = List<String>.from(
        (row['options'] as List?)?.map((e) => e.toString()) ?? const [],
      );
      await _api.post<void>(
        ApiEndpoints.quizQuestions,
        data: {
          'quizId': quizId,
          'questionText':
              (row['questionText'] ?? row['question'] ?? '').toString(),
          'options': options,
          'correctOptionIndex': row['correctOptionIndex'] ?? 0,
          'order': order,
        },
      );
      order++;
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

  Future<String?> lookupSavedRowId({
    required SavedMaterialType type,
    required String entityId,
  }) async {
    if (entityId.isEmpty) return null;

    final env = await _api.get<List<Map<String, dynamic>>>(
      switch (type) {
        SavedMaterialType.quiz => ApiEndpoints.savedQuizzes,
        SavedMaterialType.flashcards => ApiEndpoints.savedFlashcardSets,
        SavedMaterialType.summary => ApiEndpoints.savedSummaries,
        SavedMaterialType.mindmap => ApiEndpoints.savedMindMaps,
      },
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      },
    );

    final entityKey = switch (type) {
      SavedMaterialType.quiz => 'quizId',
      SavedMaterialType.flashcards => 'flashcardSetId',
      SavedMaterialType.summary => 'summaryId',
      SavedMaterialType.mindmap => 'mindMapId',
    };

    for (final row in env.data ?? const <Map<String, dynamic>>[]) {
      final savedRowId = row['id']?.toString();
      if (savedRowId == null || savedRowId.isEmpty) continue;

      final direct = row[entityKey]?.toString();
      if (direct == entityId) return savedRowId;

      final nestedKey = switch (type) {
        SavedMaterialType.quiz => 'quiz',
        SavedMaterialType.flashcards => 'flashcardSet',
        SavedMaterialType.summary => 'summary',
        SavedMaterialType.mindmap => 'mindMap',
      };
      final nested = row[nestedKey];
      if (nested is Map) {
        final nestedId = nested['id']?.toString();
        if (nestedId == entityId) return savedRowId;
      }
    }
    return null;
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
    for (final nestedKey in const [
      'quiz',
      'flashcardSet',
      'flashcard_set',
      'summary',
      'mindMap',
      'mind_map',
    ]) {
      final nested = map[nestedKey];
      if (nested is Map) {
        final nestedId = nested['id']?.toString();
        if (nestedId != null && nestedId.isNotEmpty) return nestedId;
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
