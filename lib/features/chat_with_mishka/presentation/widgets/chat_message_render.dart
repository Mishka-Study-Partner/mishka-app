import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../data/controller/chat_flow_controller.dart';
import 'tool_preview_renderer.dart';

typedef OptionTap = void Function(String value);

class ChatMessageRenderer extends StatelessWidget {
  final ChatMessage message;
  final OptionTap? onOptionSelected;

  const ChatMessageRenderer({
    super.key,
    required this.message,
    this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.system:
        return _SystemBubble(text: message.text!);

      case MessageType.text:
      case MessageType.explanation:
        return _TextBubble(
          text: message.text!,
          isFromMishka: message.isFromMishka,
        );

      case MessageType.file:
        return _FileBubble(fileName: message.fileName!);

      case MessageType.options:
        return _OptionsBubble(
          options: message.options!,
          onSelect: onOptionSelected,
        );

      case MessageType.selection:
        return _SelectionBubble(value: message.selectedOption!);

      case MessageType.toolPreview:
        return ToolPreviewRenderer(toolData: message.toolData!);
    }
  }
}

class _SystemBubble extends StatelessWidget {
  final String text;

  const _SystemBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.sp,
            fontFamily: "Pridi",
            color: AppColors.greyText,
          ),
        ),
      ),
    );
  }
}
class _TextBubble extends StatelessWidget {
  final String text;
  final bool isFromMishka;

  const _TextBubble({
    required this.text,
    required this.isFromMishka,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
      isFromMishka ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
        padding: EdgeInsets.all(14.r),
        constraints: BoxConstraints(maxWidth: 260.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14.r),
            topRight: Radius.circular(14.r),
            bottomLeft:
            isFromMishka ? Radius.zero : Radius.circular(14.r),
            bottomRight:
            isFromMishka ? Radius.circular(14.r) : Radius.zero,
          ),
          border: Border.all(color: AppColors.mainDark),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: "Pridi",
            fontSize: 14.sp,
            height: 1.4,
            color: AppColors.mainDark,
          ),
        ),
      ),
    );
  }
}
class _FileBubble extends StatelessWidget {
  final String fileName;

  const _FileBubble({required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.mainDark),
        ),
        child: Text(
          fileName,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.mainDark,
          ),
        ),
      ),
    );
  }
}
class _OptionsBubble extends StatelessWidget {
  final List<String> options;
  final OptionTap? onSelect;

  const _OptionsBubble({
    required this.options,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: options.map((option) {
          return GestureDetector(
            onTap: () => onSelect?.call(option),
            child: Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.mainDark),
              ),
              child: Center(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Pridi",
                    color: AppColors.mainDark,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
class _SelectionBubble extends StatelessWidget {
  final String value;

  const _SelectionBubble({required this.value});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.mainDark,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

