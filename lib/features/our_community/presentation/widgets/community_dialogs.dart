import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/button_label.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_styles.dart';
import '../../data/community_error_helpers.dart';
import '../../data/community_models.dart';

Future<bool?> showCommunityConfirmDialog(
  BuildContext context, {
  required String message,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => CommunityConfirmDialog(message: message),
  );
}

class CommunityConfirmDialog extends StatelessWidget {
  const CommunityConfirmDialog({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center, style: CommunityStyles.body),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionChip(
                  label: l10n.no,
                  color: AppColors.green,
                  onTap: () => Navigator.pop(context, false),
                ),
                SizedBox(width: 10.w),
                _ActionChip(
                  label: l10n.yes,
                  color: AppColors.red,
                  onTap: () => Navigator.pop(context, true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Text(
          label,
          style: CommunityStyles.body.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

Future<void> showCommunitySuccessDialog(
  BuildContext context, {
  required String message,
  VoidCallback? onDismiss,
  bool barrierDismissible = true,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => CommunitySuccessDialog(
      message: message,
      onDismiss: onDismiss,
    ),
  );
}

class CommunitySuccessDialog extends StatelessWidget {
  const CommunitySuccessDialog({
    super.key,
    required this.message,
    this.onDismiss,
  });

  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_outlined, size: 60.w, color: AppColors.green),
            SizedBox(height: 16.h),
            Text(message, textAlign: TextAlign.center, style: CommunityStyles.successMessage),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDismiss?.call();
                },
                style: CommunityStyles.goldButtonStyle(verticalPadding: 12.h),
                child: ButtonLabel(
                  l10n.ok,
                  style: CommunityStyles.bodyLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showJoinPrivateCommunityDialog(
  BuildContext context, {
  required Future<CommunityModel> Function(String code) onJoin,
  required void Function(CommunityModel community) onSuccess,
}) {
  final controller = TextEditingController();
  var submitting = false;

  final l10n = AppLocalizations.of(context)!;

  return showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.communityJoinPrivateTitle,
                  style: CommunityStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10.h),
                Text(l10n.communityJoinPrivateCodePrompt, style: CommunityStyles.body),
                SizedBox(height: 8.h),
                TextField(
                  controller: controller,
                  decoration: CommunityStyles.inputDecoration(
                    l10n.communityJoinPrivateCodeHint,
                  ),
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: CommunityStyles.goldButtonStyle(),
                    onPressed: submitting
                        ? null
                        : () async {
                            final code = controller.text.trim();
                            if (code.isEmpty) return;
                            setState(() => submitting = true);
                            try {
                              final community = await onJoin(code);
                              if (!context.mounted) return;
                              Navigator.pop(ctx);
                              await showCommunitySuccessDialog(
                                context,
                                message: l10n.communityJoinPrivateSuccess,
                                onDismiss: () => onSuccess(community),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              CommunityStyles.showSnackBar(
                                context,
                                communityErrorMessage(e, l10n: l10n),
                              );
                              setState(() => submitting = false);
                            }
                          },
                    child: submitting
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : ButtonLabel(
                            l10n.communityJoinPrivateButton,
                            style: CommunityStyles.bodyLarge.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
