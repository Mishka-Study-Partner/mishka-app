import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/features/our_community/community_chat_layout_metrics.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';

import '../../community_styles.dart';
import '../../data/community_models.dart';
import 'community_shared_material_preview.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_preview_renderer.dart';

class CommunityChatBubble extends StatelessWidget {
  const CommunityChatBubble({
    super.key,
    required this.message,
    required this.senderLabel,
    this.senderRoleLabel,
    required this.isOwnMessage,
  });

  final CommunityChatMessage message;
  final String senderLabel;
  final String? senderRoleLabel;
  final bool isOwnMessage;

  bool get _alignLeft => message.isMishka || !isOwnMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Column(
        crossAxisAlignment:
            _alignLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Align(
              alignment:
                  _alignLeft ? Alignment.centerLeft : Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    senderLabel,
                    style: CommunityStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainDark,
                    ),
                  ),
                  if (senderRoleLabel != null && senderRoleLabel!.isNotEmpty) ...[
                    Text(
                      ' · ',
                      style: CommunityStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightText,
                      ),
                    ),
                    Text(
                      senderRoleLabel!,
                      style: CommunityStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.mainGold,
                      ),
                    ),
                  ],
                  if (message.timeLabel.isNotEmpty) ...[
                    SizedBox(width: 8.w),
                    Text(message.timeLabel, style: CommunityStyles.caption),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Align(
            alignment: _alignLeft ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 12.w),
              padding: EdgeInsets.all(14.r),
              constraints: BoxConstraints(
                maxWidth: message.hasSharedMaterial
                    ? CommunityChatLayoutMetrics.materialBubbleMaxWidth(context)
                    : CommunityChatLayoutMetrics.bubbleMaxWidth(context),
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radiusMedium),
                  topRight: Radius.circular(AppSizes.radiusMedium),
                  bottomLeft:
                      _alignLeft ? Radius.zero : Radius.circular(AppSizes.radiusMedium),
                  bottomRight:
                      _alignLeft ? Radius.circular(AppSizes.radiusMedium) : Radius.zero,
                ),
                border: Border.all(color: AppColors.mainDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.materialRef != null)
                    CommunitySharedMaterialPreview(
                      materialRef: message.materialRef!,
                      note: message.text.isNotEmpty ? message.text : null,
                    )
                  else if (message.inlineToolData != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.communityChatSharedFromMishka,
                          style: CommunityStyles.bodySemiBold.copyWith(
                            fontSize: AppSizes.fontSizeSmall,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ToolPreviewRenderer(
                          toolData: message.inlineToolData!,
                          layout: ToolPreviewLayout.communityChat,
                        ),
                      ],
                    )
                  else ...[
                    if (message.text.isNotEmpty)
                      Text(
                        message.text,
                        style: CommunityStyles.body.copyWith(height: 1.4),
                      ),
                    if (message.isShared && message.text.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mainGold.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusSmall),
                          border: Border.all(color: AppColors.mainGold),
                        ),
                        child: Text(
                          l10n.communityChatSharedFromMishka,
                          style: CommunityStyles.bodySemiBold.copyWith(
                            fontSize: AppSizes.fontSizeSmall,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
