import 'package:mishka_app/features/chat_with_mishka/data/tool_data_normalizer.dart';

/// Parsed `/generate-tools` response (Mishka backend or AI worker).
class GenerateToolsResult {
  const GenerateToolsResult({
    required this.toolData,
    this.toolPreviewMessageId,
    this.materialId,
  });

  final Map<String, dynamic> toolData;
  final String? toolPreviewMessageId;
  final String? materialId;
}

GenerateToolsResult parseGenerateToolsResponse(
  Map<String, dynamic> raw, {
  String? chatSessionId,
}) {
  final map = Map<String, dynamic>.from(raw);

  final previewId = _firstNonEmpty(map, const [
    'tool_preview_message_id',
    'toolPreviewMessageId',
  ]);
  final materialId = _firstNonEmpty(map, const [
    'materialId',
    'material_id',
  ]);

  for (final key in const [
    'tool_preview_message_id',
    'toolPreviewMessageId',
    'materialId',
    'material_id',
  ]) {
    map.remove(key);
  }

  final toolData = normalizeToolData(map);
  if (chatSessionId != null && chatSessionId.isNotEmpty) {
    toolData['chatSessionId'] = chatSessionId;
  }
  _applyMaterialId(toolData, materialId);

  return GenerateToolsResult(
    toolData: toolData,
    toolPreviewMessageId: previewId,
    materialId: materialId,
  );
}

void _applyMaterialId(Map<String, dynamic> toolData, String? materialId) {
  if (materialId == null || materialId.isEmpty) return;

  final toolType = (toolData['tool_type'] ?? '').toString().toLowerCase();
  switch (toolType) {
    case 'quizzes':
    case 'quiz':
      toolData['quizId'] = materialId;
    case 'flashcards':
      toolData['flashcardSetId'] = materialId;
    case 'mind_maps':
    case 'mindmap':
      toolData['mindMapId'] = materialId;
    case 'summaries':
    case 'summary':
      toolData['summaryId'] = materialId;
  }
}

String? _firstNonEmpty(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key]?.toString();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}
