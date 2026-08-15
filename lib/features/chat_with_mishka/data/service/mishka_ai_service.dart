import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mishka_app/features/chat_with_mishka/data/ai_service_config.dart';
import 'package:mishka_app/features/chat_with_mishka/data/ai_service_logger.dart';
import 'package:mishka_app/features/chat_with_mishka/data/ai_response_helpers.dart';
import 'package:mishka_app/features/chat_with_mishka/data/ai_study_text_extractor.dart';

import 'package:mishka_app/features/chat_with_mishka/data/generate_tools_result.dart';

import '../controller/chat_flow_controller.dart';

String _basename(String filePath) {
  final sep = Platform.pathSeparator;
  final i = filePath.lastIndexOf(sep);
  return i < 0 ? filePath : filePath.substring(i + 1);
}

class MishkaAiService {
  final String baseUrl;

  MishkaAiService({String? baseUrl})
      : baseUrl = baseUrl ?? AiServiceConfig.baseUrl;

  Map<String, String> get _headers => AiServiceConfig.headers;

  /// OpenAPI: `POST /upload` multipart — only `file` (required) and `summary_level`.
  /// Tool choice is sent later via `POST /generate-tools` (query params).
  Future<ExplainResult> explainPdf({
    required String pdfPath,
    required String summaryLevel, // "simple" | "detailed"
  }) async {
    final uri = Uri.parse('$baseUrl/upload');
    try {
      return await _explainPdf(
        uri: uri,
        pdfPath: pdfPath,
        summaryLevel: summaryLevel,
      );
    } catch (e, st) {
      logAiServiceError(
        operation: 'POST /upload',
        error: e,
        stackTrace: st,
        baseUrl: baseUrl,
        url: uri.toString(),
      );
      rethrow;
    }
  }

  Future<ExplainResult> _explainPdf({
    required Uri uri,
    required String pdfPath,
    required String summaryLevel,
  }) async {
    _logRequest(
      method: 'POST',
      path: '/upload',
      body: {
        'summary_level': summaryLevel,
        'file': pdfPath,
      },
    );

    final req = http.MultipartRequest('POST', uri)
      ..fields['summary_level'] = summaryLevel;
    if (_headers.isNotEmpty) {
      req.headers.addAll(_headers);
    }

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

    final streamed = await req.send().timeout(AiServiceConfig.uploadTimeout);
    final res = await http.Response.fromStream(streamed)
        .timeout(AiServiceConfig.uploadTimeout);
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
      throw AiServiceException(
        detail: res.statusCode == 503 &&
                res.body.toLowerCase().contains('ngrok')
            ? 'AI upload service is offline. If using ngrok dev, restart the tunnel; otherwise check Railway AI deployment.'
            : res.statusCode >= 500
                ? 'AI upload service is unavailable (${res.statusCode}). Check the Railway AI deployment and try again.'
                : 'Upload failed (${res.statusCode}): ${res.body}',
      );
    }

    final decoded = _jsonDecode(res.body);
    final json = decoded is Map<String, dynamic>
        ? decoded
        : decoded is Map
            ? Map<String, dynamic>.from(decoded)
            : <String, dynamic>{};
    final payload = AiStudyTextExtractor.unwrapPayload(json);
    final sessionId =
        (payload['session_id'] ?? payload['sessionId'] ?? '').toString();
    final explanation = AiStudyTextExtractor.extractUploadExplanation(json) ?? '';
    AiResponseHelpers.throwIfProviderError(explanation, field: 'explanation');
    if (explanation.trim().isEmpty) {
      throw AiServiceException(
        detail: 'Upload returned empty explanation (session_id=$sessionId)',
      );
    }
    return ExplainResult(
      sessionId: sessionId,
      explanation: explanation,
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
    try {
      return await _chat(uri);
    } catch (e, st) {
      logAiServiceError(
        operation: 'POST /chat',
        error: e,
        stackTrace: st,
        baseUrl: baseUrl,
        url: uri.toString(),
      );
      rethrow;
    }
  }

  Future<String> _chat(Uri uri) async {
    if (kDebugMode) {
      debugPrint('🤖 AI REQUEST [POST] /chat');
      debugPrint('   url: $uri');
    }

    final res = await http
        .post(uri, headers: _headers)
        .timeout(AiServiceConfig.chatTimeout);
    _logResponse(method: 'POST', path: '/chat', statusCode: res.statusCode, body: res.body);

    if (res.statusCode == 404) {
      throw const AiSessionNotFoundException();
    }

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
    final response = (json['response'] ?? '').toString();
    AiResponseHelpers.throwIfProviderError(response, field: 'response');
    if (response.trim().isEmpty) {
      throw const AiServiceException(detail: 'Chat returned empty response');
    }
    return response;
  }

  /// OpenAPI: `POST /generate-tools` — query params `session_id`, `tool_type`, `complexity`.
  Future<GenerateToolsResult> generateTool({
    required String sessionId,
    required StudyAction action,
    required String complexity, // "Simple" | "Intermediate" | "Hard"
  }) async {
    final toolType = _toolType(action);
    final uri = Uri.parse('$baseUrl/generate-tools').replace(
      queryParameters: {
        'session_id': sessionId,
        'tool_type': toolType,
        'complexity': complexity,
      },
    );
    try {
      return await _generateTool(uri: uri, toolType: toolType);
    } catch (e, st) {
      logAiServiceError(
        operation: 'POST /generate-tools',
        error: e,
        stackTrace: st,
        baseUrl: baseUrl,
        url: uri.toString(),
      );
      rethrow;
    }
  }

  Future<GenerateToolsResult> _generateTool({
    required Uri uri,
    required String toolType,
  }) async {
    if (kDebugMode) {
      debugPrint('🤖 AI REQUEST [POST] /generate-tools');
      debugPrint('   url: $uri');
    }

    final res = await http
        .post(uri, headers: _headers)
        .timeout(AiServiceConfig.generateToolsTimeout);
    _logResponse(
      method: 'POST',
      path: '/generate-tools',
      statusCode: res.statusCode,
      body: res.body,
    );

    if (res.statusCode == 404) {
      throw const AiSessionNotFoundException();
    }

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

    final decoded = _jsonDecode(res.body);
    final map = decoded is Map<String, dynamic>
        ? decoded
        : decoded is Map
            ? Map<String, dynamic>.from(decoded)
            : <String, dynamic>{};
    map.putIfAbsent('tool_type', () => toolType);
    final errorText = (map['error'] ?? map['detail'] ?? map['message'])?.toString();
    if (errorText != null && AiResponseHelpers.looksLikeProviderError(errorText)) {
      throw AiServiceException(detail: errorText);
    }
    return parseGenerateToolsResponse(map);
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
    debugPrint('   baseUrl: $baseUrl');
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
    final preview = body.length > 500 ? '${body.substring(0, 500)}…' : body;
    debugPrint('   body: $preview');
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
