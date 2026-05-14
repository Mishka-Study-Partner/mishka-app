import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';
import 'package:mishka_app/features/saved/presentation/screens/saved_category_list_screen.dart';
import 'package:mishka_app/features/saved/presentation/widgets/saved_library_mishka_card.dart';
import 'package:mishka_app/generated/assets.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import '../../../../core/widgets/custom_app_bar.dart';

/// Hub: four category cards. Tap **image/title** to show only that card; tap it again to show all four.
/// Tap **View** to open the full saved list for that category.
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  static const _hubBodyPadding = 20.0;

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
        title: l10n.savedQuizes,
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
        title: l10n.mindMap,
        fallbackImage: Assets.imagesSavedCard3,
        imageLeft: false,
      ),
    ];

    if (_filterKind == null) {
      return hubs;
    }
    return hubs.where((h) => h.kind == _filterKind).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visible = _visibleHubs(l10n);

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.saved,
        showBack: false,
        showBottomBar: false,
        topTitle: l10n.saved,
      ),
      body: ListView(
        padding: EdgeInsets.all(SavedScreen._hubBodyPadding.w),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0) SizedBox(height: 20.h),
            SavedLibraryMishkaCard(
              title: visible[i].title,
              primaryImageAsset:
                  SavedLibraryMishkaCard.prototypePrimaryAsset(visible[i].kind),
              fallbackImageAsset: visible[i].fallbackImage,
              imageLeft: visible[i].imageLeft,
              actionLabel: l10n.view,
              onSurfaceTap: () => _onHubSurfaceTapped(visible[i].kind),
              onView: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        SavedCategoryListScreen(kind: visible[i].kind),
                  ),
                );
              },
            ),
          ],
        ],
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
