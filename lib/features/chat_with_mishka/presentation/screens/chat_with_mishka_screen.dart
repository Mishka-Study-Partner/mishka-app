import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../l10n/app_localizations.dart';

import '../../data/controller/chat_flow_controller.dart';
import '../../data/model/uploaded_item.dart';
import '../../data/service/mishka_ai_service.dart' as ai_service;

import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_render.dart';

class ChatWithMishkaScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ChatWithMishkaScreen({
    super.key,
    this.onBack,
  });

  @override
  State<ChatWithMishkaScreen> createState() => _ChatWithMishkaScreenState();
}

class _ChatWithMishkaScreenState extends State<ChatWithMishkaScreen> {
  late final ChatFlowController controller;
  late final ai_service.MishkaAiService ai;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();

  String? _pickedPdfPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    controller = ChatFlowController();
    ai = ai_service.MishkaAiService();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  // ================= SCROLL =================
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ================= PDF PICK =================
  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: false,
    );

    if (result == null) return;

    final file = result.files.single;
    final path = file.path;

    if (path == null || path.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotReadFilePath)),
      );
      return;
    }

    setState(() {
      _pickedPdfPath = path;
      controller.onPdfUploaded(fileName: file.name);
    });

    _scrollToBottom();
  }

  void removePdf(UploadedItem item) {
    setState(() {
      _pickedPdfPath = null;
      controller.uploadedPdfName = null;
      controller.difficulty = null;

      controller.messages.removeWhere((m) =>
      m.type == MessageType.file ||
          m.type == MessageType.options ||
          m.type == MessageType.selection ||
          m.type == MessageType.explanation);
    });

    _scrollToBottom();
  }

  List<UploadedItem> get uploadedItems {
    final name = controller.uploadedPdfName;
    if (name == null) return [];
    return [UploadedItem(name: name, type: UploadType.pdf)];
  }

  // ================= OPTIONS =================
  Future<void> _handleOptionTap(String value) async {
    /// REGENERATE
    if (value == "Regenerate") {
      final regenerateAction = controller.onRegenerateOrAnotherTool(value);
      _scrollToBottom();
      
      if (regenerateAction != null) {
        // Regenerate same tool type
        try {
          final sid = controller.sessionId;
          if (sid == null) throw Exception('Missing sessionId');

          final complexity = _difficultyForTools(controller.difficulty);
          final toolJson = await ai.generateTool(
            sessionId: sid,
            action: regenerateAction,
            complexity: complexity,
          );

          setState(() {
            // Don't show "regenerated" message - just show the tool directly
            controller.onToolPreviewGenerated(toolData: toolJson);
            controller.onToolGenerated(regenerateAction);
          });
        } catch (e) {
          setState(() {
            controller.messages.add(
              ChatMessage(
                isFromMishka: true,
                type: MessageType.system,
                time: DateTime.now(),
                text: "⚠️ Regeneration failed.\n$e",
              ),
            );
          });
        }
        _scrollToBottom();
      }
      return;
    }

    /// ANOTHER TOOL
    if (value == "Another Tool") {
      // Show tool options again
      controller.onRegenerateOrAnotherTool(value);
      // Make sure we're in freeInteraction state so tool selection works
      controller.step = ChatStep.freeInteraction;
      setState(() {});
      _scrollToBottom();
      return;
    }

    /// DIFFICULTY
    if (controller.step == ChatStep.waitingForDifficulty) {
      final level = _mapDifficulty(value);

      setState(() {
        controller.onDifficultySelected(level);
        _isLoading = true;
      });
      _scrollToBottom();

      try {
        if (_pickedPdfPath == null) {
          throw Exception('PDF path missing');
        }

        final summaryLevel =
        (level == DifficultyLevel.simple) ? 'simple' : 'detailed';

        final result = await ai.explainPdf(
          pdfPath: _pickedPdfPath!,
          summaryLevel: summaryLevel,
        );

        setState(() {
          controller.onExplanationReady(
            explanationText: result.explanation,
            sessionId: result.sessionId,
          );
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          controller.messages.add(
            ChatMessage(
              isFromMishka: true,
              type: MessageType.system,
              time: DateTime.now(),
              text: "⚠️ Failed to analyze PDF.\n$e",
            ),
          );
        });
      } finally {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
      return;
    }

    /// TOOLS
    if (controller.step == ChatStep.freeInteraction) {
      // onActionSelected expects String label, not StudyAction
      final action = controller.onActionSelected(value);
      _scrollToBottom();

      try {
        final sid = controller.sessionId;
        if (sid == null) throw Exception('Missing sessionId');

        final complexity = _difficultyForTools(controller.difficulty);

        final toolJson = await ai.generateTool(
          sessionId: sid,
          action: action,
          complexity: complexity,
        );

        setState(() {
          // Don't show "generated" message - just show the tool directly
          // Add tool preview to chat
          controller.onToolPreviewGenerated(toolData: toolJson);
          // Show regenerate/another tool options
          controller.onToolGenerated(action);
        });

        // Don't navigate - show in chat instead
        // if (effect.navigateTo != null && mounted) {
        //   _navigateToToolScreen(effect.navigateTo!, toolJson);
        // }
      } catch (e) {
        setState(() {
          controller.messages.add(
            ChatMessage(
              isFromMishka: true,
              type: MessageType.system,
              time: DateTime.now(),
              text: "⚠️ Tool generation failed.\n$e",
            ),
          );
        });
      }

      _scrollToBottom();
    }
  }

  // ================= CHAT =================
  Future<void> _handleSend(String text) async {
    // Only allow chat after explanation exists (sessionId is set)
    if (controller.sessionId == null) {
      setState(() {
        controller.messages.add(
          ChatMessage(
            isFromMishka: true,
            type: MessageType.system,
            time: DateTime.now(),
            text: "⚠️ Please wait for the explanation to complete first.",
          ),
        );
      });
      _scrollToBottom();
      return;
    }

    controller.onUserChatMessage(text);
    _scrollToBottom();

    try {
      final reply = await ai.chat(
        sessionId: controller.sessionId!,
        message: text,
      );

      setState(() {
        controller.onMishkaChatReply(reply);
      });
    } catch (e) {
      setState(() {
        controller.messages.add(
          ChatMessage(
            isFromMishka: true,
            type: MessageType.system,
            time: DateTime.now(),
            text: "⚠️ Chat failed.\n$e",
          ),
        );
      });
    }

    _scrollToBottom();
  }

  // ================= HELPERS =================
  DifficultyLevel _mapDifficulty(String value) {
    switch (value.toLowerCase()) {
      case 'simple':
        return DifficultyLevel.simple;
      case 'hard':
        return DifficultyLevel.advanced;
      case 'intermediate':
      default:
        return DifficultyLevel.intermediate;
    }
  }

  String _difficultyForTools(DifficultyLevel? level) {
    switch (level) {
      case DifficultyLevel.simple:
        return 'Simple';
      case DifficultyLevel.advanced:
        return 'Hard';
      case DifficultyLevel.intermediate:
      default:
        return 'Intermediate';
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: 'Chat with Mishka',
        showBack: true,
        showBottomBar: false,
        onBackTap: widget.onBack ?? () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          /// CHAT
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(bottom: 12.h),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final message = controller.messages[index];
                return ChatMessageRenderer(
                  message: message,
                  onOptionSelected: _handleOptionTap,
                );
              },
            ),
          ),

          if (_isLoading)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),

          /// INPUT
          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: ChatInputBar(
              typingEnabled: controller.isTypingEnabled,
              controller: _inputController,
              uploads: uploadedItems,
              onPickFile: pickPdf,
              onRemoveUpload: removePdf,
              onSend: _handleSend,
            ),
          ),
        ],
      ),
    );
  }
}
