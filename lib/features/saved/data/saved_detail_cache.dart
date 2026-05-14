import 'dart:convert';

import 'package:mishka_app/features/saved/data/models/saved_detail_model.dart';
import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Last successful `GET /saved-*/{id}` payload per list row (offline / fast reopen).
class SavedDetailCache {
  SavedDetailCache._();

  static const _keyPrefix = 'mishka_saved_detail_v1_';

  static String _key(SavedContentKind kind, String savedListItemId) =>
      '$_keyPrefix${kind.name}_$savedListItemId';

  static Future<SavedLibraryDetail?> read(
    SavedContentKind kind,
    String savedListItemId,
  ) async {
    if (savedListItemId.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(kind, savedListItemId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return SavedLibraryDetail(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  static Future<void> write(
    SavedContentKind kind,
    String savedListItemId,
    Map<String, dynamic> raw,
  ) async {
    if (savedListItemId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(kind, savedListItemId), jsonEncode(raw));
  }

  static Future<void> clear(SavedContentKind kind, String savedListItemId) async {
    if (savedListItemId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(kind, savedListItemId));
  }
}
