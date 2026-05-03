
import 'package:http/http.dart' as http;

import '../controller/chat_flow_controller.dart';

class MishkaAiService {
  /// Example: "http://127.0.0.1:8000"
  /// Put it in flavors later if you want.
  final String baseUrl;

  MishkaAiService({this.baseUrl = 'http://127.0.0.1:8000'});

  /// According to your AI doc:
  /// POST /upload (multipart: file, summary_level)
  /// returns: { session_id, explanation } :contentReference[oaicite:3]{index=3}
  Future<ExplainResult> explainPdf({
    required String pdfPath,
    required String summaryLevel, // "simple" | "detailed"
  }) async {
    final uri = Uri.parse('$baseUrl/upload');

    final req = http.MultipartRequest('POST', uri)
      ..fields['summary_level'] = summaryLevel
      ..files.add(await http.MultipartFile.fromPath('file', pdfPath));

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Upload failed (${res.statusCode}): ${res.body}');
    }

    final json = _jsonDecode(res.body);
    return ExplainResult(
      sessionId: (json['session_id'] ?? '').toString(),
      explanation: (json['explanation'] ?? '').toString(),
    );
  }

  /// POST /chat(session_id, message) -> { response } :contentReference[oaicite:4]{index=4}
  Future<String> chat({
    required String sessionId,
    required String message,
  }) async {
    final uri = Uri.parse('$baseUrl/chat');

    // doc shows function signature like /chat(session_id: str, message: str)
    // so safest is form-encoded.
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'session_id': sessionId,
        'message': message,
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Chat failed (${res.statusCode}): ${res.body}');
    }

    final json = _jsonDecode(res.body);
    return (json['response'] ?? '').toString();
  }

  /// POST /generate-tools(session_id, tool_type, complexity) :contentReference[oaicite:5]{index=5}
  Future<Map<String, dynamic>> generateTool({
    required String sessionId,
    required StudyAction action,
    required String complexity, // "Simple" | "Intermediate" | "Hard" (your UI)
  }) async {
    final uri = Uri.parse('$baseUrl/generate-tools');

    final toolType = _toolType(action); // quizzes|flashcards|mind_maps

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'session_id': sessionId,
        'tool_type': toolType,
        'complexity': complexity,
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Generate-tools failed (${res.statusCode}): ${res.body}');
    }

    return _jsonDecode(res.body) as Map<String, dynamic>;
  }

  String _toolType(StudyAction action) {
    switch (action) {
      case StudyAction.quiz:
        return 'quizzes';
      case StudyAction.flashcards:
        return 'flashcards';
      case StudyAction.mindmap:
        return 'mind_maps';
    }
  }
}

/// Simple JSON decode without importing `dart:convert` everywhere
dynamic _jsonDecode(String body) {
  // keep it simple; you can swap to jsonDecode directly
  // ignore: avoid_dynamic_calls
  return (body.isNotEmpty) ? _Json.jsonDecode(body) : {};
}

class ExplainResult {
  final String sessionId;
  final String explanation;

  ExplainResult({
    required this.sessionId,
    required this.explanation,
  });
}

/// Local helper so this file stays minimal.
class _Json {
  static dynamic jsonDecode(String source) {
    // ignore: avoid_dynamic_calls
    return (const _JsonCodec()).decode(source);
  }
}

class _JsonCodec {
  const _JsonCodec();
  dynamic decode(String source) {
    // dart:convert jsonDecode
    // kept inline so you don’t forget the import.
    // ignore: avoid_dynamic_calls
    return _dartConvertJsonDecode(source);
  }
}

// ---- dart:convert bridge (so code block is copy/paste ready) ----
dynamic _dartConvertJsonDecode(String s) {
  // ignore: avoid_dynamic_calls
  return (const _DartConvert()).decode(s);
}

class _DartConvert {
  const _DartConvert();
  dynamic decode(String s) {
    // real one:
    // return jsonDecode(s);
    // but we must import dart:convert:
    throw UnimplementedError(
      'Add: import "dart:convert"; and replace this helper with jsonDecode(s).',
    );
  }
}
