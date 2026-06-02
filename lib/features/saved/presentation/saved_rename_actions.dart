import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/saved/data/repositories/saved_repository.dart';
import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

Future<bool> showRenameSavedItemDialog({
  required BuildContext context,
  required SavedRepository repository,
  required SavedContentKind kind,
  required String entityId,
  required String currentTitle,
}) async {
  final l10n = AppLocalizations.of(context)!;
  if (entityId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.savedRenameUnavailable)),
    );
    return false;
  }

  final controller = TextEditingController(text: currentTitle);
  final newTitle = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
        child: Container(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.renameSavedItem,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: AppSizes.fontSizeLarge,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainDark,
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.savedItemTitleHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final value = controller.text.trim();
                        if (value.isEmpty) return;
                        Navigator.pop(dialogContext, value);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainGold,
                      ),
                      child: Text(l10n.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  if (newTitle == null || newTitle.trim().isEmpty || newTitle == currentTitle) {
    return false;
  }

  try {
    await repository.renameTutorEntity(
      kind: kind,
      entityId: entityId,
      title: newTitle.trim(),
    );
    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.savedItemRenamed)),
    );
    return true;
  } catch (e) {
    if (!context.mounted) return false;
    final message = e is ApiException ? e.message : e.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${l10n.errorPrefix}: $message')),
    );
    return false;
  }
}
