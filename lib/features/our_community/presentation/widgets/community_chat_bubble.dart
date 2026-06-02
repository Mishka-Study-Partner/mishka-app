import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';

import '../../community_styles.dart';
import '../../data/community_models.dart';

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
              constraints: BoxConstraints(maxWidth: 280.w),
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
                  Text(
                    message.text,
                    style: CommunityStyles.body.copyWith(height: 1.4),
                  ),
                  if (message.isShared) ...[
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mainGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        border: Border.all(color: AppColors.mainGold),
                      ),
                      child: Text(
                        'Shared from Mishka',
                        style: CommunityStyles.bodySemiBold.copyWith(
                          fontSize: AppSizes.fontSizeSmall,
                        ),
                      ),
                    ),
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
