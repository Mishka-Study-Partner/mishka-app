import 'package:flutter/material.dart';
import 'dart:ui';

class TodoListItemModel {
  final String id;
  final String title;
  final IconData icon;
  final Color iconColor;

  TodoListItemModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.iconColor,
  });
}
