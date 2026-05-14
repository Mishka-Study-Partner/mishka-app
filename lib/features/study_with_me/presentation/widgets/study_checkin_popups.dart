import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

enum CheckInType { stillThere, moodEmoji, moodScale, goodProgress }

/// Backend kind string for each check-in type.
String checkInKindString(CheckInType type) {
  switch (type) {
    case CheckInType.stillThere:
      return 'still_there_yes_no';
    case CheckInType.moodEmoji:
      return 'mood_scale_5';
    case CheckInType.moodScale:
      return 'mood_scale_10';
    case CheckInType.goodProgress:
      return 'progress_yes_no';
  }
}

/// Shows the next study check-in popup in sequence.
/// [currentIndex] is 0-3, cycling through the 4 popup types.
/// [onResponse] is called with (CheckInType, response value) when user responds.
Future<dynamic> showStudyCheckInPopup(
  BuildContext context, {
  required int currentIndex,
  required void Function(CheckInType type, dynamic response) onResponse,
}) {
  final type = CheckInType.values[currentIndex % CheckInType.values.length];
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _StudyCheckInDialog(type: type, onResponse: onResponse),
  );
}

class _StudyCheckInDialog extends StatelessWidget {
  final CheckInType type;
  final void Function(CheckInType type, dynamic response) onResponse;

  const _StudyCheckInDialog({required this.type, required this.onResponse});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF6F0),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.mainGold, width: 2.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            Text(
              _title(type, l10n),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.mainDark,
              ),
            ),
            SizedBox(height: 16.h),
            _buildInteraction(context, type, l10n),
            SizedBox(height: 16.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.asset(
                'assets/images/study_pop_up.png',
                height: 160.h,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  String _title(CheckInType type, AppLocalizations l10n) {
    switch (type) {
      case CheckInType.stillThere:
        return l10n.areYouStillThere;
      case CheckInType.moodEmoji:
      case CheckInType.moodScale:
        return l10n.howIsYourModeWhileStudying;
      case CheckInType.goodProgress:
        return l10n.makingGoodProgressToday;
    }
  }

  Widget _buildInteraction(
      BuildContext context, CheckInType type, AppLocalizations l10n) {
    switch (type) {
      case CheckInType.stillThere:
        return _YesNoButtons(
          onYes: () {
            Navigator.pop(context);
            onResponse(type, true);
          },
          onNo: () {
            Navigator.pop(context);
            onResponse(type, false);
          },
          l10n: l10n,
        );
      case CheckInType.moodEmoji:
        return _MoodEmojiRow(onSelect: (index) {
          Navigator.pop(context);
          onResponse(type, index + 1); // Backend expects 1-5
        });
      case CheckInType.moodScale:
        return _NumberScaleRow(onSelect: (number) {
          Navigator.pop(context);
          onResponse(type, number);
        });
      case CheckInType.goodProgress:
        return _YesNoButtons(
          onYes: () {
            Navigator.pop(context);
            onResponse(type, true);
          },
          onNo: () {
            Navigator.pop(context);
            onResponse(type, false);
          },
          l10n: l10n,
        );
    }
  }
}

class _YesNoButtons extends StatelessWidget {
  final VoidCallback onYes;
  final VoidCallback onNo;
  final AppLocalizations l10n;

  const _YesNoButtons({
    required this.onYes,
    required this.onNo,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _OutlinedActionButton(
          text: l10n.no,
          borderColor: AppColors.green,
          textColor: AppColors.green,
          onTap: onNo,
        ),
        SizedBox(width: 16.w),
        _OutlinedActionButton(
          text: l10n.yes,
          borderColor: AppColors.red,
          textColor: AppColors.red,
          onTap: onYes,
        ),
      ],
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  final String text;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  const _OutlinedActionButton({
    required this.text,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor, width: 1.5),
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Pridi',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _MoodEmojiRow extends StatelessWidget {
  final ValueChanged<int> onSelect;

  const _MoodEmojiRow({required this.onSelect});

  static const _emojis = ['😊', '🙂', '😐', '😕', '😣'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_emojis.length, (i) {
        return GestureDetector(
          onTap: () => onSelect(i),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Text(
              _emojis[i],
              style: TextStyle(fontSize: 28.sp),
            ),
          ),
        );
      }),
    );
  }
}

class _NumberScaleRow extends StatelessWidget {
  final ValueChanged<int> onSelect;

  const _NumberScaleRow({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6.w,
      runSpacing: 6.h,
      children: List.generate(10, (i) {
        final number = i + 1;
        return GestureDetector(
          onTap: () => onSelect(number),
          child: Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: AppColors.mainGold, width: 1.5),
              color: const Color(0xFFFAF6F0),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.mainDark,
              ),
            ),
          ),
        );
      }),
    );
  }
}
