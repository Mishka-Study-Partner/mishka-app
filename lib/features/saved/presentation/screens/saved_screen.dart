import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/layout/app_scale.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';
import 'package:mishka_app/features/saved/presentation/screens/saved_category_list_screen.dart';
import 'package:mishka_app/features/saved/presentation/widgets/saved_library_mishka_card.dart';
import 'package:mishka_app/generated/assets.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import '../../../../core/widgets/custom_app_bar.dart';

/// Hub: four category cards. Tap **image/title** to show only that card; tap it again to show all four.
/// Tap **View** to open the full saved list for that category.
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  /// `null` → show all hub cards. Otherwise only that category’s card is visible.
  SavedContentKind? _filterKind;

  void _onHubSurfaceTapped(SavedContentKind kind) {
    setState(() {
      if (_filterKind == kind) {
        _filterKind = null;
      } else {
        _filterKind = kind;
      }
    });
  }

  List<_HubItem> _visibleHubs(AppLocalizations l10n) {
    final hubs = <_HubItem>[
      _HubItem(
        kind: SavedContentKind.flashcards,
        title: l10n.savedFlashCards,
        fallbackImage: Assets.imagesSavedCard1,
        imageLeft: true,
      ),
      _HubItem(
        kind: SavedContentKind.quiz,
        title: l10n.savedQuizzes,
        fallbackImage: Assets.imagesSavedCard2,
        imageLeft: false,
      ),
      _HubItem(
        kind: SavedContentKind.summary,
        title: l10n.savedSummary,
        fallbackImage: Assets.imagesSavedCard1,
        imageLeft: true,
      ),
      _HubItem(
        kind: SavedContentKind.mindmap,
        title: l10n.savedMindMap,
        fallbackImage: Assets.imagesSavedCard3,
        imageLeft: false,
      ),
    ];

    if (_filterKind == null) {
      return hubs;
    }
    return hubs.where((h) => h.kind == _filterKind).toList();
  }

  /// Split available list height evenly across cards on tablet only.
  double? _tabletCardHeight(
    BuildContext context,
    double viewportHeight,
    int cardCount,
  ) {
    if (!AppBreakpoints.isTablet(context) || cardCount == 0) return null;

    final separatorTotal = AppScale.h(12) * (cardCount - 1);
    final scrollPadding = AppSizes.screenEndPadding * 2;
    final available = viewportHeight - separatorTotal - scrollPadding;
    return (available / cardCount).clamp(AppScale.h(140), AppScale.h(240));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visible = _visibleHubs(l10n);
    final horizontal = AppBreakpoints.horizontalPadding(context, base: 20);
    final isTablet = AppBreakpoints.isTablet(context);

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.saved,
        showBack: false,
        showBottomBar: false,
        topTitle: l10n.saved,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final tabletHeight = _tabletCardHeight(
            context,
            constraints.maxHeight,
            visible.length,
          );

          return ListView.separated(
            padding: AppScrollInsets.page(
              horizontal: AppScale.w(horizontal),
              top: 12.h,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: visible.length + 1,
            separatorBuilder: (_, __) => SizedBox(
              height: isTablet ? AppScale.h(12) : 12.h,
            ),
            itemBuilder: (context, index) {
              if (index == visible.length) {
                return const ScreenEndSpacer();
              }
              final item = visible[index];
              return SavedLibraryMishkaCard(
                title: item.title,
                primaryImageAsset:
                    SavedLibraryMishkaCard.prototypePrimaryAsset(item.kind),
                fallbackImageAsset: item.fallbackImage,
                imageLeft: item.imageLeft,
                actionLabel: l10n.view,
                tabletCardHeight: tabletHeight,
                onSurfaceTap: () => _onHubSurfaceTapped(item.kind),
                onView: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => SavedCategoryListScreen(kind: item.kind),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _HubItem {
  const _HubItem({
    required this.kind,
    required this.title,
    required this.fallbackImage,
    required this.imageLeft,
  });

  final SavedContentKind kind;
  final String title;
  final String fallbackImage;
  final bool imageLeft;
}
