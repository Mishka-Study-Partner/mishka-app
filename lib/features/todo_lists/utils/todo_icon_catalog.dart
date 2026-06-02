import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/features/todo_lists/data/models/icon_api_model.dart';


class TodoIconOption {
  const TodoIconOption({
    this.id,
    required this.iconify,
    required this.color,
    required this.label,
    this.imageUrl,
  });

  /// Backend `icons.id`; null for local-only library icons.
  final int? id;
  final String iconify;
  final Color color;
  final String label;
  final String? imageUrl;

  static const defaultOption = TodoIconOption(
    id: null,
    iconify: Mdi.format_list_bulleted,
    color: AppColors.mainGold,
    label: 'list',
  );
}

class TodoIconCatalog {
  TodoIconCatalog._();

  static const _fallback = [
    TodoIconOption(id: null, iconify: Mdi.briefcase, color: AppColors.mainGold, label: 'work'),
    TodoIconOption(id: null, iconify: Mdi.school, color: AppColors.blue, label: 'school'),
    TodoIconOption(id: null, iconify: Mdi.account, color: AppColors.green, label: 'personal'),
    TodoIconOption(id: null, iconify: Mdi.heart, color: AppColors.red, label: 'favorite'),
    TodoIconOption(id: null, iconify: Mdi.folder, color: AppColors.mainDark, label: 'folder'),
    TodoIconOption(id: null, iconify: Mdi.book, color: AppColors.blue, label: 'book'),
    TodoIconOption(id: null, iconify: Mdi.calendar, color: AppColors.mainGold, label: 'calendar'),
    TodoIconOption(id: null, iconify: Mdi.pencil, color: AppColors.green, label: 'notes'),
    TodoIconOption(id: null, iconify: Mdi.lightbulb, color: AppColors.mainGold, label: 'ideas'),
    TodoIconOption(id: null, iconify: Mdi.star, color: AppColors.red, label: 'star'),
    TodoIconOption(id: null, iconify: Mdi.music, color: AppColors.blue, label: 'music'),
    TodoIconOption(id: null, iconify: Mdi.run, color: AppColors.green, label: 'fitness'),
  ];

  static List<TodoIconOption> fromApi(List<IconApiModel> icons) {
    return icons
        .map(
          (icon) => TodoIconOption(
            id: icon.id,
            iconify: _iconifyForName(icon.iconName),
            color: _colorForName(icon.iconName),
            label: icon.iconName,
            imageUrl: _resolveImageUrl(icon.iconPath),
          ),
        )
        .toList();
  }

  /// API icons when available; otherwise a rich Iconify library set.
  static List<TodoIconOption> merge(List<IconApiModel> apiIcons) {
    final apiOptions = fromApi(apiIcons);
    if (apiOptions.isNotEmpty) return apiOptions;
    return List<TodoIconOption>.from(_fallback);
  }

  static Map<int, TodoIconOption> indexById(List<TodoIconOption> options) {
    return {
      for (final option in options)
        if (option.id != null) option.id!: option,
    };
  }

  static TodoIconOption resolve({
    required int? iconId,
    required Map<int, TodoIconOption> byId,
  }) {
    if (iconId != null && byId.containsKey(iconId)) {
      return byId[iconId]!;
    }
    return TodoIconOption.defaultOption;
  }

  static String _iconifyForName(String name) {
    return switch (name.toLowerCase()) {
      'book' => Mdi.book,
      'calendar' => Mdi.calendar,
      'work' || 'briefcase' => Mdi.briefcase,
      'school' || 'education' => Mdi.school,
      'personal' || 'user' || 'account' => Mdi.account,
      'heart' || 'favorite' => Mdi.heart,
      'folder' => Mdi.folder,
      'music' => Mdi.music,
      'star' => Mdi.star,
      'pencil' || 'notes' => Mdi.pencil,
      'lightbulb' || 'ideas' => Mdi.lightbulb,
      'run' || 'fitness' => Mdi.run,
      'home' => Mdi.home,
      'cart' || 'shopping' => Mdi.cart,
      _ => Mdi.tag,
    };
  }

  static Color _colorForName(String name) {
    final palette = [
      AppColors.mainGold,
      AppColors.blue,
      AppColors.green,
      AppColors.red,
      AppColors.mainDark,
    ];
    return palette[name.hashCode.abs() % palette.length];
  }

  static String? _resolveImageUrl(String? iconPath) {
    if (iconPath == null || iconPath.isEmpty) return null;
    if (iconPath.startsWith('http')) return iconPath;
    final base = ApiEndpoints.baseUrl.replaceAll(RegExp(r'/$'), '');
    final path = iconPath.startsWith('/') ? iconPath : '/$iconPath';
    return '$base$path';
  }
}
