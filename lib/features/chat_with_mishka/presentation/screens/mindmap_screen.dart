import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
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

    final data = Map<String, dynamic>.from(toolData);
    data.putIfAbsent('tool_type', () => 'mind_maps');

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.mindMap,
        showBack: true,
        showBottomBar: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        child: ToolPreviewRenderer(toolData: data),
      ),
    );
  }
}
