import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_styles.dart';
import '../../data/community_current_user.dart';
import '../../data/community_error_helpers.dart';
import '../../data/community_invite_helpers.dart';
import '../../data/community_models.dart';
import '../../data/community_repository.dart';
import '../screens/edit_community_screen.dart';
import 'community_dialogs.dart';
import 'community_share_copy_field.dart';

class CommunityActionMenu extends StatefulWidget {
  const CommunityActionMenu({
    super.key,
    required this.community,
    required this.repository,
    this.onChanged,
  });

  final CommunityModel community;
  final CommunityRepository repository;
  final VoidCallback? onChanged;

  static Future<void> show(
    BuildContext context, {
    required CommunityModel community,
    required CommunityRepository repository,
    VoidCallback? onChanged,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: CommunityActionMenu(
          community: community,
          repository: repository,
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  State<CommunityActionMenu> createState() => _CommunityActionMenuState();
}

class _CommunityActionMenuState extends State<CommunityActionMenu> {
  bool _shareExpanded = true;
  CommunityInviteInfo? _invite;

  bool get _canManage {
    final userId = readCachedCurrentUserId();
    if (userId != null) return widget.community.canManageFor(userId);
    return widget.community.canManage;
  }

  Future<CommunityInviteInfo> _loadInvite() async {
    _invite ??= await widget.repository.getInvite(
      widget.community.id,
      community: widget.community,
    );
    return _invite!;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final boxDecoration = BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      border: Border.all(color: AppColors.lightText, width: 1.2),
    );

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.lightFrameBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_canManage)
              _MenuRow(
                decoration: boxDecoration,
                icon: Icons.edit_calendar_outlined,
                label: l10n.communityEditCommunity,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => EditCommunityScreen(
                        community: widget.community,
                        repository: widget.repository,
                        onSaved: widget.onChanged,
                      ),
                    ),
                  );
                },
              ),
            if (_canManage) SizedBox(height: 14.h),
            Container(
              decoration: boxDecoration,
              child: Column(
                children: [
                  InkWell(
                    onTap: () => setState(() => _shareExpanded = !_shareExpanded),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      child: Row(
                        children: [
                          Icon(Icons.share_outlined, color: AppColors.mainGold, size: 28.w),
                          SizedBox(width: 16.w),
                          Text(
                            l10n.communityShareMenuTitle,
                            style: CommunityStyles.menuTitle,
                          ),
                          const Spacer(),
                          Icon(
                            _shareExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: AppColors.lightText,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_shareExpanded)
                    Padding(
                      padding: EdgeInsets.only(left: 60.w, bottom: 16.h, right: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ShareOption(
                            title: l10n.communityShareSendLink,
                            onTap: () => _openShareDialog(
                              context,
                              SendLinkDialog(
                                community: widget.community,
                                loader: _loadInvite,
                              ),
                            ),
                          ),
                          _ShareOption(
                            title: l10n.communityShareCreateCode,
                            onTap: () => _openShareDialog(
                              context,
                              GetCodeDialog(
                                community: widget.community,
                                loader: _loadInvite,
                                repository: widget.repository,
                              ),
                            ),
                          ),
                          _ShareOption(
                            title: l10n.communityShareInsertEmail,
                            onTap: () => _openShareDialog(
                              context,
                              InsertEmailDialog(
                                communityId: widget.community.id,
                                repository: widget.repository,
                              ),
                            ),
                          ),
                          _ShareOption(
                            title: l10n.communityShareInsertUsername,
                            onTap: () => _openShareDialog(
                              context,
                              InsertUsernameDialog(
                                communityId: widget.community.id,
                                repository: widget.repository,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            _MenuRow(
              decoration: boxDecoration,
              icon: widget.community.isPinned
                  ? Icons.bookmark_remove_outlined
                  : Icons.bookmark_add_outlined,
              label: widget.community.isPinned
                  ? l10n.communityUnsave
                  : l10n.communitySave,
              onTap: () async {
                Navigator.pop(context);
                final wasPinned = widget.community.isPinned;
                try {
                  if (wasPinned) {
                    await widget.repository.unpinCommunity(widget.community.id);
                  } else {
                    await widget.repository.pinCommunity(widget.community.id);
                  }
                  if (!context.mounted) return;
                  await showCommunitySuccessDialog(
                    context,
                    message: wasPinned
                        ? l10n.communityUnsavedSuccess
                        : l10n.communitySavedSuccess,
                  );
                  widget.onChanged?.call();
                } catch (e) {
                  if (!context.mounted) return;
                  CommunityStyles.showSnackBar(
                    context,
                    communityErrorMessage(e, l10n: l10n),
                  );
                }
              },
            ),
            if (_canManage) ...[
              SizedBox(height: 14.h),
              _MenuRow(
                decoration: boxDecoration,
                icon: Icons.delete_outline_rounded,
                label: l10n.communityDeleteCommunity,
                onTap: () async {
                  Navigator.pop(context);
                  final confirmed = await showCommunityConfirmDialog(
                    context,
                    message: l10n.communityDeleteConfirm,
                  );
                  if (confirmed != true || !context.mounted) return;
                  try {
                    await widget.repository.deleteCommunity(widget.community.id);
                    if (!context.mounted) return;
                    await showCommunitySuccessDialog(
                      context,
                      message: l10n.communityDeletedSuccess,
                      onDismiss: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    CommunityStyles.showSnackBar(context, '$e');
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openShareDialog(BuildContext context, Widget dialog) {
    Navigator.pop(context);
    showDialog<void>(context: context, builder: (_) => dialog);
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.decoration,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final BoxDecoration decoration;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: decoration,
        child: Row(
          children: [
            Icon(icon, color: AppColors.mainGold, size: 28.w),
            SizedBox(width: 16.w),
            Text(
              label,
              style: CommunityStyles.menuTitle,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Text(
          title,
          style: CommunityStyles.menuItem,
        ),
      ),
    );
  }
}

class _BaseShareDialog extends StatelessWidget {
  const _BaseShareDialog({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: child,
      ),
    );
  }
}

class SendLinkDialog extends StatelessWidget {
  const SendLinkDialog({
    super.key,
    required this.community,
    required this.loader,
  });

  final CommunityModel community;
  final Future<CommunityInviteInfo> Function() loader;

  @override
  Widget build(BuildContext context) {
    return _BaseShareDialog(
      child: FutureBuilder<CommunityInviteInfo>(
        future: loader(),
        builder: (context, snapshot) {
          final l10n = AppLocalizations.of(context)!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.communityShareDialogTitle,
                style: CommunityStyles.dialogTitle,
              ),
              if (community.isPublic) ...[
                SizedBox(height: 6.h),
                Text(
                  l10n.communitySharePublicLinkHint,
                  style: CommunityStyles.caption,
                ),
              ],
              SizedBox(height: 12.h),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (snapshot.hasError)
                Text(
                  communityErrorMessage(snapshot.error!, l10n: l10n),
                  style: CommunityStyles.error,
                )
              else
                CommunityShareCopyField(
                  value: snapshot.data?.shareUrl ??
                      'https://www.mishkacommunity.com/communities/${community.id}',
                ),
            ],
          );
        },
      ),
    );
  }
}

class GetCodeDialog extends StatefulWidget {
  const GetCodeDialog({
    super.key,
    required this.community,
    required this.loader,
    required this.repository,
  });

  final CommunityModel community;
  final Future<CommunityInviteInfo> Function() loader;
  final CommunityRepository repository;

  @override
  State<GetCodeDialog> createState() => _GetCodeDialogState();
}

class _GetCodeDialogState extends State<GetCodeDialog> {
  CommunityInviteInfo? _invite;
  String? _error;
  bool _loading = true;
  bool _regenerating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final invite = await widget.loader();
      if (!mounted) return;
      setState(() {
        _invite = invite;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = communityErrorMessage(
          e,
          l10n: AppLocalizations.of(context)!,
        );
        _loading = false;
      });
    }
  }

  Future<void> _regenerate() async {
    if (widget.community.isPublic) return;
    setState(() => _regenerating = true);
    try {
      final invite = await widget.repository.regenerateInvite(
        widget.community.id,
        community: widget.community,
      );
      if (!mounted) return;
      setState(() {
        _invite = invite;
        _regenerating = false;
      });
    } catch (e) {
      if (!mounted) return;
      CommunityStyles.showSnackBar(
        context,
        communityErrorMessage(e, l10n: AppLocalizations.of(context)!),
      );
      setState(() => _regenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final code = _invite?.inviteCode ?? '';
    final showRegenerate = !widget.community.isPublic;

    return _BaseShareDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.communityShareDialogTitle,
            style: CommunityStyles.dialogTitle,
          ),
          SizedBox(height: 6.h),
          Text(
            widget.community.isPublic
                ? l10n.communitySharePublicCodeHint
                : l10n.communitySharePrivateCodeHint,
            style: CommunityStyles.caption,
          ),
          SizedBox(height: 12.h),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Text(_error!, style: CommunityStyles.error)
          else ...[
            Text(l10n.communityShareYourCode, style: CommunityStyles.bodyBold),
            SizedBox(height: 8.h),
            CommunityShareCopyField(
              value: code.isEmpty ? '…' : code,
              icon: Icons.tag,
            ),
            if (showRegenerate) ...[
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _regenerating ? null : _regenerate,
                  icon: _regenerating
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.refresh, color: AppColors.green, size: 20.w),
                  label: Text(
                    l10n.communityShareGenerateNewCode,
                    style: CommunityStyles.outlineAction(AppColors.green),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class InsertEmailDialog extends StatefulWidget {
  const InsertEmailDialog({
    super.key,
    required this.communityId,
    required this.repository,
  });

  final String communityId;
  final CommunityRepository repository;

  @override
  State<InsertEmailDialog> createState() => _InsertEmailDialogState();
}

class _InsertEmailDialogState extends State<InsertEmailDialog> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _controller.text.trim();
    if (email.isEmpty) return;
    if (isSelfInviteTarget(email, readCachedUser())) {
      CommunityStyles.showSnackBar(context, l10n.communityInviteCannotInviteSelf);
      return;
    }
    setState(() => _sending = true);
    try {
      await widget.repository.inviteMemberByEmail(widget.communityId, email);
      if (!mounted) return;
      Navigator.pop(context);
      CommunityStyles.showSnackBar(
        context,
        AppLocalizations.of(context)!.communityInviteEmailSent(email),
      );
    } catch (e) {
      if (!mounted) return;
      CommunityStyles.showSnackBar(
        context,
        communityErrorMessage(e, l10n: AppLocalizations.of(context)!),
      );
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _BaseShareDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.communityShareDialogTitle,
            style: CommunityStyles.dialogTitle,
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.communityInviteRequiresAccount,
            style: CommunityStyles.caption,
          ),
          SizedBox(height: 14.h),
          Text(l10n.communityShareInsertEmail, style: CommunityStyles.sectionLabel),
          SizedBox(height: 6.h),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.emailAddress,
            decoration: CommunityStyles.inputDecoration(l10n.communityInviteEmailHint),
            enabled: !_sending,
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: CommunityStyles.goldButtonStyle(),
              onPressed: _sending ? null : _send,
              child: _sending
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(l10n.communityInviteSend),
            ),
          ),
        ],
      ),
    );
  }
}

class InsertUsernameDialog extends StatefulWidget {
  const InsertUsernameDialog({
    super.key,
    required this.communityId,
    required this.repository,
  });

  final String communityId;
  final CommunityRepository repository;

  @override
  State<InsertUsernameDialog> createState() => _InsertUsernameDialogState();
}

class _InsertUsernameDialogState extends State<InsertUsernameDialog> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    final username = normalizeInviteUsername(_controller.text);
    if (username.isEmpty) return;
    if (isSelfInviteTarget(username, readCachedUser())) {
      CommunityStyles.showSnackBar(context, l10n.communityInviteCannotInviteSelf);
      return;
    }
    setState(() => _sending = true);
    try {
      await widget.repository.inviteMemberByUsername(
        widget.communityId,
        username,
      );
      if (!mounted) return;
      Navigator.pop(context);
      CommunityStyles.showSnackBar(
        context,
        AppLocalizations.of(context)!.communityInviteUsernameSent(username),
      );
    } catch (e) {
      if (!mounted) return;
      CommunityStyles.showSnackBar(
        context,
        communityErrorMessage(e, l10n: AppLocalizations.of(context)!),
      );
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _BaseShareDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.communityShareDialogTitle,
            style: CommunityStyles.dialogTitle,
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.communityInviteRequiresAccount,
            style: CommunityStyles.caption,
          ),
          SizedBox(height: 14.h),
          Text(
            l10n.communityShareInsertUsername,
            style: CommunityStyles.sectionLabel,
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: _controller,
            decoration: CommunityStyles.inputDecoration(
              l10n.communityInviteUsernameHint,
            ),
            enabled: !_sending,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _sending ? null : _send(),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: CommunityStyles.goldButtonStyle(),
              onPressed: _sending ? null : _send,
              child: _sending
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(l10n.communityInviteSend),
            ),
          ),
        ],
      ),
    );
  }
}
