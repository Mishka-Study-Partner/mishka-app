import 'package:flutter/material.dart';

class StudentSubjectModel {
  const StudentSubjectModel({
    required this.id,
    required this.name,
    required this.color,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String color;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Color get displayColor {
    final hex = color.replaceFirst('#', '');
    if (hex.length == 6) {
      final value = int.tryParse(hex, radix: 16);
      if (value != null) return Color(0xFF000000 | value);
    }
    return const Color(0xFF4E7DBA);
  }

  StudentSubjectModel copyWith({
    String? name,
    String? color,
    int? sortOrder,
  }) {
    return StudentSubjectModel(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory StudentSubjectModel.fromJson(Map<String, dynamic> json) {
    return StudentSubjectModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      color: (json['color'] ?? '#4E7DBA').toString(),
      sortOrder: _parseInt(json['sortOrder']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'name': name.trim(),
        'color': color,
      };

  Map<String, dynamic> toUpdateJson() => {
        'name': name.trim(),
        'color': color,
      };

  static int _parseInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }
}
