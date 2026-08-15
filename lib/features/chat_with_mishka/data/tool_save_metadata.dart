import 'package:mishka_app/features/chat_with_mishka/data/data_sources/saved_library_remote_data_source.dart';

/// Keys embedded in persisted `tool_preview` message JSON after save.
const savedLibraryIdKey = 'savedLibraryId';

String? readSavedLibraryId(Map<String, dynamic> toolData) {
  for (final key in [savedLibraryIdKey, 'savedRowId', 'saved_id']) {
    final value = toolData[key]?.toString();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

String? readEntityIdFromToolData(
  Map<String, dynamic> toolData,
  SavedMaterialType type,
) {
  final candidates = switch (type) {
    SavedMaterialType.quiz => const ['quizId', 'id'],
    SavedMaterialType.flashcards => const ['flashcardSetId', 'id'],
    SavedMaterialType.summary => const ['summaryId', 'id'],
    SavedMaterialType.mindmap => const ['mindMapId', 'id'],
  };
  for (final key in candidates) {
    final value = toolData[key]?.toString();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

Map<String, dynamic> applySaveMetadata({
  required Map<String, dynamic> toolData,
  required SavedMaterialRef ref,
  required SavedMaterialType type,
}) {
  final data = Map<String, dynamic>.from(toolData);
  data[savedLibraryIdKey] = ref.savedId;
  final entityKey = switch (type) {
    SavedMaterialType.quiz => 'quizId',
    SavedMaterialType.flashcards => 'flashcardSetId',
    SavedMaterialType.summary => 'summaryId',
    SavedMaterialType.mindmap => 'mindMapId',
  };
  data[entityKey] = ref.entityId;
  return data;
}
