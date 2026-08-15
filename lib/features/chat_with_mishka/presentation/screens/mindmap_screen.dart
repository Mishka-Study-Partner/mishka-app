import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/tool_data_normalizer.dart';
import '../widgets/tool_preview_renderer.dart';

class MindmapScreen extends StatelessWidget {
  final Map<String, dynamic> toolData;

  const MindmapScreen({
    super.key,
    required this.toolData,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final data = normalizeToolData(Map<String, dynamic>.from(toolData));
    data.putIfAbsent('tool_type', () => 'mind_maps');

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.mindMap,
        showBack: true,
        showBottomBar: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppScrollInsets.page(horizontal: 12.w, top: 12.h, bottom: 12.h),
          child: SizedBox.expand(
            child: ToolPreviewRenderer(
              toolData: data,
              layout: ToolPreviewLayout.expanded,
            ),
          ),
        ),
      ),
    );
  }
}
