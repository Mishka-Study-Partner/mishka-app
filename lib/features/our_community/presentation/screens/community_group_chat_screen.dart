import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/Auth/data/models/user_model.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/chat_input_bar.dart';
import 'package:mishka_app/features/saved/data/repositories/saved_repository.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_display_helper.dart';
import '../../community_styles.dart';
import '../../data/community_json_helpers.dart';
import '../../data/community_models.dart';
import '../../data/community_repository.dart';
import '../../utils/community_navigation.dart';
import '../share_saved_to_channel_flow.dart';
import '../widgets/community_action_menu.dart';
import '../widgets/community_chat_app_bar.dart';
import '../widgets/community_chat_bubble.dart';

class CommunityGroupChatScreen extends StatefulWidget {
  const CommunityGroupChatScreen({
    super.key,
    required this.community,
    required this.group,
    required this.repository,
  });

  final CommunityModel community;
  final CommunityGroupModel group;
  final CommunityRepository repository;

  @override
  State<CommunityGroupChatScreen> createState() =>
      _CommunityGroupChatScreenState();
}

class _CommunityGroupChatScreenState extends State<CommunityGroupChatScreen>
    with WidgetsBindingObserver {
  static const _pollInterval = Duration(seconds: 12);

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _savedRepository = SavedRepository();
  Timer? _pollTimer;

  late CommunityModel _community;
  bool _loading = true;
  bool _sending = false;
  bool _sharing = false;
  bool _channelJoined = false;
  String? _loadError;
  String _currentUserId = '';
  String _currentUserName = '';
  String _currentUserRole = 'Member';
  final Map<String, String> _memberNamesByUserId = {};
  final Map<String, String> _memberRolesByUserId = {};
  List<CommunityChatMessage> _messages = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _community = widget.community;
    _channelJoined = widget.group.joined;
    _loadCurrentUser();
    _loadMessages();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollMessagesQuietly());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _pollMessagesQuietly();
    }
  }

  bool _messagesChanged(
    List<CommunityChatMessage> previous,
    List<CommunityChatMessage> next,
  ) {
    if (previous.length != next.length) return true;
    if (previous.isEmpty) return false;
    return previous.last.id != next.last.id;
  }

  Future<void> _pollMessagesQuietly() async {
    if (!mounted || _loading || _sending || _sharing) return;
    try {
      final messages = await widget.repository.fetchChannelMessages(
        widget.community.id,
        widget.group.id,
      );
      if (!mounted || !_messagesChanged(_messages, messages)) return;
      setState(() => _messages = messages);
      _scrollToBottom();
    } catch (_) {}
  }

  void _loadCurrentUser() {
    final raw = AppPreferences.cachedUserJson;
    if (raw == null || raw.isEmpty) return;

    try {
      final user = UserModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
      _currentUserId = user.id;
      final full = user.fullName?.trim();
      if (full != null && full.isNotEmpty) {
        _currentUserName = full;
      } else {
        final combined = '${user.firstName} ${user.lastName}'.trim();
        if (combined.isNotEmpty) {
          _currentUserName = combined;
        } else if (user.username != null && user.username!.trim().isNotEmpty) {
          _currentUserName = user.username!.trim();
        }
      }
      if (_currentUserName.isNotEmpty) {
        _memberNamesByUserId[user.id] = _currentUserName;
      }
      _syncCurrentUserRole();
    } catch (_) {}
  }

  void _syncCurrentUserRole() {
    _currentUserRole = resolveCurrentUserCommunityRole(
      userId: _currentUserId,
      membershipRole: _community.myRole,
      ownerUserId: _community.ownerUserId,
      memberListRole: _memberRolesByUserId[_currentUserId],
    );
    if (_currentUserId.isNotEmpty) {
      _memberRolesByUserId[_currentUserId] = _currentUserRole;
    }
  }

  String _senderDisplayLabel(CommunityChatMessage message) {
    final l10n = AppLocalizations.of(context)!;
    if (message.isMishka) return l10n.communityBrandMishka;
    if (_isOwnMessage(message)) return l10n.communityChatSenderMe;

    // Backend `senderDisplay` is authoritative when present.
    final apiName = message.senderName.trim();
    if (apiName.isNotEmpty && apiName.toLowerCase() != 'member') {
      return apiName;
    }

    if (message.senderUserId.isNotEmpty) {
      final mapped = _memberNamesByUserId[message.senderUserId];
      if (mapped != null && mapped.isNotEmpty) return mapped;
    }

    return communityMemberDisplayName('', l10n);
  }

  String? _senderRoleLabel(CommunityChatMessage message) {
    if (message.isMishka) return null;

    final l10n = AppLocalizations.of(context)!;
    final String raw;
    if (message.senderRole.isNotEmpty) {
      raw = message.senderRole;
    } else {
      final userId = message.senderUserId.isNotEmpty
          ? message.senderUserId
          : (_isOwnMessage(message) ? _currentUserId : '');
      raw = resolveMemberCommunityRole(
        userId: userId,
        rawRole: _isOwnMessage(message) ? _community.myRole : null,
        ownerUserId: _community.ownerUserId,
        memberListRole:
            userId.isNotEmpty ? _memberRolesByUserId[userId] : null,
      );
    }
    if (raw.isEmpty) return null;
    return communityRoleDisplayLabel(raw, l10n);
  }

  Future<void> _ensureChannelJoined() async {
    if (_channelJoined) return;
    await widget.repository.ensureChannelJoined(
      widget.community.id,
      widget.group.id,
    );
    _channelJoined = true;
  }

  String _errorMessage(Object error) {
    if (error is ApiException) return error.message;
    return error.toString();
  }

  bool _isOwnMessage(CommunityChatMessage message) {
    if (_currentUserId.isNotEmpty &&
        message.senderUserId.isNotEmpty &&
        message.senderUserId == _currentUserId) {
      return true;
    }
    return message.senderName == _currentUserName;
  }

  Future<void> _loadMessages() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      await _ensureChannelJoined();
      final bundle = await widget.repository.loadChatBundle(
        widget.community.id,
        widget.group.id,
        seedCommunity: _community,
      );
      if (!mounted) return;
      setState(() {
        _community = bundle.community;
        _messages = bundle.messages;
        _loading = false;
        if (_currentUserId.isNotEmpty && _currentUserName.isNotEmpty) {
          _memberNamesByUserId[_currentUserId] = _currentUserName;
        }
        _syncCurrentUserRole();
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = _errorMessage(e);
      });
    }
  }

  Future<void> _send(String text) async {
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      await _ensureChannelJoined();
      final message = await widget.repository.postMessage(
        widget.community.id,
        widget.group.id,
        text,
      );
      if (!mounted) return;
      setState(() {
        _messages = [
          ..._messages,
          CommunityChatMessage(
            id: message.id,
            senderName: message.senderName,
            senderUserId:
                message.senderUserId.isEmpty ? _currentUserId : message.senderUserId,
            senderRole: message.senderRole.isNotEmpty
                ? message.senderRole
                : _currentUserRole,
            text: message.text,
            sentAt: message.sentAt ?? DateTime.now(),
            isMishka: message.isMishka,
            isShared: message.isShared,
          ),
        ];
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      CommunityStyles.showSnackBar(context, _errorMessage(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _shareSavedMaterial() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      await _ensureChannelJoined();
      if (!mounted) return;
      await shareSavedMaterialToChannel(
        context: context,
        repository: _savedRepository,
        communityId: widget.community.id,
        channelId: widget.group.id,
        knownMessages: _messages,
        onShared: _loadMessages,
      );
    } catch (e) {
      if (!mounted) return;
      CommunityStyles.showSnackBar(context, _errorMessage(e));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommunityChatAppBar(
        community: _community,
        onMenuTap: () => CommunityActionMenu.show(
          context,
          community: _community,
          repository: widget.repository,
          onChanged: _loadMessages,
          onLeftCommunity: () {
            if (mounted) {
              Navigator.pop(context, communityLeftRouteResult);
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _loadError != null
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _loadError!,
                                textAlign: TextAlign.center,
                                style: CommunityStyles.error,
                              ),
                              SizedBox(height: 12.h),
                              TextButton(
                                onPressed: _loadMessages,
                                child: Text(l10n.retry),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMessages,
                        child: _messages.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: AppScrollInsets.list(top: 8.h),
                                children: [
                                  SizedBox(height: 48.h),
                                  Center(
                                    child: Text(
                                      l10n.communityChatEmpty,
                                      style: CommunityStyles.caption,
                                    ),
                                  ),
                                  const ScreenEndSpacer(),
                                ],
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: AppScrollInsets.list(top: 8.h, bottom: 12.h),
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final message = _messages[index];
                                  return CommunityChatBubble(
                                    message: message,
                                    senderLabel: _senderDisplayLabel(message),
                                    senderRoleLabel: _senderRoleLabel(message),
                                    isOwnMessage: _isOwnMessage(message),
                                  );
                                },
                              ),
                      ),
          ),
          if (_sharing)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom +
                  AppSizes.screenEndPadding,
            ),
            child: ChatInputBar(
              typingEnabled: !_sending && !_sharing,
              controller: _messageController,
              uploads: const [],
              onPickFile: _shareSavedMaterial,
              onRemoveUpload: (_) {},
              onSend: _send,
              uploadHint: l10n.shareToCommunityChannels,
              chooseDifficultyHint: l10n.askMishka,
              askHint: l10n.communityChatTypeHint,
            ),
          ),
        ],
      ),
    );
  }
}
