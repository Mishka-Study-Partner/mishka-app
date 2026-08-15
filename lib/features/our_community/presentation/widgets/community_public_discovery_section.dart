import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_styles.dart';
import '../../data/community_discover_models.dart';
import '../../data/community_repository.dart';
import 'community_category_field.dart';

/// Public community discover options: category (free text / suggestions), subjects, purpose.
class CommunityPublicDiscoverySection extends StatelessWidget {
  const CommunityPublicDiscoverySection({
    super.key,
    required this.repository,
    required this.categoryController,
    required this.categoryTitles,
    required this.categories,
    required this.loadingDiscover,
    required this.selectedSubjectKeys,
    required this.selectedPurposeKey,
    required this.onSubjectsChanged,
    required this.onPurposeChanged,
    this.profileEducationHint,
  });

  final CommunityRepository repository;
  final TextEditingController categoryController;
  final List<CommunityCategoryTitle> categoryTitles;
  final DiscoverCategories? categories;
  final bool loadingDiscover;
  final Set<String> selectedSubjectKeys;
  final String? selectedPurposeKey;
  final ValueChanged<Set<String>> onSubjectsChanged;
  final ValueChanged<String?> onPurposeChanged;
  final String? profileEducationHint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final discover = categories ?? const DiscoverCategories();
    final subjects = discover.subjects;
    final purposes = discover.purposes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.communityCreateDiscoverSection,
          style: CommunityStyles.sectionLabel,
        ),
        SizedBox(height: 6.h),
        Text(
          l10n.communityCreateDiscoverSubtitle,
          style: CommunityStyles.caption,
        ),
        SizedBox(height: 16.h),
        CommunityCategoryField(
          key: ValueKey('public-category-${categoryTitles.length}'),
          repository: repository,
          controller: categoryController,
          initialTitles: categoryTitles,
        ),
        SizedBox(height: 20.h),
        if (profileEducationHint != null && profileEducationHint!.isNotEmpty) ...[
          Text(profileEducationHint!, style: CommunityStyles.caption),
          SizedBox(height: 10.h),
        ],
        if (loadingDiscover)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else ...[
          if (subjects.isNotEmpty) ...[
            Text(
              l10n.communityDiscoverySubjectsOptional,
              style: CommunityStyles.sectionLabel,
            ),
            SizedBox(height: 6.h),
            Text(l10n.communityDiscoverySubjectsHelper, style: CommunityStyles.caption),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: subjects.map((chip) {
                final selected = selectedSubjectKeys.contains(chip.key);
                return FilterChip(
                  label: Text(chip.label),
                  selected: selected,
                  onSelected: (value) {
                    final next = Set<String>.from(selectedSubjectKeys);
                    if (value) {
                      if (next.length < 8) next.add(chip.key);
                    } else {
                      next.remove(chip.key);
                    }
                    onSubjectsChanged(next);
                  },
                  selectedColor: AppColors.mainGold.withValues(alpha: 0.25),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
          ],
          if (purposes.isNotEmpty) ...[
            Text(
              l10n.communityDiscoveryPurposeOptional,
              style: CommunityStyles.sectionLabel,
            ),
            SizedBox(height: 6.h),
            Text(l10n.communityDiscoveryPurposeHelper, style: CommunityStyles.caption),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: purposes.map((chip) {
                final selected = selectedPurposeKey == chip.key;
                return FilterChip(
                  label: Text(chip.label),
                  selected: selected,
                  onSelected: (value) {
                    onPurposeChanged(value ? chip.key : null);
                  },
                  selectedColor: AppColors.mainGold.withValues(alpha: 0.25),
                );
              }).toList(),
            ),
          ],
        ],
      ],
    );
  }
}
