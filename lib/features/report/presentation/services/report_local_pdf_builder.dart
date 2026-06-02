import 'dart:io';
import 'dart:ui' show Rect;

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:mishka_app/features/report/data/models/report_models.dart';

/// Offline / pre-deploy fallback PDF (plain text summary).
class ReportLocalPdfBuilder {
  Future<File> buildAndSave({
    required YourReportSnapshot snapshot,
    required String title,
    required String studySectionTitle,
    required String aiSectionTitle,
    required String streakSectionTitle,
    required String tasksSectionTitle,
    required String streakCurrentLabel,
    required String streakLongestLabel,
    required String streakFreezesLabel,
    required String quizzesLabel,
    required String flashcardsLabel,
    required String summariesLabel,
  }) async {
    final document = PdfDocument();
    final page = document.pages.add();
    final graphics = page.graphics;
    final titleFont = PdfStandardFont(PdfFontFamily.helvetica, 18,
        style: PdfFontStyle.bold);
    final headerFont = PdfStandardFont(PdfFontFamily.helvetica, 13,
        style: PdfFontStyle.bold);
    final bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 11);

    var y = 20.0;
    graphics.drawString(title, titleFont, bounds: Rect.fromLTWH(20, y, 500, 24));
    y += 28;
    graphics.drawString(snapshot.periodLabel, bodyFont,
        bounds: Rect.fromLTWH(20, y, 500, 18));
    y += 26;

    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final streakLines = <String>[
      '$streakCurrentLabel: ${snapshot.currentStreak}',
      '$streakLongestLabel: ${snapshot.longestStreak}',
      '$streakFreezesLabel: ${snapshot.freezesRemaining}',
      if (snapshot.hasStreakWeek)
        ...List.generate(snapshot.streakWeek.length, (i) {
          final day = snapshot.streakWeek[i];
          final status = day.isCompleted
              ? 'completed'
              : day.isMissed
                  ? 'missed'
                  : day.isToday
                      ? 'today'
                      : 'upcoming';
          final label = i < dayLabels.length ? dayLabels[i] : 'Day ${i + 1}';
          return '$label: $status';
        }),
    ];
    y = _section(graphics, y, streakSectionTitle, streakLines, headerFont, bodyFont);
    y = _section(
      graphics,
      y,
      studySectionTitle,
      snapshot.studyMinutes
          .map((b) => '${b.label}: ${b.value.toStringAsFixed(0)} min')
          .toList(),
      headerFont,
      bodyFont,
    );
    y = _section(
      graphics,
      y,
      aiSectionTitle,
      [
        '$quizzesLabel: ${snapshot.aiTools.quizzes}',
        '$flashcardsLabel: ${snapshot.aiTools.flashcards}',
        '$summariesLabel: ${snapshot.aiTools.summaries}',
      ],
      headerFont,
      bodyFont,
    );

    if (snapshot.hasTasksCompletedData) {
      _section(
        graphics,
        y,
        tasksSectionTitle,
        snapshot.tasksCompletedByDay
            .where((b) => b.value > 0)
            .map((b) => '${b.label}: ${b.value.toStringAsFixed(0)} tasks')
            .toList(),
        headerFont,
        bodyFont,
      );
    }

    final bytes = await document.save();
    document.dispose();

    final dir = await getTemporaryDirectory();
    final fileName =
        'mishka-report-${snapshot.period.name}-${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> shareFile(File file, {String? subject}) async {
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: subject,
    );
  }

  double _section(
    PdfGraphics graphics,
    double y,
    String title,
    List<String> lines,
    PdfFont headerFont,
    PdfFont bodyFont,
  ) {
    graphics.drawString(title, headerFont, bounds: Rect.fromLTWH(20, y, 500, 18));
    y += 20;
    for (final line in lines) {
      graphics.drawString(line, bodyFont, bounds: Rect.fromLTWH(28, y, 500, 16));
      y += 16;
    }
    return y + 12;
  }
}
