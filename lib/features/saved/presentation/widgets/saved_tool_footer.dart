import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_focus_metrics.dart';
import 'package:mishka_app/features/saved/presentation/widgets/saved_created_at.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Compact done button + optional created-at row for saved tool play screens.
class SavedToolFooter extends StatelessWidget {
  const SavedToolFooter({
    super.key,
    required this.onDone,
    this.createdAt,
    this.showDoneButton = true,
  });

  final VoidCallback onDone;
  final DateTime? createdAt;
  final bool showDoneButton;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final createdParts = splitSavedCreatedAt(createdAt, locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDoneButton) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onDone,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.mainGold,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: ToolFocusMetrics.doneButtonVerticalPad(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: Text(
                l10n.done,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: ToolFocusMetrics.doneButtonFontSize(context),
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
              ),
            ),
          ),
        ],
        if (createdParts != null) ...[
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.savedCreatedOnDate(createdParts.$1),
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: ToolFocusMetrics.footerMetaSize(context),
                    color: const Color(0xFFD4845A),
                  ),
                ),
              ),
              Text(
                createdParts.$2,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: ToolFocusMetrics.footerMetaSize(context),
                  color: const Color(0xFFD4845A),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
