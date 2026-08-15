import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/features/chat_with_mishka/presentation/chat_layout_metrics.dart';

import '../../../../core/utils/app_colors.dart';
import '../../data/ai_response_helpers.dart';
import '../../data/chat_flow_strings.dart';
import '../../data/controller/chat_flow_controller.dart';
import 'package:mishka_app/features/chat_with_mishka/data/data_sources/saved_library_remote_data_source.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_preview_chat_bubble.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'formatted_study_text.dart';
import 'study_text_utils.dart';
import 'tool_preview_renderer.dart';

typedef OptionTap = void Function(String value);
typedef ToolDataUpdated = void Function(Map<String, dynamic> toolData);

class ChatMessageRenderer extends StatelessWidget {
  const ChatMessageRenderer({
    super.key,
    required this.message,
    this.onOptionSelected,
    this.onToolDataUpdated,
    this.savedLibrary,
    this.flowStrings,
  });

  final ChatMessage message;
  final OptionTap? onOptionSelected;
  final ToolDataUpdated? onToolDataUpdated;
  final SavedLibraryRemoteDataSource? savedLibrary;
  final ChatFlowStrings? flowStrings;

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.system:
        return _SystemBubble(text: message.text ?? '', time: message.time);

      case MessageType.text:
        return _TextBubble(
          text: message.text ?? '',
          isFromMishka: message.isFromMishka,
          time: message.time,
        );

      case MessageType.explanation:
        final l10n = AppLocalizations.of(context)!;
        final text = AiResponseHelpers.displayText(
          message.text ?? '',
          l10n.chatAiServiceUnavailable,
        );
        return _ExplanationBubble(text: text, time: message.time);

      case MessageType.file:
        return _FileBubble(fileName: message.fileName ?? '', time: message.time);

      case MessageType.options:
        return _OptionsBubble(
          options: message.options!
              .map((o) => flowStrings?.localizeOptionLabel(o) ?? o)
              .toList(),
          rawOptions: message.options!,
          onSelect: onOptionSelected,
          time: message.time,
        );

      case MessageType.selection:
        return _SelectionBubble(
          value: flowStrings?.localizeOptionLabel(message.selectedOption!) ??
              message.selectedOption!,
          time: message.time,
        );

      case MessageType.toolPreview:
        if (savedLibrary == null) {
          return ToolPreviewRenderer(toolData: message.toolData!);
        }
        return ToolPreviewChatBubble(
          toolData: message.toolData!,
          savedLibrary: savedLibrary!,
          messageTime: message.time,
          storageMessageId: message.backendMessageId,
          onToolDataUpdated: onToolDataUpdated,
        );
    }
  }
}

class _Timestamp extends StatelessWidget {
  const _Timestamp({required this.time, this.alignLeft = true});

  final DateTime time;
  final bool alignLeft;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: alignLeft ? 16.w : 0,
        right: alignLeft ? 0 : 16.w,
        bottom: 4.h,
        top: 2.h,
      ),
      child: Text(
        formatChatTime(time),
        style: TextStyle(
          fontFamily: 'Pridi',
          fontSize: 11.sp,
          color: AppColors.greyText,
        ),
      ),
    );
  }
}

class _SystemBubble extends StatelessWidget {
  const _SystemBubble({required this.text, required this.time});

  final String text;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: 'Pridi',
                color: AppColors.greyText,
              ),
            ),
          ),
        ),
        _Timestamp(time: time, alignLeft: true),
      ],
    );
  }
}

class _TextBubble extends StatelessWidget {
  const _TextBubble({
    required this.text,
    required this.isFromMishka,
    required this.time,
  });

  final String text;
  final bool isFromMishka;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    final alignment =
        isFromMishka ? Alignment.centerLeft : Alignment.centerRight;

    return Column(
      crossAxisAlignment:
          isFromMishka ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Align(
          alignment: alignment,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
            padding: EdgeInsets.all(14.r),
            constraints: BoxConstraints(
              maxWidth: ChatLayoutMetrics.bubbleMaxWidth(context),
            ),
            decoration: BoxDecoration(
              color: isFromMishka ? AppColors.white : AppColors.mainDark,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isFromMishka ? AppColors.mainDark : AppColors.mainDark,
              ),
            ),
            child: StudyText(
              text,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: 14.sp,
                height: 1.4,
                color: isFromMishka ? AppColors.mainDark : AppColors.white,
              ),
            ),
          ),
        ),
        _Timestamp(time: time, alignLeft: isFromMishka),
      ],
    );
  }
}

class _ExplanationBubble extends StatelessWidget {
  const _ExplanationBubble({required this.text, required this.time});

  final String text;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.mainDark),
          ),
          child: FormattedStudyText(
            text: text,
            textAlign: TextAlign.justify,
            baseStyle: TextStyle(
              fontFamily: 'Pridi',
              fontSize: 14.sp,
              height: 1.5,
              color: AppColors.mainDark,
            ),
          ),
        ),
        _Timestamp(time: time),
      ],
    );
  }
}

class _FileBubble extends StatelessWidget {
  const _FileBubble({required this.fileName, required this.time});

  final String fileName;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.mainDark),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.picture_as_pdf, color: AppColors.mainGold, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  fileName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Pridi',
                    color: AppColors.mainDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        _Timestamp(time: time, alignLeft: false),
      ],
    );
  }
}

class _OptionsBubble extends StatelessWidget {
  const _OptionsBubble({
    required this.options,
    required this.rawOptions,
    required this.time,
    this.onSelect,
  });

  final List<String> options;
  final List<String> rawOptions;
  final DateTime time;
  final OptionTap? onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(options.length, (index) {
              return GestureDetector(
                onTap: () => onSelect?.call(rawOptions[index]),
                child: Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.mainDark),
                  ),
                  child: Center(
                    child: Text(
                      options[index],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Pridi',
                        color: AppColors.mainDark,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        _Timestamp(time: time),
      ],
    );
  }
}

class _SelectionBubble extends StatelessWidget {
  const _SelectionBubble({required this.value, required this.time});

  final String value;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
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
                fontFamily: 'Pridi',
                color: AppColors.white,
              ),
            ),
          ),
        ),
        _Timestamp(time: time, alignLeft: false),
      ],
    );
  }
}
