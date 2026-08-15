import 'dart:convert';

/// Reference embedded in community channel messages when `inputType` is `material`.
class CommunityMaterialRef {
  const CommunityMaterialRef({
    required this.materialType,
    required this.materialId,
    this.note,
  });

  /// Backend enum: `quiz` | `flashcard_set` | `summary` | `mind_map`.
  final String materialType;
  final String materialId;
  final String? note;

  static CommunityMaterialRef? tryParseFromMessage({
    required String inputType,
    required String messageContent,
  }) {
    final type = inputType.trim().toLowerCase();
    if (type != 'material') return null;

    final content = messageContent.trim();
    if (content.isEmpty) return null;

    try {
      final decoded = jsonDecode(content);
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);

      final materialType = (map['materialType'] ?? map['material_type'] ?? '')
          .toString()
          .trim();
      final materialId =
          (map['materialId'] ?? map['material_id'] ?? map['id'] ?? '')
              .toString()
              .trim();
      if (materialType.isEmpty || materialId.isEmpty) return null;

      final note = (map['note'] ?? '').toString().trim();
      return CommunityMaterialRef(
        materialType: materialType,
        materialId: materialId,
        note: note.isEmpty ? null : note,
      );
    } catch (_) {
      return null;
    }
  }
}
