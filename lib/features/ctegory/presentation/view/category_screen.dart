import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/ctegory/data/models/category_api_model.dart';
import 'package:mishka_app/features/ctegory/data/repositories/category_repository.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/generated/assets.dart';
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
    if (t.contains('game')) return CategoryScreenType.gamefaction;
    if (t.contains('todo') || t.contains('to do')) return null;
    return null;
  }

  String _imageForCategory(String text) {
    final t = text.toLowerCase();
    if (t.contains('ai')) return Assets.imagesAiTools;
    if (t.contains('study')) return Assets.imagesStudyWithMe;
    if (t.contains('communit')) return Assets.imagesOurCommunity;
    if (t.contains('todo') || t.contains('to do')) return Assets.imagesToDoList;
    if (t.contains('game')) return Assets.imagesGamification;
    return Assets.imagesAiTools;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const MishkaAppBar(
        title: "",
        showBack: true,
        showBottomBar: false,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _categories.isEmpty
                ? [
                    SectionCard(
                      imagePath: Assets.imagesAiTools,
                      title: l10n.aiTools,
                      subtitle: l10n.aiToolsSubtitle,
                      onTap: () => widget.onNavigate(CategoryScreenType.aiTools),
                    ),
                    SizedBox(height: 12.h),
                    SectionCard(
                      imagePath: Assets.imagesStudyWithMe,
                      title: l10n.studyWithMe,
                      subtitle: l10n.studyWithMeSubtitle,
                      onTap: () => widget.onNavigate(CategoryScreenType.studyWithMe),
                    ),
                    SizedBox(height: 12.h),
                    SectionCard(
                      imagePath: Assets.imagesOurCommunity,
                      title: l10n.ourCommunity,
                      subtitle: l10n.ourCommunitySubtitle,
                      onTap: () => widget.onNavigate(CategoryScreenType.ourCommunity),
                    ),
                    SizedBox(height: 12.h),
                    SectionCard(
                      imagePath: Assets.imagesToDoList,
                      title: l10n.toDoList,
                      subtitle: l10n.yourToDoList,
                      onTap: () => widget.onTabSwitch?.call(MainTab.todo),
                    ),
                    SizedBox(height: 12.h),
                    SectionCard(
                      imagePath: Assets.imagesGamification,
                      title: l10n.gamification,
                      subtitle: l10n.gamificationSubtitle,
                      onTap: () => widget.onNavigate(CategoryScreenType.gamefaction),
                    ),
                  ]
                : _categories.map((category) {
                    final route = _routeForCategory(category.title);
                    return SectionCard(
                      imagePath: _imageForCategory(category.title),
                      title: category.title,
                      subtitle: category.subtitle ?? '',
                      onTap: () {
                        if (route != null) {
                          widget.onNavigate(route);
                          return;
                        }
                        widget.onTabSwitch?.call(MainTab.todo);
                      },
                      isSaved: _savedMap.containsKey(category.id),
                      onToggleSaved: () => _toggleSaved(category.id),
                    );
                  }).toList(),
          ),
        ),
      ),
    );
  }
}