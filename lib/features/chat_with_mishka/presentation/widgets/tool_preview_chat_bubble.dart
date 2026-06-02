import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/chat_with_mishka/data/data_sources/saved_library_remote_data_source.dart';
import 'package:mishka_app/features/chat_with_mishka/data/generated_material_helper.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/generated_material_toolbar.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_preview_renderer.dart';

class ToolPreviewChatBubble extends StatefulWidget {
  const ToolPreviewChatBubble({
    super.key,
    required this.toolData,
    required this.savedLibrary,
  });

  final Map<String, dynamic> toolData;
  final SavedLibraryRemoteDataSource savedLibrary;

  @override
  State<ToolPreviewChatBubble> createState() => _ToolPreviewChatBubbleState();
}

class _ToolPreviewChatBubbleState extends State<ToolPreviewChatBubble> {
  bool _isBusy = false;
  String? _savedLibraryId;
  String? _sharedEntityId;

  GeneratedMaterialHelper get _helper =>
      GeneratedMaterialHelper(context, widget.savedLibrary);

  Future<void> _onSave() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    final id = await _helper.saveTool(widget.toolData);
    if (mounted) {
      setState(() {
        _isBusy = false;
        if (id != null) _savedLibraryId = id;
      });
    }
  }

  Future<void> _onShare() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    await _helper.shareTool(
      toolData: widget.toolData,
      savedLibraryId: _savedLibraryId,
      sharedEntityId: _sharedEntityId,
      onEntityId: (id) => _sharedEntityId = id,
    );
    if (mounted) setState(() => _isBusy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: AppColors.mainDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GeneratedMaterialToolbar(
              onShare: _onShare,
              onSave: _onSave,
              isBusy: _isBusy,
            ),
            ToolPreviewRenderer(toolData: widget.toolData),
          ],
        ),
      ),
    );
  }
}
