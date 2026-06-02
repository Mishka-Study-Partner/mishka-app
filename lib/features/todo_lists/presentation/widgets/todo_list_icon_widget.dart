import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:mishka_app/features/todo_lists/utils/todo_icon_catalog.dart';

class TodoListIconWidget extends StatelessWidget {
  const TodoListIconWidget({
    super.key,
    required this.option,
    this.size = 22,
  });

  final TodoIconOption option;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = option.imageUrl;
    if (url != null && url.isNotEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Iconify(
            option.iconify,
            color: option.color,
            size: size,
          ),
        ),
      );
    }
    return Iconify(option.iconify, color: option.color, size: size);
  }
}
