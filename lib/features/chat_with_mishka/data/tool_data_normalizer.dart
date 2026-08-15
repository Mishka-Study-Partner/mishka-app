import 'dart:convert';

import 'package:mishka_app/features/chat_with_mishka/data/ai_study_text_extractor.dart';

/// Maps Stanley AI `/generate-tools` JSON into shapes [ToolPreviewRenderer] expects.
Map<String, dynamic> normalizeToolData(Map<String, dynamic> raw) {
  final data = Map<String, dynamic>.from(raw);
  _unwrapNestedPayload(data);
  var toolType =
      (data['tool_type'] ?? data['toolType'] ?? '').toString().toLowerCase();

  if (toolType == 'quiz') toolType = 'quizzes';
  if (toolType == 'mindmap') toolType = 'mind_maps';
  if (toolType == 'summarize') toolType = 'summaries';
  if (toolType.isEmpty) {
    toolType = _inferToolType(data);
  }
  if (toolType.isNotEmpty) data['tool_type'] = toolType;

  switch (toolType) {
    case 'quizzes':
      _normalizeQuiz(data);
      break;
    case 'flashcards':
      _normalizeFlashcards(data);
      break;
    case 'mind_maps':
      _normalizeMindMap(data);
      break;
    case 'summaries':
    case 'summary':
      _normalizeSummary(data);
      data['tool_type'] = 'summaries';
      break;
  }

  return data;
}

void _unwrapNestedPayload(Map<String, dynamic> data) {
  data.addAll(AiStudyTextExtractor.unwrapPayload(data));
}

String _inferToolType(Map<String, dynamic> data) {
  if (data['questions'] != null || data['quizzes'] != null) return 'quizzes';
  if (data['cards'] != null || data['flashcards'] != null) return 'flashcards';
  if (data['nodes'] != null || data['root'] != null) return 'mind_maps';

  final content = data['content'];
  if (content is List) {
    if (content.isEmpty) return '';
    final first = content.first;
    if (first is Map) {
      if (first.containsKey('question') || first.containsKey('options')) {
        return 'quizzes';
      }
      if (first.containsKey('front') || first.containsKey('back')) {
        return 'flashcards';
      }
      if (first.containsKey('children') || first.containsKey('title')) {
        return 'mind_maps';
      }
    }
  }
  if (content is Map) {
    if (content.containsKey('children') ||
        content.containsKey('title') ||
        content.containsKey('nodes')) {
      return 'mind_maps';
    }
  }

  if (data['summaryText'] != null ||
      data['explanation'] != null ||
      data['summary'] != null ||
      content is String ||
      (content is List &&
          content.isNotEmpty &&
          content.every((e) => e is String))) {
    return 'summaries';
  }

  final text = data['text'];
  if (text is String && text.trim().length > 80) return 'summaries';

  return '';
}

void _normalizeQuiz(Map<String, dynamic> data) {
  final existing = data['questions'];
  if (existing is List && existing.isNotEmpty) {
    final normalized = normalizeQuizQuestionsList(existing);
    if (normalized.isNotEmpty) {
      data['questions'] = normalized;
      data['totalQuestions'] = normalized.length;
    }
    return;
  }

  final rawItems = data['content'] ??
      data['questions'] ??
      data['quizzes'] ??
      data['quizQuestions'];
  if (rawItems is! List) return;

  final questions = normalizeQuizQuestionsList(rawItems);
  if (questions.isNotEmpty) {
    data['questions'] = questions;
    data['totalQuestions'] = questions.length;
  }
}

List<Map<String, dynamic>> normalizeQuizQuestionsList(List<dynamic> raw) {
  final questions = <Map<String, dynamic>>[];
  for (final item in raw) {
    if (item is! Map) continue;
    questions.add(normalizeQuizQuestionRow(Map<String, dynamic>.from(item)));
  }
  return questions;
}

Map<String, dynamic> normalizeQuizQuestionRow(Map<String, dynamic> row) {
  var options = List<String>.from(
    (row['options'] as List?)?.map((e) => e.toString()) ?? const [],
  );
  if (options.isEmpty) {
    options = [
      row['optionA'],
      row['optionB'],
      row['optionC'],
      row['optionD'],
    ]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .map((e) => e.toString())
        .toList();
  }
  if (options.isEmpty && row['choices'] is List) {
    options = List<String>.from(
      (row['choices'] as List).map((e) => e.toString()),
    );
  }

  var correctIndex = row['correctOptionIndex'] as int?;
  if (correctIndex == null || correctIndex < 0) {
    final letter = (row['correctOption'] ??
            row['correctAnswer'] ??
            row['correct_answer'])
        ?.toString()
        .trim();
    if (letter != null && letter.length == 1) {
      correctIndex = 'ABCD'.indexOf(letter.toUpperCase());
    } else if (letter != null && options.isNotEmpty) {
      correctIndex = options.indexWhere((o) => o == letter);
    }
  }

  return {
    if (row['id'] != null) 'id': row['id'].toString(),
    'questionText':
        (row['questionText'] ?? row['question'] ?? row['text'] ?? '').toString(),
    'options': options,
    'correctOptionIndex': correctIndex ?? -1,
  };
}

/// Builds quiz tool data from a saved-library detail payload.
Map<String, dynamic>? buildQuizToolDataFromSavedDetail(
  Map<String, dynamic> raw, {
  String fallbackTitle = 'Quiz',
}) {
  final quiz = raw['quiz'];
  final content = quiz is Map ? Map<String, dynamic>.from(quiz) : raw;
  final quizId = (raw['quizId'] ?? content['id'] ?? '').toString();

  final questions = raw['questions'] ??
      content['questions'] ??
      content['quizQuestions'] ??
      raw['quizQuestions'];
  if (questions is! List || questions.isEmpty) return null;

  final data = normalizeToolData({
    'tool_type': 'quizzes',
    'title': content['title'] ?? content['name'] ?? fallbackTitle,
    'questions': questions,
    if (quizId.isNotEmpty) 'quizId': quizId,
    if (content['totalQuestions'] != null)
      'totalQuestions': content['totalQuestions'],
  });
  return data;
}

/// Builds flashcard tool data from a saved-library detail payload.
Map<String, dynamic>? buildFlashcardToolDataFromSavedDetail(
  Map<String, dynamic> raw, {
  String fallbackTitle = 'Flashcards',
}) {
  final nested = raw['flashcardSet'] ?? raw['flashcard_set'] ?? raw['set'];
  final content = nested is Map ? Map<String, dynamic>.from(nested) : raw;
  final setId = (raw['flashcardSetId'] ??
          raw['flashcard_set_id'] ??
          content['id'] ??
          '')
      .toString();
  final cards = content['cards'] ??
      content['flashcards'] ??
      raw['flashcards'] ??
      raw['cards'];
  if (cards is! List || cards.isEmpty) return null;

  return normalizeToolData({
    'tool_type': 'flashcards',
    'title': content['title'] ?? content['name'] ?? fallbackTitle,
    'cards': cards,
    if (setId.isNotEmpty) 'flashcardSetId': setId,
  });
}

bool quizQuestionsMissingOptions(Map<String, dynamic> toolData) {
  final questions = toolData['questions'] as List?;
  if (questions == null || questions.isEmpty) return true;
  for (final item in questions) {
    if (item is! Map) return true;
    final options = item['options'] as List?;
    if (options == null || options.isEmpty) return true;
  }
  return false;
}

void _normalizeFlashcards(Map<String, dynamic> data) {
  final existingCards = data['cards'] ?? data['flashcards'];
  if (existingCards is List && existingCards.isNotEmpty) {
    data['cards'] = existingCards.map((item) {
      if (item is! Map) {
        return {'front': item.toString(), 'back': ''};
      }
      final row = Map<String, dynamic>.from(item);
      return {
        'front': (row['front'] ?? row['question'] ?? row['term'] ?? '')
            .toString(),
        'back': (row['back'] ?? row['answer'] ?? row['definition'] ?? '')
            .toString(),
        if (row['image'] != null) 'image': row['image'],
      };
    }).toList();
    return;
  }

  final rawItems = data['content'] ?? data['cards'] ?? data['flashcards'];
  if (rawItems is! List) return;

  data['cards'] = rawItems.map((item) {
    if (item is! Map) {
      return {'front': item.toString(), 'back': ''};
    }
    final row = Map<String, dynamic>.from(item);
    return {
      'front': (row['front'] ?? row['question'] ?? row['term'] ?? '').toString(),
      'back': (row['back'] ?? row['answer'] ?? row['definition'] ?? '').toString(),
    };
  }).toList();
}

void _normalizeMindMap(Map<String, dynamic> data) {
  if (data['nodes'] is! List || (data['nodes'] as List).isEmpty) {
    final content = data['content'];
    if (content is String && content.trim().startsWith('{')) {
      try {
        final parsed = jsonDecode(content);
        if (parsed is Map) {
          data.addAll(Map<String, dynamic>.from(parsed));
        }
      } catch (_) {}
    } else if (content is Map) {
      final map = Map<String, dynamic>.from(content);
      data['root'] ??=
          map['root'] ?? map['title'] ?? map['central_topic'] ?? map['name'];
      data['nodes'] ??= map['nodes'] ??
          map['branches'] ??
          map['topics'] ??
          map['children'];
    } else if (content is List && content.isNotEmpty) {
      data['nodes'] = content;
      data['root'] ??= data['title'] ?? 'Topic';
    }
    data['nodes'] ??= data['branches'] ?? data['topics'] ?? data['children'];
  }

  // Tree root at top level: { title, children: [...] }
  if ((data['nodes'] is! List || (data['nodes'] as List).isEmpty) &&
      data['children'] is List &&
      (data['children'] as List).isNotEmpty) {
    data['root'] ??= data['title'] ?? data['root'] ?? 'Topic';
    data['nodes'] = data['children'];
  }

  if (data['nodes'] is List && (data['nodes'] as List).isNotEmpty) {
    data['nodes'] = _coerceMindMapNodes(data['nodes'] as List);
    data['root'] ??= data['title'] ?? 'Topic';
    return;
  }

  data['root'] ??= data['title'] ?? 'Topic';
  data['nodes'] ??= <Map<String, dynamic>>[];
}

List<Map<String, dynamic>> _coerceMindMapNodes(List<dynamic> raw) {
  return raw.map((item) {
    if (item is String) {
      return {'title': item, 'children': <dynamic>[]};
    }
    if (item is Map) {
      final row = Map<String, dynamic>.from(item);
      final title = (row['title'] ??
              row['label'] ??
              row['name'] ??
              row['text'] ??
              row['topic'] ??
              'Node')
          .toString();
      final children =
          row['children'] ?? row['subtopics'] ?? row['branches'] ?? const [];
      return {
        'title': title,
        'children': _coerceMindMapChildren(children),
      };
    }
    return {'title': item.toString(), 'children': <dynamic>[]};
  }).toList();
}

List<dynamic> _coerceMindMapChildren(dynamic raw) {
  if (raw is! List) return const [];
  return raw.map((child) {
    if (child is Map) {
      final row = Map<String, dynamic>.from(child);
      return (row['title'] ??
              row['label'] ??
              row['name'] ??
              row['text'] ??
              row['topic'] ??
              child)
          .toString();
    }
    return child.toString();
  }).toList();
}

/// Whether normalized mind map data has enough structure to persist.
bool mindMapHasSaveableContent(Map<String, dynamic> normalized) {
  final nodes = (normalized['nodes'] as List?) ?? const [];
  if (nodes.isNotEmpty) return true;
  final content = normalized['content'];
  return content is Map && (content['children'] as List?)?.isNotEmpty == true;
}

/// Builds the tree `{ title, children }` shape required by `POST /mind-maps`.
Map<String, dynamic> mindMapContentForApi(Map<String, dynamic> normalized) {
  Map<String, dynamic>? candidate;

  final existing = normalized['content'];
  if (existing is Map) {
    final map = Map<String, dynamic>.from(existing);
    if (map['children'] is List && (map['children'] as List).isNotEmpty) {
      map.putIfAbsent(
        'title',
        () => normalized['root'] ?? normalized['title'] ?? 'Topic',
      );
      candidate = map;
    }
  }

  candidate ??= {
    'title': (normalized['root'] ?? normalized['title'] ?? 'Topic').toString(),
    'children': ((normalized['nodes'] as List?) ?? const [])
        .map(_mindMapNodeToApiTree)
        .toList(),
  };

  return sanitizeMindMapContentTree(candidate);
}

/// Recursively normalizes AI / UI mind map trees for backend JSON validation.
Map<String, dynamic> sanitizeMindMapContentTree(Map<String, dynamic> raw) {
  final title = (raw['title'] ?? raw['label'] ?? raw['name'] ?? raw['root'] ?? 'Topic')
      .toString()
      .trim();
  final childrenRaw = raw['children'] ?? raw['nodes'] ?? raw['branches'] ?? const [];
  final children = <Map<String, dynamic>>[];
  if (childrenRaw is List) {
    for (final child in childrenRaw) {
      if (child is Map) {
        children.add(sanitizeMindMapContentTree(Map<String, dynamic>.from(child)));
      } else if (child != null && child.toString().trim().isNotEmpty) {
        children.add({
          'title': child.toString().trim(),
          'children': <Map<String, dynamic>>[],
        });
      }
    }
  }

  return {
    'title': title.isEmpty ? 'Topic' : title,
    'children': children,
  };
}

Map<String, dynamic> _mindMapNodeToApiTree(dynamic node) {
  if (node is String) {
    return {'title': node, 'children': <Map<String, dynamic>>[]};
  }
  if (node is Map) {
    final row = Map<String, dynamic>.from(node);
    final title = (row['title'] ?? row['label'] ?? row['name'] ?? 'Node')
        .toString();
    final children =
        row['children'] ?? row['subtopics'] ?? row['branches'] ?? const [];
    return {
      'title': title,
      'children': (children as List).map(_mindMapChildToApiTree).toList(),
    };
  }
  return {'title': node.toString(), 'children': <Map<String, dynamic>>[]};
}

Map<String, dynamic> _mindMapChildToApiTree(dynamic child) {
  if (child is Map) {
    return _mindMapNodeToApiTree(child);
  }
  return {'title': child.toString(), 'children': <Map<String, dynamic>>[]};
}

/// Summary is produced by `POST /upload` (`explanation`), not `/generate-tools`.
Map<String, dynamic> buildSummaryToolData({
  required String summary,
  String? title,
}) {
  final text = summary.trim();
  return normalizeToolData({
    'tool_type': 'summaries',
    'summaryText': text,
    'summary': text,
    'text': text,
    if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
  });
}

void _normalizeSummary(Map<String, dynamic> data) {
  final resolved = AiStudyTextExtractor.resolveSummaryBody(data);
  if (resolved == null || resolved.isEmpty) return;

  data['summaryText'] = resolved;
  data['summary'] = resolved;
  data['text'] = resolved;
}

/// True when [value] looks like an uploaded document name (e.g. `notes.pdf`).
bool looksLikeUploadedFilename(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.contains('://')) return false;
  final dot = trimmed.lastIndexOf('.');
  if (dot <= 0 || dot >= trimmed.length - 1) return false;
  final ext = trimmed.substring(dot + 1).toLowerCase();
  return ext.length <= 10 && RegExp(r'^[a-z0-9]+$').hasMatch(ext);
}

/// Embeds upload metadata on generated tool payloads before save/share.
void attachSourceFileMetadata(
  Map<String, dynamic> data, {
  String? uploadOriginalFilename,
  String? chatSessionId,
}) {
  final name = uploadOriginalFilename?.trim();
  if (name != null && name.isNotEmpty) {
    data['uploadOriginalFilename'] = name;
    data['sourceReference'] = name;
  }
  final sessionId = chatSessionId?.trim();
  if (sessionId != null && sessionId.isNotEmpty) {
    data['chatSessionId'] = sessionId;
  }
}

/// Fields for Mishka create endpoints (`sourceReference` = original PDF name).
Map<String, dynamic> sourceReferenceFieldsForCreate(
  Map<String, dynamic> normalized,
) {
  for (final key in const [
    'uploadOriginalFilename',
    'sourceReference',
    'sourceFileName',
  ]) {
    final value = normalized[key]?.toString().trim();
    if (value != null &&
        value.isNotEmpty &&
        looksLikeUploadedFilename(value)) {
      return {'sourceReference': value};
    }
  }
  return const {};
}

Map<String, dynamic> chatSessionFieldForCreate(Map<String, dynamic> normalized) {
  final sessionId = normalized['chatSessionId']?.toString().trim();
  if (sessionId == null || sessionId.isEmpty) return const {};
  return {'chatSessionId': sessionId};
}
