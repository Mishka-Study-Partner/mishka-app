import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Keeps uploaded chat PDFs on device so sessions can regenerate tools after reopen.
/// Files expire after [retentionDays] (default 30).
class ChatPdfCache {
  ChatPdfCache._();

  static const retentionDays = 30;

  static Future<Directory> _cacheDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/chat_pdf_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static File _pdfFile(Directory dir, String sessionId) =>
      File('${dir.path}/$sessionId.pdf');

  static File _metaFile(Directory dir) => File('${dir.path}/index.json');

  /// Copies [sourcePath] into app storage keyed by [sessionId].
  static Future<String> persistForSession({
    required String sessionId,
    required String sourcePath,
  }) async {
    final dir = await _cacheDir();
    final dest = _pdfFile(dir, sessionId);
    await File(sourcePath).copy(dest.path);

    final meta = await _readMeta(dir);
    meta[sessionId] = {
      'savedAt': DateTime.now().toUtc().toIso8601String(),
    };
    await _writeMeta(dir, meta);
    await purgeExpired();
    return dest.path;
  }

  /// Returns cached PDF path when still within retention window.
  static Future<String?> pathForSession(String sessionId) async {
    if (sessionId.isEmpty) return null;
    final dir = await _cacheDir();
    final meta = await _readMeta(dir);
    final entry = meta[sessionId];
    if (entry is Map) {
      final savedAt = DateTime.tryParse((entry['savedAt'] ?? '').toString());
      if (savedAt != null &&
          DateTime.now().difference(savedAt).inDays > retentionDays) {
        await deleteForSession(sessionId);
        return null;
      }
    }

    final file = _pdfFile(dir, sessionId);
    if (await file.exists()) return file.path;
    return null;
  }

  static Future<void> deleteForSession(String sessionId) async {
    final dir = await _cacheDir();
    final file = _pdfFile(dir, sessionId);
    if (await file.exists()) {
      await file.delete();
    }
    final meta = await _readMeta(dir);
    meta.remove(sessionId);
    await _writeMeta(dir, meta);
  }

  static Future<void> purgeExpired() async {
    final dir = await _cacheDir();
    final meta = await _readMeta(dir);
    final now = DateTime.now();
    final toRemove = <String>[];

    for (final entry in meta.entries) {
      if (entry.value is! Map) continue;
      final savedAt =
          DateTime.tryParse((entry.value['savedAt'] ?? '').toString());
      if (savedAt == null || now.difference(savedAt).inDays > retentionDays) {
        toRemove.add(entry.key);
      }
    }

    for (final id in toRemove) {
      await deleteForSession(id);
    }
  }

  static Future<Map<String, dynamic>> _readMeta(Directory dir) async {
    final file = _metaFile(dir);
    if (!await file.exists()) return {};
    try {
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return {};
  }

  static Future<void> _writeMeta(
    Directory dir,
    Map<String, dynamic> meta,
  ) async {
    await _metaFile(dir).writeAsString(jsonEncode(meta));
  }
}
