import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../data/chat_flow_strings.dart';
import '../../data/chat_pdf_cache.dart';
import '../../data/controller/chat_flow_controller.dart';
import '../../data/data_sources/saved_library_remote_data_source.dart';
import '../../data/model/uploaded_item.dart';
import 'package:mishka_app/features/chat_with_mishka/data/models/chat_history_item.dart';
import 'package:mishka_app/features/chat_with_mishka/data/repositories/chat_history_repository.dart';
import 'package:mishka_app/features/chat_with_mishka/data/repositories/chat_session_repository.dart';
import '../../data/service/mishka_ai_service.dart' as ai_service;

import '../widgets/chat_history_drawer.dart';
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
  late final ai_service.MishkaAiService ai;
  late final ChatSessionRepository _sessionRepo;
  late final ChatHistoryRepository _historyRepo;
  late final SavedLibraryRemoteDataSource _savedLibrary;
  late ChatFlowController controller;
  ChatFlowStrings? _strings;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();

  String? _pickedPdfPath;
  String? _backendSessionId;
  bool _isLoading = false;
  bool _isRestoring = true;
  bool _historyOpen = false;
  bool _historyLoading = false;
  ChatHistoryData _historyData = const ChatHistoryData();
  int _persistedMessageCount = 0;

  @override
  void initState() {
    super.initState();
    controller = ChatFlowController();
    ai = ai_service.MishkaAiService();
    _sessionRepo = ChatSessionRepository();
    _historyRepo = ChatHistoryRepository();
    _savedLibrary = SavedLibraryRemoteDataSource(ApiService());
    ChatPdfCache.purgeExpired();
    _restoreActiveSession();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final strings = ChatFlowStrings(AppLocalizations.of(context)!);
    _strings = strings;
    controller.updateStrings(strings);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _restoreActiveSession() async {
    try {
      final loaded = await _sessionRepo.loadActiveSession();
      if (!mounted) return;
      if (loaded != null) {
        controller.restoreFromTimeline(loaded.timeline, loaded.aiSessionId);
        _backendSessionId = loaded.timeline.session.id;
        _persistedMessageCount = controller.messages.length;
        await _restorePdfFromCache(_backendSessionId!);
      }
    } catch (_) {
      // Keep fresh chat when restore fails.
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
        _scrollToBottom();
      }
    }
  }

  void _persistNewMessages() {
    final sessionId = _backendSessionId;
    if (sessionId == null || sessionId.isEmpty) return;

    while (_persistedMessageCount < controller.messages.length) {
      final message = controller.messages[_persistedMessageCount];
      _persistedMessageCount++;
      _sessionRepo
          .persistMessage(backendSessionId: sessionId, message: message)
          .catchError((_) {});
    }
  }

  Future<void> _openHistory() async {
    setState(() {
      _historyOpen = true;
      _historyLoading = true;
    });
    try {
      final data = await _historyRepo.loadHistory();
      if (!mounted) return;
      setState(() {
        _historyData = data;
        _historyLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _historyLoading = false);
    }
  }

  void _closeHistory() {
    setState(() => _historyOpen = false);
  }

  Future<void> _onHistorySessionSelected(ChatHistoryItem item) async {
    final sessionId = item.chatSessionId;
    if (sessionId == null || sessionId.isEmpty) return;

    _closeHistory();
    setState(() => _isRestoring = true);
    try {
      final loaded = await _sessionRepo.loadSession(sessionId);
      if (!mounted) return;
      controller.restoreFromTimeline(loaded.timeline, loaded.aiSessionId);
      setState(() {
        _backendSessionId = loaded.timeline.session.id;
        _persistedMessageCount = controller.messages.length;
        _isRestoring = false;
      });
      await _restorePdfFromCache(_backendSessionId!);
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isRestoring = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.historyLoadFailed),
        ),
      );
    }
  }

  Future<void> _restorePdfFromCache(String sessionId) async {
    final cached = await ChatPdfCache.pathForSession(sessionId);
    if (!mounted) return;
    if (cached != null) {
      setState(() => _pickedPdfPath = cached);
    }
  }

  Future<void> _startNewChat() async {
    final strings = _strings ?? ChatFlowStrings(AppLocalizations.of(context)!);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.newChatTitle),
        content: Text(strings.newChatMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(strings.newChatConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await AppPreferences.clearActiveChatSession();
    _inputController.clear();
    setState(() {
      _pickedPdfPath = null;
      _backendSessionId = null;
      _persistedMessageCount = 0;
      _isLoading = false;
      controller.reset();
      controller.updateStrings(strings);
    });
    _scrollToBottom();
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

    try {
      final session = await _sessionRepo.startSession(
        title: file.name,
        uploadOriginalFilename: file.name,
      );
      await AppPreferences.setChatBackendSessionId(session.id);
      _backendSessionId = session.id;
      _persistedMessageCount = controller.messages.length;
    } catch (e) {
      if (!mounted) return;
      final strings = _strings ?? ChatFlowStrings(AppLocalizations.of(context)!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.errorSessionStartFailed(e))),
      );
      return;
    }

    try {
      _pickedPdfPath = await ChatPdfCache.persistForSession(
        sessionId: _backendSessionId!,
        sourcePath: path,
      );
    } catch (_) {
      _pickedPdfPath = path;
    }

    setState(() {
      controller.onPdfUploaded(fileName: file.name);
    });

    _persistNewMessages();
    _scrollToBottom();
  }

  Future<void> removePdf(UploadedItem item) async {
    await AppPreferences.clearActiveChatSession();
    setState(() {
      _pickedPdfPath = null;
      _backendSessionId = null;
      _persistedMessageCount = 0;
      controller.uploadedPdfName = null;
      controller.difficulty = null;
      controller.sessionId = null;
      controller.step = ChatStep.idle;

      controller.messages.removeWhere((m) =>
          m.type == MessageType.file ||
          m.type == MessageType.options ||
          m.type == MessageType.selection ||
          m.type == MessageType.explanation ||
          m.type == MessageType.toolPreview);
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
    final strings = _strings ?? ChatFlowStrings(AppLocalizations.of(context)!);

  if (strings.isRegenerate(value)) {
      final regenerateAction = controller.onRegenerateOrAnotherTool(value);
      _persistNewMessages();
      _scrollToBottom();

      if (regenerateAction != null) {
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
            controller.onToolPreviewGenerated(toolData: toolJson);
            controller.onToolGenerated(regenerateAction);
          });
          _persistNewMessages();
        } catch (e) {
          setState(() {
            controller.messages.add(
              ChatMessage(
                isFromMishka: true,
                type: MessageType.system,
                time: DateTime.now(),
                text: strings.errorRegenerationFailed(e),
              ),
            );
          });
          _persistNewMessages();
        }
        _scrollToBottom();
      }
      return;
    }

    /// ANOTHER TOOL
    if (strings.isAnotherTool(value)) {
      controller.onRegenerateOrAnotherTool(value);
      controller.step = ChatStep.freeInteraction;
      setState(() {});
      _persistNewMessages();
      _scrollToBottom();
      return;
    }

    /// DIFFICULTY
    if (controller.step == ChatStep.waitingForDifficulty) {
      final level = strings.difficultyForLabel(value);
      if (level == null) return;

      setState(() {
        controller.onDifficultySelected(level);
        _isLoading = true;
      });
      _persistNewMessages();
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

        if (_backendSessionId != null) {
          await _sessionRepo.bindAiSession(
            backendSessionId: _backendSessionId!,
            aiSessionId: result.sessionId,
            difficulty: level,
          );
        }

        setState(() {
          controller.onExplanationReady(
            explanationText: result.explanation,
            sessionId: result.sessionId,
          );
          _isLoading = false;
        });
        _persistNewMessages();
      } catch (e) {
        setState(() {
          controller.messages.add(
            ChatMessage(
              isFromMishka: true,
              type: MessageType.system,
              time: DateTime.now(),
              text: strings.errorAnalyzePdfFailed(e),
            ),
          );
        });
        _persistNewMessages();
      } finally {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
      return;
    }

    /// TOOLS
    if (controller.step == ChatStep.freeInteraction) {
      final action = controller.onActionSelected(value);
      _persistNewMessages();
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
          controller.onToolPreviewGenerated(toolData: toolJson);
          controller.onToolGenerated(action);
        });
        _persistNewMessages();
      } catch (e) {
        setState(() {
          controller.messages.add(
            ChatMessage(
              isFromMishka: true,
              type: MessageType.system,
              time: DateTime.now(),
              text: strings.errorToolGenerationFailed(e),
            ),
          );
        });
        _persistNewMessages();
      }

      _scrollToBottom();
    }
  }

  // ================= CHAT =================
  Future<void> _handleSend(String text) async {
    final strings = _strings ?? ChatFlowStrings(AppLocalizations.of(context)!);

    if (controller.sessionId == null) {
      setState(() {
        controller.messages.add(
          ChatMessage(
            isFromMishka: true,
            type: MessageType.system,
            time: DateTime.now(),
            text: strings.waitForExplanation,
          ),
        );
      });
      _persistNewMessages();
      _scrollToBottom();
      return;
    }

    controller.onUserChatMessage(text);
    _persistNewMessages();
    _scrollToBottom();

    try {
      final reply = await ai.chat(
        sessionId: controller.sessionId!,
        message: text,
      );

      setState(() {
        controller.onMishkaChatReply(reply);
      });
      _persistNewMessages();
    } catch (e) {
      setState(() {
        controller.messages.add(
          ChatMessage(
            isFromMishka: true,
            type: MessageType.system,
            time: DateTime.now(),
            text: strings.errorChatFailed(e),
          ),
        );
      });
      _persistNewMessages();
    }

    _scrollToBottom();
  }

  // ================= HELPERS =================
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
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.screenBackground,
          appBar: MishkaAppBar(
            title: l10n.chatWithMishka,
            showBack: true,
            showBottomBar: true,
            onMenuTap: _openHistory,
            onBackTap: widget.onBack ?? () => Navigator.pop(context),
          ),
          body: _isRestoring
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : Column(
                  children: [
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
                        savedLibrary: _savedLibrary,
                        flowStrings: _strings,
                      );
                        },
                      ),
                    ),
                    if (_isLoading)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                  child: ChatInputBar(
                    typingEnabled: controller.isTypingEnabled,
                    controller: _inputController,
                    uploads: uploadedItems,
                    onPickFile: pickPdf,
                    onRemoveUpload: removePdf,
                    onSend: _handleSend,
                    uploadHint: l10n.chatUploadPdfHint,
                    chooseDifficultyHint: l10n.chatChooseDifficultyHint,
                    askHint: l10n.askMishka,
                  ),
                    ),
                  ],
                ),
        ),
        ChatHistoryDrawer(
          isOpen: _historyOpen,
          onClose: _closeHistory,
          data: _historyData,
          isLoading: _historyLoading,
          onChatSelected: _onHistorySessionSelected,
          onSessionSelected: _onHistorySessionSelected,
          onNewChat: () {
            _closeHistory();
            _startNewChat();
          },
        ),
      ],
    );
  }
}
