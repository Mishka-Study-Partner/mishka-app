import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/app_bottom_sheet_layout.dart';
import 'package:mishka_app/features/our_community/data/community_channel_material_publisher.dart';
import 'package:mishka_app/features/our_community/data/community_models.dart';
import 'package:mishka_app/features/saved/data/repositories/saved_repository.dart';
import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../community_styles.dart';

class SavedMaterialPick {
  const SavedMaterialPick({
    required this.kind,
    required this.savedListItemId,
    required this.title,
  });

  final SavedContentKind kind;
  final String savedListItemId;
  final String title;
}

Future<void> shareSavedMaterialToChannel({
  required BuildContext context,
  required SavedRepository repository,
  required String communityId,
  required String channelId,
  List<CommunityChatMessage>? knownMessages,
  VoidCallback? onShared,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final picked = await showPickSavedMaterialSheet(context);
  if (picked == null || !context.mounted) return;

  try {
    await repository.shareSavedLibraryRow(
      kind: picked.kind,
      savedListRowId: picked.savedListItemId,
      channelIds: [channelId],
    );
    await ensureSavedRowMaterialPosted(
      repository: repository,
      kind: picked.kind,
      savedListRowId: picked.savedListItemId,
      knownMessages: knownMessages,
      targets: [
        (communityId: communityId, channelId: channelId),
      ],
    );
    if (!context.mounted) return;
    CommunityStyles.showSnackBar(
      context,
      '"${picked.title}" shared to the group.',
    );
    onShared?.call();
  } catch (e) {
    if (!context.mounted) return;
    final message = e is ApiException ? e.message : e.toString();
    CommunityStyles.showSnackBar(context, '${l10n.errorPrefix}: $message');
  }
}

Future<SavedMaterialPick?> showPickSavedMaterialSheet(BuildContext context) {
  return showModalBottomSheet<SavedMaterialPick>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => AppBottomSheetLayout.wrap(
      ctx,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : MediaQuery.sizeOf(context).height * 0.88;
          return SizedBox(
            height: maxHeight,
            child: Material(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusMedium),
              ),
              clipBehavior: Clip.antiAlias,
              child: const _PickSavedMaterialSheet(),
            ),
          );
        },
      ),
    ),
  );
}

class _PickSavedMaterialSheet extends StatefulWidget {
  const _PickSavedMaterialSheet();

  @override
  State<_PickSavedMaterialSheet> createState() => _PickSavedMaterialSheetState();
}

class _PickSavedMaterialSheetState extends State<_PickSavedMaterialSheet> {
  final _repository = SavedRepository();
  SavedContentKind? _selectedKind;
  bool _loading = false;
  String? _error;
  List<SavedMaterialPick> _items = const [];

  String _kindLabel(SavedContentKind kind, AppLocalizations l10n) {
    return switch (kind) {
      SavedContentKind.flashcards => l10n.savedFlashCards,
      SavedContentKind.quiz => l10n.savedQuizes,
      SavedContentKind.summary => l10n.savedSummary,
      SavedContentKind.mindmap => l10n.savedMindMap,
    };
  }

  Future<void> _loadKind(SavedContentKind kind) async {
    setState(() {
      _selectedKind = kind;
      _loading = true;
      _error = null;
      _items = const [];
    });

    try {
      final items = switch (kind) {
        SavedContentKind.flashcards => (await _repository.getSavedFlashcardSets())
            .map(
              (row) => SavedMaterialPick(
                kind: kind,
                savedListItemId: row.savedRowId,
                title: row.title,
              ),
            )
            .toList(),
        SavedContentKind.quiz => (await _repository.getSavedQuizzes())
            .map(
              (row) => SavedMaterialPick(
                kind: kind,
                savedListItemId: row.savedRowId,
                title: row.title,
              ),
            )
            .toList(),
        SavedContentKind.summary => (await _repository.getSavedSummaries())
            .map(
              (row) => SavedMaterialPick(
                kind: kind,
                savedListItemId: row.savedRowId,
                title: row.title,
              ),
            )
            .toList(),
        SavedContentKind.mindmap => (await _repository.getSavedMindMaps())
            .map(
              (row) => SavedMaterialPick(
                kind: kind,
                savedListItemId: row.savedRowId,
                title: row.title,
              ),
            )
            .toList(),
      };

      if (!mounted) return;
      setState(() {
        _items = items.where((item) => item.savedListItemId.isNotEmpty).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e is ApiException ? e.message : e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final kinds = SavedContentKind.values;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.shareToCommunityChannels,
                  style: CommunityStyles.sectionLabel,
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.communityShareChooseMaterial,
                  style: CommunityStyles.caption,
                ),
                SizedBox(height: 12.h),
                if (_selectedKind == null)
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: kinds
                        .map(
                          (kind) => ActionChip(
                            label: Text(_kindLabel(kind, l10n)),
                            onPressed: () => _loadKind(kind),
                          ),
                        )
                        .toList(),
                  )
                else
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() {
                          _selectedKind = null;
                          _items = const [];
                          _error = null;
                        }),
                        icon: const Icon(Icons.arrow_back),
                        color: AppColors.mainGold,
                      ),
                      Expanded(
                        child: Text(
                          _kindLabel(_selectedKind!, l10n),
                          style: CommunityStyles.bodySemiBold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (_selectedKind != null) ...[
            SizedBox(height: 8.h),
            if (_loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: CommunityStyles.error,
                    ),
                  ),
                ),
              )
            else if (_items.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      l10n.communityShareNoSavedInCategory,
                      textAlign: TextAlign.center,
                      style: CommunityStyles.caption,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 16.h),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: AppColors.stroke),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return ListTile(
                      title: Text(item.title, style: CommunityStyles.body),
                      trailing:
                          Icon(Icons.share_outlined, color: AppColors.mainGold),
                      onTap: () => Navigator.pop(context, item),
                    );
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }
}
