import 'package:mishka_app/features/chat_with_mishka/data/tool_data_normalizer.dart';

/// Resolves the original uploaded file name (e.g. `chapter-3.pdf`) from a saved payload.
/// Only uses [uploadOriginalFilename] on the row, nested entity, or linked chat session —
/// not generated titles, source references, or generic type labels.
String? resolveUploadedPdfFileName(Map<String, dynamic> raw) {
  String? pickUploadName(Map<String, dynamic> map) {
    final direct = map['uploadOriginalFilename']?.toString().trim();
    if (direct != null && direct.isNotEmpty) return direct;

    final session = map['chatSession'];
    if (session is Map) {
      final fromSession =
          session['uploadOriginalFilename']?.toString().trim();
      if (fromSession != null && fromSession.isNotEmpty) return fromSession;
    }

    final reference = map['sourceReference']?.toString().trim();
    if (reference != null &&
        reference.isNotEmpty &&
        looksLikeUploadedFilename(reference)) {
      return reference;
    }
    return null;
  }

  final direct = pickUploadName(raw);
  if (direct != null) return direct;

  for (final key in const [
    'quiz',
    'flashcardSet',
    'flashcard_set',
    'set',
    'summary',
    'mindMap',
    'mind_map',
  ]) {
    final nested = raw[key];
    if (nested is Map) {
      final fromNested = pickUploadName(Map<String, dynamic>.from(nested));
      if (fromNested != null) return fromNested;
    }
  }
  return null;
}

/// First three flashcard fronts from a saved list or detail payload.
List<String> extractFlashcardPreviewLabels(Map<String, dynamic> raw) {
  final nested = raw['flashcardSet'] ?? raw['flashcard_set'] ?? raw['set'];
  final sources = <Object?>[
    if (nested is Map) ...[
      nested['flashcards'],
      nested['cards'],
    ],
    raw['flashcards'],
    raw['cards'],
  ];
  for (final source in sources) {
    final labels = previewLabelsFromFlashcardCards(source);
    if (labels.isNotEmpty) return labels;
  }
  return const [];
}

List<String> previewLabelsFromFlashcardCards(Object? raw) {
  if (raw is! List) return const [];
  final labels = <String>[];
  for (final item in raw.take(3)) {
    if (item is Map) {
      final label = (item['front'] ??
              item['question'] ??
              item['term'] ??
              item['title'] ??
              '')
          .toString()
          .trim();
      if (label.isNotEmpty) labels.add(label);
    }
  }
  return labels;
}

String? readSavedSourceFileName(
  Map<String, dynamic> raw, {
  required String nestedKey,
  List<String> nestedAliases = const [],
}) {
  final resolved = resolveUploadedPdfFileName(raw);
  if (resolved != null) return resolved;

  final keys = [nestedKey, ...nestedAliases];
  for (final alias in keys) {
    final nested = raw[alias];
    if (nested is! Map) continue;
    final fromNested = resolveUploadedPdfFileName(
      Map<String, dynamic>.from(nested),
    );
    if (fromNested != null) return fromNested;
  }
  return null;
}

DateTime? readSavedCreatedAt(
  Map<String, dynamic> raw, {
  required String nestedKey,
  List<String> nestedAliases = const [],
}) {
  final direct = raw['createdAt'] ?? raw['savedAt'];
  if (direct != null) return DateTime.tryParse(direct.toString());

  for (final alias in [nestedKey, ...nestedAliases]) {
    final nested = raw[alias];
    if (nested is Map) {
      final value = nested['createdAt'] ?? nested['savedAt'];
      if (value != null) return DateTime.tryParse(value.toString());
    }
  }
  return null;
}

String? extractSummaryTextFromRaw(Map<String, dynamic> raw) {
  final nested = raw['summary'];
  if (nested is Map) {
    final content = Map<String, dynamic>.from(nested);
    final text = content['summaryText'] ??
        content['text'] ??
        content['content'] ??
        content['summary'];
    if (text is String && text.trim().isNotEmpty) return text.trim();
  }
  if (nested is String && nested.trim().isNotEmpty) return nested.trim();
  final text = raw['summaryText'] ?? raw['text'] ?? raw['content'];
  if (text is String && text.trim().isNotEmpty) return text.trim();
  return null;
}

String snippetFromSummaryText(String? text, {int maxChars = 160}) {
  if (text == null || text.trim().isEmpty) return '';
  final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.length <= maxChars) return normalized;
  return '${normalized.substring(0, maxChars).trim()}...';
}

String snippetFromMindMapRaw(Map<String, dynamic> raw) {
  final toolData = buildMindMapToolDataFromSavedDetail(raw);
  if (toolData == null) return '';

  final root = (toolData['root'] ?? toolData['title'] ?? 'Topic').toString();
  final nodes = toolData['nodes'] as List? ?? const [];
  final branches = <String>[root];
  for (final node in nodes.take(3)) {
    if (node is Map) {
      final label = (node['title'] ?? node['label'] ?? node['name'] ?? '')
          .toString()
          .trim();
      if (label.isNotEmpty) branches.add(label);
    } else if (node != null && node.toString().trim().isNotEmpty) {
      branches.add(node.toString().trim());
    }
  }
  return snippetFromSummaryText(branches.join(' · '), maxChars: 140);
}

Map<String, dynamic>? buildSummaryToolDataFromSavedDetail(
  Map<String, dynamic> raw, {
  String fallbackTitle = 'Summary',
}) {
  final text = extractSummaryTextFromRaw(raw);
  if (text == null) return null;

  final nested = raw['summary'];
  final content = nested is Map ? Map<String, dynamic>.from(nested) : raw;
  final summaryId = (raw['summaryId'] ??
          raw['summary_id'] ??
          content['id'] ??
          '')
      .toString();

  return buildSummaryToolData(
    summary: text,
    title: (content['title'] ?? content['name'] ?? fallbackTitle).toString(),
  )..addAll({
      if (summaryId.isNotEmpty) 'summaryId': summaryId,
    });
}

Map<String, dynamic>? buildMindMapToolDataFromSavedDetail(
  Map<String, dynamic> raw, {
  String fallbackTitle = 'Mind Map',
}) {
  final nested = raw['mindMap'] ?? raw['mind_map'];
  final content = nested is Map ? Map<String, dynamic>.from(nested) : raw;
  final mindMapId = (raw['mindMapId'] ??
          raw['mind_map_id'] ??
          content['id'] ??
          '')
      .toString();

  final apiTree = content['content'];
  if (apiTree is Map && (apiTree['children'] as List?)?.isNotEmpty == true) {
    final data = normalizeToolData({
      'tool_type': 'mind_maps',
      'title': content['title'] ?? content['name'] ?? fallbackTitle,
      'content': apiTree,
      if (mindMapId.isNotEmpty) 'mindMapId': mindMapId,
    });
    return data;
  }

  final nodes = content['nodes'];
  final root = content['root'] ?? content['centralTopic'] ?? content['title'];
  if (nodes is List && nodes.isNotEmpty && root != null) {
    return normalizeToolData({
      'tool_type': 'mind_maps',
      'title': content['title'] ?? content['name'] ?? fallbackTitle,
      'root': root.toString(),
      'nodes': nodes,
      if (mindMapId.isNotEmpty) 'mindMapId': mindMapId,
    });
  }

  return null;
}
