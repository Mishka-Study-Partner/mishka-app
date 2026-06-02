import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_styles.dart';
import '../../data/community_discover_models.dart';

class CommunityDiscoveryFields extends StatelessWidget {
  const CommunityDiscoveryFields({
    super.key,
    required this.categories,
    required this.selectedSubjectKeys,
    required this.selectedPurposeKey,
    required this.onSubjectsChanged,
    required this.onPurposeChanged,
    this.profileEducationHint,
  });

  final DiscoverCategories? categories;
  final Set<String> selectedSubjectKeys;
  final String? selectedPurposeKey;
  final ValueChanged<Set<String>> onSubjectsChanged;
  final ValueChanged<String?> onPurposeChanged;
  final String? profileEducationHint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subjects = (categories?.subjects ?? [])
        .where((c) => c.communityCount > 0 || c.key == 'general')
        .toList();
    final purposes = categories?.purposes ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (profileEducationHint != null && profileEducationHint!.isNotEmpty) ...[
          Text(profileEducationHint!, style: CommunityStyles.caption),
          SizedBox(height: 10.h),
        ],
        if (subjects.isNotEmpty) ...[
          Text(l10n.communityDiscoverySubjectsOptional, style: CommunityStyles.sectionLabel),
          SizedBox(height: 6.h),
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
          SizedBox(height: 14.h),
        ],
        if (purposes.isNotEmpty) ...[
          Text(l10n.communityDiscoveryPurposeOptional, style: CommunityStyles.sectionLabel),
          SizedBox(height: 6.h),
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
    );
  }
}
