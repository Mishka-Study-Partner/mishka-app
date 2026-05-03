import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../data/controller/chat_flow_controller.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  /// Callbacks for option selections
  final void Function(DifficultyLevel)? onDifficultySelected;
  final void Function(StudyAction)? onActionSelected;

  const ChatBubble({
    super.key,
    required this.message,
    this.onDifficultySelected,
    this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.system:
        return _SystemBubble(text: message.text ?? "");
      case MessageType.text:
        return _TextBubble(
          text: message.text ?? "",
          isFromMishka: message.isFromMishka,
        );
      case MessageType.explanation:
        return _ExplanationBubble(text: message.text ?? "");
      case MessageType.file:
        return _FileBubble(
          fileName: message.fileName ?? "PDF",
          isFromMishka: message.isFromMishka,
        );
      case MessageType.selection:
        return _SelectionBubble(label: message.selectedOption ?? "");
      case MessageType.options:
        return _OptionsBubble(
          options: message.options ?? const [],
          onDifficultySelected: onDifficultySelected,
          onActionSelected: onActionSelected,
        );
      case MessageType.toolPreview:
        // Tool preview is handled by chat_message_render.dart
        // This widget may not be used for toolPreview, but we need to handle it
        return const SizedBox.shrink();
    }
  }
}

/// ========================
/// System bubble (centered)
/// ========================
class _SystemBubble extends StatelessWidget {
  final String text;
  const _SystemBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "Pridi",
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.mainDark,
            ),
          ),
        ),
      ),
    );
  }
}

/// ========================
/// Normal text bubble
/// ========================
class _TextBubble extends StatelessWidget {
  final String text;
  final bool isFromMishka;

  const _TextBubble({
    required this.text,
    required this.isFromMishka,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isFromMishka ? Alignment.centerLeft : Alignment.centerRight;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Align(
        alignment: alignment,
        child: Container(
          constraints: BoxConstraints(maxWidth: 280.w),
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.mainDark),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: "Pridi",
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: AppColors.mainDark,
            ),
          ),
        ),
      ),
    );
  }
}

/// ========================
/// Explanation bubble
/// ========================
class _ExplanationBubble extends StatelessWidget {
  final String text;
  const _ExplanationBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: 300.w),
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.mainDark),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: "Pridi",
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              height: 1.45,
              color: AppColors.mainDark,
            ),
          ),
        ),
      ),
    );
  }
}

/// ========================
/// File bubble (simple for now)
/// ========================
class _FileBubble extends StatelessWidget {
  final String fileName;
  final bool isFromMishka;

  const _FileBubble({
    required this.fileName,
    required this.isFromMishka,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isFromMishka ? Alignment.centerLeft : Alignment.centerRight;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Align(
        alignment: alignment,
        child: Container(
          width: 220.w,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.mainDark),
          ),
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: AppColors.mainGold, size: 20.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "Pridi",
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ========================
/// Option B selection bubble (user choice)
/// ========================
class _SelectionBubble extends StatelessWidget {
  final String label;
  const _SelectionBubble({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: 260.w),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.mainDark, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 16.sp, color: AppColors.mainGold),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "Pridi",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ========================
/// Options bubble (difficulty or tools)
/// - difficulty: vertical pill list
/// - tools: vertical pill list too
/// ========================
class _OptionsBubble extends StatelessWidget {
  final List<String> options;
  final void Function(DifficultyLevel)? onDifficultySelected;
  final void Function(StudyAction)? onActionSelected;

  const _OptionsBubble({
    required this.options,
    this.onDifficultySelected,
    this.onActionSelected,
  });

  bool get _isDifficultyOptions =>
      options.contains("Simple") &&
          options.contains("Intermediate") &&
          options.contains("Hard");

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: 320.w),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.mainDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: options.map((label) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _OptionPill(
                  label: label,
                  onTap: () {
                    if (_isDifficultyOptions) {
                      onDifficultySelected?.call(_difficultyFromLabel(label));
                    } else {
                      onActionSelected?.call(_actionFromLabel(label));
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  DifficultyLevel _difficultyFromLabel(String label) {
    switch (label) {
      case "Simple":
        return DifficultyLevel.simple;
      case "Intermediate":
        return DifficultyLevel.intermediate;
      case "Hard":
        return DifficultyLevel.advanced;
      default:
        return DifficultyLevel.intermediate;
    }
  }

  StudyAction _actionFromLabel(String label) {
    switch (label) {
      case "Quiz":
        return StudyAction.quiz;
      case "Flashcards":
        return StudyAction.flashcards;
      case "Mind Map":
        return StudyAction.mindmap;
      default:
        return StudyAction.quiz;
    }
  }
}

class _OptionPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OptionPill({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(color: AppColors.mainDark),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: "Pridi",
              fontSize: 14.sp,
              fontWeight: FontWeight.w600, // ✅ semibold
              color: AppColors.mainDark,
            ),
          ),
        ),
      ),
    );
  }
}
/*
class ChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          /// BUBBLE
          Container(
            constraints: BoxConstraints(maxWidth: 260.w),
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: _bubbleRadius(),
              border: Border.all(
                color: AppColors.mainDark,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// MESSAGE
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: "Pridi",
                    fontSize: 14.sp,
                    height: 1.4,
                    color: AppColors.mainDark,
                  ),
                ),

                /// ACTIONS (inside bubble, received only)
                if (!isUser) ...[
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        _ActionIcon(Tabler.copy),
                        SizedBox(width: 12),
                        _ActionIcon(Uiw.like_o),
                        SizedBox(width: 12),
                        _ActionIcon(Uiw.dislike_o),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 4.h),

          /// TIME (outside bubble)
          Text(
            time,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.greyText,
            ),
          ),

          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  /// 3 rounded corners + 1 sharp corner
  BorderRadius _bubbleRadius() {
    const radius = Radius.circular(14);

    if (isUser) {
      // sent → sharp bottom-right
      return const BorderRadius.only(
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: Radius.zero,
      );
    } else {
      // received → sharp bottom-left
      return const BorderRadius.only(
        topLeft: radius,
        topRight: radius,
        bottomRight: radius,
        bottomLeft: Radius.zero,
      );
    }
  }
}

/// Action icon widget
class _ActionIcon extends StatelessWidget {
  final String icon;

  const _ActionIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Iconify(
      icon,
      size: 18,
      color: AppColors.mainDark,
    );
  }
}
*/