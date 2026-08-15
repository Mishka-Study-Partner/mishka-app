import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_focus_metrics.dart';

/// Design shell for AI-generated flashcards, quiz, summary, and mind map in chat.
class GeneratedMaterialCard extends StatelessWidget {
  const GeneratedMaterialCard({
    super.key,
    required this.title,
    required this.child,
    this.onShare,
    this.onExpand,
    this.onSave,
    this.onRefresh,
    this.isBusy = false,
    this.isSaved = false,
  });

  final String title;
  final Widget child;
  final VoidCallback? onShare;
  final VoidCallback? onExpand;
  final VoidCallback? onSave;
  final VoidCallback? onRefresh;
  final bool isBusy;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.mainDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: ToolFocusMetrics.materialCardHeaderPadding(context),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: ToolFocusMetrics.materialCardTitleSize(context),
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainDark,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: isBusy ? null : onShare,
                  icon: Icon(
                    Icons.share_outlined,
                    size: ToolFocusMetrics.materialCardActionIconSize(context),
                  ),
                  color: AppColors.mainDark,
                  padding: EdgeInsets.all(4.r),
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  onPressed: isBusy ? null : onExpand,
                  icon: Icon(
                    Icons.open_in_full,
                    size: ToolFocusMetrics.materialCardActionIconSize(context),
                  ),
                  color: AppColors.mainDark,
                  padding: EdgeInsets.all(4.r),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Padding(
            padding: ToolFocusMetrics.materialCardBodyPadding(context),
            child: child,
          ),
          Padding(
            padding: EdgeInsets.only(left: 6.w, right: 6.w, bottom: 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _FooterIcon(
                  icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                  onTap: isBusy ? null : onSave,
                  color: isSaved ? AppColors.mainGold : AppColors.mainDark,
                ),
                _FooterIcon(
                  icon: Icons.refresh,
                  onTap: isBusy ? null : onRefresh,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterIcon extends StatelessWidget {
  const _FooterIcon({
    required this.icon,
    this.onTap,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: ToolFocusMetrics.materialCardActionIconSize(context)),
      color: color ?? AppColors.mainDark,
      padding: EdgeInsets.all(6.r),
      constraints: const BoxConstraints(),
    );
  }
}
