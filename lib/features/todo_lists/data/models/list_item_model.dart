import 'package:flutter/material.dart';
import 'dart:ui';

class TodoListItemModel {
  final String title;
  final IconData icon;
  final Color iconColor;

  TodoListItemModel({
    required this.title,
    required this.icon,
    required this.iconColor,
  });
}
