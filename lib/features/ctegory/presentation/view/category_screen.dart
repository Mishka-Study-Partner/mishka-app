import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/layout/app_scale.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/ctegory/data/models/category_api_model.dart';
import 'package:mishka_app/features/ctegory/data/repositories/category_repository.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/generated/assets.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../main.dart';
import '../widgets/category_section_card.dart';

class CategoryScreen extends StatefulWidget {
  final void Function(CategoryScreenType) onNavigate;
  final void Function(MainTab)? onTabSwitch;

  const CategoryScreen({
    super.key,
    required this.onNavigate,
    this.onTabSwitch,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryRepository _repository = CategoryRepository();
  List<CategoryApiModel> _categories = const [];
  Map<String, String> _savedMap = const {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _repository.getCategories();
      final saved = await _repository.getSavedCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _savedMap = {for (final s in saved) s.categoryId: s.id};
      });
    } catch (_) {
      // Keep default static fallback cards on failure.
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleSaved(String categoryId) async {
    final savedId = _savedMap[categoryId];
    try {
      if (savedId == null) {
        final created = await _repository.saveCategory(categoryId: categoryId);
        if (created != null && mounted) {
          setState(() {
            _savedMap = {..._savedMap, categoryId: created.id};
          });
        }
      } else {
        await _repository.removeSavedCategory(savedRowId: savedId);
        if (mounted) {
          final next = {..._savedMap};
          next.remove(categoryId);
          setState(() => _savedMap = next);
        }
      }
    } catch (_) {
      // Do not interrupt navigation flow for save toggle errors.
    }
  }

  CategoryScreenType? _routeForCategory(String text) {
    final t = text.toLowerCase();
    if (t.contains('ai')) return CategoryScreenType.aiTools;
    if (t.contains('study')) return CategoryScreenType.studyWithMe;
    if (t.contains('communit')) return CategoryScreenType.ourCommunity;
    if (t.contains('progress') || t.contains('report')) {
      return CategoryScreenType.myProgress;
    }
    if (t.contains('gamification') || t.contains('game')) {
      return CategoryScreenType.gamification;
    }
    if (t.contains('todo') || t.contains('to do')) return null;
    return null;
  }

  String _imageForCategory(String text) {
    final t = text.toLowerCase();
    if (t.contains('ai')) return Assets.imagesAiTools;
    if (t.contains('study')) return Assets.imagesStudyWithMe;
    if (t.contains('communit')) return Assets.imagesOurCommunity;
    if (t.contains('todo') || t.contains('to do')) return Assets.imagesToDoList;
    if (t.contains('progress') || t.contains('report')) {
      return Assets.imagesProgressReport;
    }
    if (t.contains('gamification') || t.contains('game')) {
      return Assets.imagesGamification;
    }
    return Assets.imagesAiTools;
  }

  String _displayTitle(
    String title,
    AppLocalizations l10n,
    CategoryScreenType? route,
  ) {
    if (route == CategoryScreenType.myProgress) return l10n.myProgress;
    if (route == CategoryScreenType.gamification) return l10n.gamification;
    return title;
  }

  String _displaySubtitle(
    String title,
    String? subtitle,
    AppLocalizations l10n,
    CategoryScreenType? route,
  ) {
    if (route == CategoryScreenType.myProgress) return l10n.myProgressSubtitle;
    if (route == CategoryScreenType.gamification) {
      return l10n.gamificationSubtitle;
    }
    return subtitle ?? '';
  }

  List<_CategoryEntry> _progressAndGamificationEntries(AppLocalizations l10n) {
    return [
      _CategoryEntry(
        imagePath: Assets.imagesProgressReport,
        title: l10n.myProgress,
        subtitle: l10n.myProgressSubtitle,
        route: CategoryScreenType.myProgress,
        onTap: () => widget.onNavigate(CategoryScreenType.myProgress),
      ),
      _CategoryEntry(
        imagePath: Assets.imagesGamification,
        title: l10n.gamification,
        subtitle: l10n.gamificationSubtitle,
        route: CategoryScreenType.gamification,
        onTap: () => widget.onNavigate(CategoryScreenType.gamification),
      ),
    ];
  }

  List<_CategoryEntry> _entries(AppLocalizations l10n) {
    if (_categories.isEmpty) {
      return [
        _CategoryEntry(
          imagePath: Assets.imagesAiTools,
          title: l10n.aiTools,
          subtitle: l10n.aiToolsSubtitle,
          onTap: () => widget.onNavigate(CategoryScreenType.aiTools),
        ),
        _CategoryEntry(
          imagePath: Assets.imagesStudyWithMe,
          title: l10n.studyWithMe,
          subtitle: l10n.studyWithMeSubtitle,
          onTap: () => widget.onNavigate(CategoryScreenType.studyWithMe),
        ),
        _CategoryEntry(
          imagePath: Assets.imagesOurCommunity,
          title: l10n.ourCommunity,
          subtitle: l10n.ourCommunitySubtitle,
          onTap: () => widget.onNavigate(CategoryScreenType.ourCommunity),
        ),
        _CategoryEntry(
          imagePath: Assets.imagesToDoList,
          title: l10n.toDoList,
          subtitle: l10n.yourToDoList,
          onTap: () => widget.onTabSwitch?.call(MainTab.todo),
        ),
        ..._progressAndGamificationEntries(l10n),
      ];
    }

    final entries = <_CategoryEntry>[];
    final seenRoutes = <CategoryScreenType>{};

    for (final category in _categories) {
      final route = _routeForCategory(category.title);
      if (route != null) seenRoutes.add(route);
      entries.add(
        _CategoryEntry(
          imagePath: _imageForCategory(category.title),
          title: _displayTitle(category.title, l10n, route),
          subtitle: _displaySubtitle(
            category.title,
            category.subtitle,
            l10n,
            route,
          ),
          onTap: () {
            if (route != null) {
              widget.onNavigate(route);
              return;
            }
            widget.onTabSwitch?.call(MainTab.todo);
          },
          isSaved: _savedMap.containsKey(category.id),
          onToggleSaved: () => _toggleSaved(category.id),
        ),
      );
    }

    if (!seenRoutes.contains(CategoryScreenType.myProgress) ||
        !seenRoutes.contains(CategoryScreenType.gamification)) {
      for (final entry in _progressAndGamificationEntries(l10n)) {
        final route = entry.route;
        if (route != null && seenRoutes.contains(route)) continue;
        entries.add(entry);
      }
    }

    return entries;
  }

  /// Split available list height evenly across cards on tablet only.
  double? _tabletCardHeight(
    BuildContext context,
    double viewportHeight,
    int cardCount,
  ) {
    if (!AppBreakpoints.isTablet(context) || cardCount == 0) return null;

    final separatorTotal = 6.h * (cardCount - 1);
    final scrollPadding = AppSizes.screenEndPadding * 2;
    final available = viewportHeight - separatorTotal - scrollPadding;
    return (available / cardCount).clamp(AppScale.h(120), AppScale.h(220));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = _entries(l10n);
    final horizontal = AppBreakpoints.horizontalPadding(context, base: 16);

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const MishkaAppBar(
        title: '',
        showBack: true,
        showBottomBar: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final tabletHeight = _tabletCardHeight(
                  context,
                  constraints.maxHeight,
                  entries.length,
                );

                return ListView.separated(
                  padding: AppScrollInsets.page(
                    horizontal: AppScale.w(horizontal),
                    top: 12.h,
                  ),
                  itemCount: entries.length + 1,
                  separatorBuilder: (_, __) => SizedBox(height: 6.h),
                  itemBuilder: (context, index) {
                    if (index == entries.length) {
                      return const ScreenEndSpacer();
                    }
                    final entry = entries[index];
                    return SectionCard(
                      imagePath: entry.imagePath,
                      title: entry.title,
                      subtitle: entry.subtitle,
                      onTap: entry.onTap,
                      isSaved: entry.isSaved,
                      onToggleSaved: entry.onToggleSaved,
                      tabletCardHeight: tabletHeight,
                    );
                  },
                );
              },
            ),
    );
  }
}

class _CategoryEntry {
  const _CategoryEntry({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.route,
    this.isSaved = false,
    this.onToggleSaved,
  });

  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final CategoryScreenType? route;
  final bool isSaved;
  final VoidCallback? onToggleSaved;
}
