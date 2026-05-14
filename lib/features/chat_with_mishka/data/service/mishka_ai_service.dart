import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../controller/chat_flow_controller.dart';

String _basename(String filePath) {
  final sep = Platform.pathSeparator;
  final i = filePath.lastIndexOf(sep);
  return i < 0 ? filePath : filePath.substring(i + 1);
}

class MishkaAiService {
  /// Override with `--dart-define=AI_BASE_URL=https://...` when needed.
  final String baseUrl;

  MishkaAiService({
    this.baseUrl = const String.fromEnvironment(
      'AI_BASE_URL',
      defaultValue: 'https://mishka-ai-model-production.up.railway.app',
    ),
  });

  /// OpenAPI: `POST /upload` multipart — only `file` (required) and `summary_level`.
  /// Tool choice is sent later via `POST /generate-tools` (query params).
  Future<ExplainResult> explainPdf({
    required String pdfPath,
    required String summaryLevel, // "simple" | "detailed"
  }) async {
    final uri = Uri.parse('$baseUrl/upload');
    _logRequest(
      method: 'POST',
      path: '/upload',
      body: {
        'summary_level': summaryLevel,
        'file': pdfPath,
      },
    );

    final req = http.MultipartRequest('POST', uri)..fields['summary_level'] = summaryLevel;

    final fileName = _basename(pdfPath);
    int? fileBytes;
    try {
      fileBytes = await File(pdfPath).length();
    } catch (_) {}
    if (kDebugMode && fileBytes != null) {
      debugPrint('🤖 AI UPLOAD file: $fileName ($fileBytes bytes)');
    }

    req.files.add(
      await http.MultipartFile.fromPath(
        'file',
        pdfPath,
        filename: fileName,
        contentType: MediaType('application', 'pdf'),
      ),
    );

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    _logResponse(method: 'POST', path: '/upload', statusCode: res.statusCode, body: res.body);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      _logError(
        method: 'POST',
        path: '/upload',
        statusCode: res.statusCode,
        body: res.body,
        fullUrl: uri.toString(),
        responseHeaders: res.headers,
      );
      throw Exception('Upload failed (${res.statusCode}): ${res.body}');
    }

    final json = _jsonDecode(res.body);
    return ExplainResult(
      sessionId: (json['session_id'] ?? '').toString(),
      explanation: (json['explanation'] ?? '').toString(),
    );
  }

  /// OpenAPI: `POST /chat` — query params `session_id`, `message`.
  Future<String> chat({
    required String sessionId,
    required String message,
  }) async {
    final uri = Uri.parse('$baseUrl/chat').replace(
      queryParameters: {
        'session_id': sessionId,
        'message': message,
      },
    );
    if (kDebugMode) {
      debugPrint('🤖 AI REQUEST [POST] /chat');
      debugPrint('   url: $uri');
    }

    final res = await http.post(uri);
    _logResponse(method: 'POST', path: '/chat', statusCode: res.statusCode, body: res.body);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      _logError(
        method: 'POST',
        path: '/chat',
        statusCode: res.statusCode,
        body: res.body,
        fullUrl: uri.toString(),
        responseHeaders: res.headers,
      );
      throw Exception('Chat failed (${res.statusCode}): ${res.body}');
    }

    final json = _jsonDecode(res.body);
    return (json['response'] ?? '').toString();
  }

  /// OpenAPI: `POST /generate-tools` — query params `session_id`, `tool_type`, `complexity`.
  Future<Map<String, dynamic>> generateTool({
    required String sessionId,
    required StudyAction action,
    required String complexity, // "Simple" | "Intermediate" | "Hard" (your UI)
  }) async {
    final toolType = _toolType(action);
    final uri = Uri.parse('$baseUrl/generate-tools').replace(
      queryParameters: {
        'session_id': sessionId,
        'tool_type': toolType,
        'complexity': complexity,
      },
    );
    if (kDebugMode) {
      debugPrint('🤖 AI REQUEST [POST] /generate-tools');
      debugPrint('   url: $uri');
    }

    final res = await http.post(uri);
    _logResponse(
      method: 'POST',
      path: '/generate-tools',
      statusCode: res.statusCode,
      body: res.body,
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      _logError(
        method: 'POST',
        path: '/generate-tools',
        statusCode: res.statusCode,
        body: res.body,
        fullUrl: uri.toString(),
        responseHeaders: res.headers,
      );
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
      case StudyAction.summarize:
        return 'summaries';
    }
  }

  void _logRequest({
    required String method,
    required String path,
    required Map<String, dynamic> body,
  }) {
    if (!kDebugMode) return;
    debugPrint('🤖 AI REQUEST [$method] $path');
    debugPrint('   body: $body');
  }

  void _logResponse({
    required String method,
    required String path,
    required int statusCode,
    required String body,
  }) {
    if (!kDebugMode) return;
    debugPrint('🤖 AI RESPONSE [$method] $path');
    debugPrint('   status: $statusCode');
    debugPrint('   body: $body');
  }

  void _logError({
    required String method,
    required String path,
    required int statusCode,
    required String body,
    String? fullUrl,
    Map<String, String>? responseHeaders,
  }) {
    if (!kDebugMode) return;
    debugPrint('🤖 AI ERROR [$method] $path');
    if (fullUrl != null) {
      debugPrint('   url: $fullUrl');
    }
    debugPrint('   status: $statusCode');
    debugPrint('   body: $body');
    if (responseHeaders != null && responseHeaders.isNotEmpty) {
      const want = [
        'x-request-id',
        'x-railway-request-id',
        'cf-ray',
        'server',
        'content-type',
      ];
      for (final key in responseHeaders.keys) {
        final lower = key.toLowerCase();
        if (want.contains(lower) || lower.contains('request') && lower.contains('id')) {
          debugPrint('   $key: ${responseHeaders[key]}');
        }
      }
    }
  }
}

/// Simple JSON decode without importing `dart:convert` everywhere
dynamic _jsonDecode(String body) {
  return body.isNotEmpty ? jsonDecode(body) : {};
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
