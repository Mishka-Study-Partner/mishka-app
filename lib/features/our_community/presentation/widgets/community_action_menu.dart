import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_styles.dart';
import '../../data/community_current_user.dart';
import '../../data/community_error_helpers.dart';
import '../../data/community_models.dart';
import '../../data/community_repository.dart';
import '../screens/edit_community_screen.dart';
import 'community_dialogs.dart';

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
    _invite ??= await widget.repository.getInvite(widget.community.id);
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
                label: 'Edit Community',
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
                            'Share Community',
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
                            title: 'Send Link',
                            onTap: () => _openShareDialog(
                              context,
                              SendLinkDialog(loader: _loadInvite),
                            ),
                          ),
                          _ShareOption(
                            title: 'Create code',
                            onTap: () => _openShareDialog(
                              context,
                              GetCodeDialog(
                                communityId: widget.community.id,
                                loader: _loadInvite,
                                repository: widget.repository,
                              ),
                            ),
                          ),
                          _ShareOption(
                            title: 'Insert Email',
                            onTap: () => _openShareDialog(context, const InsertEmailDialog()),
                          ),
                          _ShareOption(
                            title: 'Insert User Name',
                            onTap: () => _openShareDialog(context, const InsertUsernameDialog()),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        communityErrorMessage(e),
                        style: CommunityStyles.snackBar,
                      ),
                    ),
                  );
                }
              },
            ),
            if (_canManage) ...[
              SizedBox(height: 14.h),
              _MenuRow(
                decoration: boxDecoration,
                icon: Icons.delete_outline_rounded,
                label: 'Delete Community',
                onTap: () async {
                  Navigator.pop(context);
                  final confirmed = await showCommunityConfirmDialog(
                    context,
                    message: 'Are you sure you want to delete the community?',
                  );
                  if (confirmed != true || !context.mounted) return;
                  try {
                    await widget.repository.deleteCommunity(widget.community.id);
                    if (!context.mounted) return;
                    await showCommunitySuccessDialog(
                      context,
                      message: 'Community deleted successfully!',
                      onDismiss: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$e', style: CommunityStyles.snackBar)),
                    );
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
  const SendLinkDialog({super.key, required this.loader});

  final Future<CommunityInviteInfo> Function() loader;

  @override
  Widget build(BuildContext context) {
    return _BaseShareDialog(
      child: FutureBuilder<CommunityInviteInfo>(
        future: loader(),
        builder: (context, snapshot) {
          final invite = snapshot.data;
          final linkUrl = invite?.shareUrl ?? 'https://www.mishkacommunity.com';
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share Community:',
                style: CommunityStyles.dialogTitle,
              ),
              SizedBox(height: 12.h),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: linkUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Link copied to clipboard!',
                          style: CommunityStyles.snackBar,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: AppColors.mainGold),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.link, color: AppColors.green, size: 18.w),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            linkUrl,
                            style: CommunityStyles.link,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
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
    required this.communityId,
    required this.loader,
    required this.repository,
  });

  final String communityId;
  final Future<CommunityInviteInfo> Function() loader;
  final CommunityRepository repository;

  @override
  State<GetCodeDialog> createState() => _GetCodeDialogState();
}

class _GetCodeDialogState extends State<GetCodeDialog> {
  CommunityInviteInfo? _invite;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final invite = await widget.loader();
    if (!mounted) return;
    setState(() => _invite = invite);
  }

  Future<void> _regenerate() async {
    final invite = await widget.repository.regenerateInvite(widget.communityId);
    if (!mounted) return;
    setState(() => _invite = invite);
  }

  @override
  Widget build(BuildContext context) {
    final code = _invite?.inviteCode ?? '…';
    return _BaseShareDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share Community:',
            style: CommunityStyles.dialogTitle,
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: AppColors.mainGold),
            ),
            child: Row(
              children: [
                Text(
                  'Your Code: ',
                  style: CommunityStyles.bodyBold,
                ),
                Text(code, style: CommunityStyles.caption),
                const Spacer(),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.copy, color: AppColors.green, size: 20.w),
                  onPressed: () => Clipboard.setData(ClipboardData(text: code)),
                ),
                SizedBox(width: 10.w),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.refresh, color: AppColors.green, size: 20.w),
                  onPressed: _regenerate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InsertEmailDialog extends StatefulWidget {
  const InsertEmailDialog({super.key});

  @override
  State<InsertEmailDialog> createState() => _InsertEmailDialogState();
}

class _InsertEmailDialogState extends State<InsertEmailDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BaseShareDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share Community:',
            style: CommunityStyles.dialogTitle,
          ),
          SizedBox(height: 14.h),
          Text('Insert Email:', style: CommunityStyles.sectionLabel),
          SizedBox(height: 6.h),
          TextField(
            controller: _controller,
            decoration: CommunityStyles.inputDecoration('Email address'),
          ),
        ],
      ),
    );
  }
}

class InsertUsernameDialog extends StatefulWidget {
  const InsertUsernameDialog({super.key});

  @override
  State<InsertUsernameDialog> createState() => _InsertUsernameDialogState();
}

class _InsertUsernameDialogState extends State<InsertUsernameDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BaseShareDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share Community:',
            style: CommunityStyles.dialogTitle,
          ),
          SizedBox(height: 14.h),
          Text('Insert User Name:', style: CommunityStyles.sectionLabel),
          SizedBox(height: 6.h),
          TextField(
            controller: _controller,
            decoration: CommunityStyles.inputDecoration('Username'),
          ),
        ],
      ),
    );
  }
}
