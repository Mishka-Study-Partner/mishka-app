import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/chat_with_mishka/data/data_sources/saved_library_remote_data_source.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Picks community channels to share a **saved library** row (same flow as AI tools).
Future<List<CommunityChannel>?> showSavedShareChannelsDialog({
  required BuildContext context,
  required List<CommunityChannel> channels,
}) {
  final l10n = AppLocalizations.of(context)!;
  final selected = <String>{};

  return showDialog<List<CommunityChannel>>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingLarge,
            ),
            child: Container(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                border: Border.all(color: AppColors.stroke),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.shareToCommunityChannels,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: AppSizes.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainDark,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 260.h),
                    child: ListView(
                      shrinkWrap: true,
                      children: channels.map((channel) {
                        final checked = selected.contains(channel.id);
                        return InkWell(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSmall,
                          ),
                          onTap: () {
                            setDialogState(() {
                              if (checked) {
                                selected.remove(channel.id);
                              } else {
                                selected.add(channel.id);
                              }
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: Row(
                              children: [
                                Icon(
                                  checked
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: checked
                                      ? AppColors.mainGold
                                      : AppColors.stroke,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    channel.name,
                                    style: TextStyle(
                                      fontFamily: 'Pridi',
                                      fontSize: AppSizes.fontSizeMedium,
                                      color: AppColors.mainDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.stroke),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSmall,
                              ),
                            ),
                          ),
                          child: Text(
                            l10n.cancel,
                            style: TextStyle(
                              fontFamily: 'Pridi',
                              color: AppColors.mainDark,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selected.isEmpty
                              ? null
                              : () {
                                  Navigator.pop(
                                    dialogContext,
                                    channels
                                        .where(
                                          (c) => selected.contains(c.id),
                                        )
                                        .toList(),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainGold,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSmall,
                              ),
                            ),
                          ),
                          child: Text(
                            l10n.share,
                            style: TextStyle(
                              fontFamily: 'Pridi',
                              color: AppColors.white,
                            ),
                          ),
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
    },
  );
}
