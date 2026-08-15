import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists todo list icon picks locally when `/icons` is empty or [iconId] is unset.
class TodoListIconPreferences {
  TodoListIconPreferences._();

  static const _key = 'mishka_todo_list_icon_labels';

  static Map<String, String>? _cache;

  static Future<Map<String, String>> allLabels() async {
    if (_cache != null) return Map<String, String>.from(_cache!);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      _cache = {};
      return {};
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _cache = decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
    } catch (_) {
      _cache = {};
    }
    return Map<String, String>.from(_cache!);
  }

  static Future<void> setLabel(String listId, String label) async {
    final all = await allLabels();
    all[listId] = label;
    await _persist(all);
  }

  static Future<void> removeLabel(String listId) async {
    final all = await allLabels();
    if (!all.containsKey(listId)) return;
    all.remove(listId);
    await _persist(all);
  }

  static Future<void> _persist(Map<String, String> all) async {
    _cache = Map<String, String>.from(all);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(all));
  }
}
