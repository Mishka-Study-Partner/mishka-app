enum TimerMode { study, shortBreak, longBreak }

class StudyTimerModel {
  final String title;
  final int studyMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;

  /// Backend concentration preset (e.g. `classic_pomodoro`, `custom`).
  final String? modeId;

  /// Saved custom timer id when using `concentrationPreset: custom`.
  final String? customPresetId;

  /// Optional personal course/subject for reports.
  final String? studentSubjectId;
  final String? studentSubjectName;

  const StudyTimerModel(
    this.title,
    this.studyMinutes,
    this.shortBreakMinutes,
    this.longBreakMinutes, {
    this.modeId,
    this.customPresetId,
    this.studentSubjectId,
    this.studentSubjectName,
  });

  StudyTimerModel withStudentSubject(String? id, {String? name}) {
    return StudyTimerModel(
      title,
      studyMinutes,
      shortBreakMinutes,
      longBreakMinutes,
      modeId: modeId,
      customPresetId: customPresetId,
      studentSubjectId: id,
      studentSubjectName: name,
    );
  }

  Duration get studyDuration => Duration(minutes: studyMinutes);
  Duration get shortBreakDuration => Duration(minutes: shortBreakMinutes);
  Duration get longBreakDuration => Duration(minutes: longBreakMinutes);

  /// Open-ended focus (Flowtime, Camera call): counts up until the user ends study.
  bool get isOpenEndedStudy =>
      modeId == 'flowtime' ||
      modeId == 'call_with_mishka' ||
      studyMinutes == 0;

  Duration durationFor(TimerMode mode) {
    switch (mode) {
      case TimerMode.study:
        return studyDuration;
      case TimerMode.shortBreak:
        return shortBreakDuration;
      case TimerMode.longBreak:
        return longBreakDuration;
    }
  }

  static const presets = [
    StudyTimerModel('Popular Timer', 20, 5, 15, modeId: 'custom'),
    StudyTimerModel('Medium Timer', 40, 8, 20, modeId: 'custom'),
    StudyTimerModel('Extended Timer', 60, 10, 25, modeId: 'custom'),
  ];
}
