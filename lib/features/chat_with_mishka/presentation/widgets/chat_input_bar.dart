import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/tabler.dart';
import 'package:iconify_flutter/icons/zondicons.dart';

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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 358.w,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: AppColors.greyText),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 UPLOADED FILES (max 2 rows)
              if (widget.uploads.isNotEmpty) ...[
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 120.h),
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
                          onRemove: () =>
                              widget.onRemoveUpload(item),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
              ],

              /// 🔹 INPUT ROW (UNCHANGED LOOK)
              Row(
                children: [
                  Iconify(Zondicons.mic,
                      size: 24, color: AppColors.mainDark),
                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: widget.onPickFile,
                    child: Iconify(
                      Ion.options_sharp,
                      size: 24,
                      color: AppColors.mainDark,
                    ),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      enabled: widget.typingEnabled,
                      decoration: InputDecoration(
                        hintText: _hintText(),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: widget.typingEnabled
                        ? () {
                      final text =
                      widget.controller.text.trim();
                      if (text.isEmpty) return;
                      widget.onSend(text);
                      widget.controller.clear();
                    }
                        : null,
                    child: Iconify(
                      Tabler.send,
                      size: 24,
                      color: widget.typingEnabled
                          ? AppColors.mainDark
                          : AppColors.greyText,
                    ),
                  ),
                ],
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
