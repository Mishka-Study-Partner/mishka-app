import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/tabler.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/layout/app_scale.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';

import '../../../../core/utils/app_colors.dart';
import '../../data/model/uploaded_item.dart';
import 'uploaded_file_card.dart';

class ChatInputBar extends StatefulWidget {
  final bool typingEnabled;
  final TextEditingController controller;

  final List<UploadedItem> uploads;
  final void Function(UploadedItem item) onRemoveUpload;
  final VoidCallback onPickFile;
  final void Function(String text) onSend;
  final String uploadHint;
  final String chooseDifficultyHint;
  final String askHint;

  const ChatInputBar({
    super.key,
    required this.typingEnabled,
    required this.controller,
    required this.uploads,
    required this.onPickFile,
    required this.onRemoveUpload,
    required this.onSend,
    required this.uploadHint,
    required this.chooseDifficultyHint,
    required this.askHint,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar>
    with TickerProviderStateMixin {
  bool get hasMaterial => widget.uploads.isNotEmpty;

  void _sendMessage() {
    if (!widget.typingEnabled) return;
    final text = widget.controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    widget.controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppBreakpoints.isTablet(context);
    final horizontalInset =
        isTablet ? AppScale.w(24) : AppSizes.paddingMedium;
    final iconSize = isTablet ? AppScale.w(26) : 24.w;
    final inputMinHeight = isTablet ? AppScale.h(44) : 40.h;
    final textStyle = TextStyle(
      fontFamily: 'Pridi',
      fontSize: isTablet ? AppSizes.fontSizeMedium : AppSizes.fontSizeSmall,
      fontWeight: FontWeight.w500,
      color: AppColors.mainDark,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalInset),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? AppScale.w(14) : AppSizes.paddingSmall,
            vertical: isTablet ? AppScale.h(10) : AppScale.h(8),
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(
              isTablet ? AppScale.r(32) : AppScale.r(28),
            ),
            border: Border.all(color: AppColors.greyText),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.uploads.isNotEmpty) ...[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: isTablet ? AppScale.h(130) : 120.h,
                  ),
                  child: SingleChildScrollView(
                    physics: widget.uploads.length > 3
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.uploads
                          .map(
                            (item) => UploadedFileCard(
                              item: item,
                              onRemove: () => widget.onRemoveUpload(item),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
              ],
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: inputMinHeight),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: widget.onPickFile,
                      child: Iconify(
                        Ion.options_sharp,
                        size: iconSize,
                        color: AppColors.mainDark,
                      ),
                    ),
                    SizedBox(width: isTablet ? 12.w : 10.w),
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        enabled: widget.typingEnabled,
                        textInputAction: TextInputAction.send,
                        minLines: 1,
                        maxLines: 4,
                        style: textStyle,
                        onSubmitted:
                            widget.typingEnabled ? (_) => _sendMessage() : null,
                        decoration: InputDecoration(
                          hintText: _hintText(),
                          hintStyle: textStyle.copyWith(
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isTablet ? AppScale.h(10) : 8.h,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isTablet ? 8.w : 4.w),
                    GestureDetector(
                      onTap: widget.typingEnabled ? _sendMessage : null,
                      child: Iconify(
                        Tabler.send,
                        size: iconSize,
                        color: widget.typingEnabled
                            ? AppColors.mainDark
                            : AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _hintText() {
    if (!hasMaterial) return widget.uploadHint;
    if (!widget.typingEnabled) return widget.chooseDifficultyHint;
    return widget.askHint;
  }
}
