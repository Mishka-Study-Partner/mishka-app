import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/features/Auth/view/bloc/auth_bloc.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../community_styles.dart';
import '../data/community_error_helpers.dart';
import '../data/community_invite_deep_link_coordinator.dart';
import '../data/community_repository.dart';
import 'screens/community_home_screen.dart';
import 'widgets/community_dialogs.dart';

/// Runs [POST /communities/join] when a queued invite link is available and the
/// user is signed in on the main shell.
class CommunityInviteDeepLinkHost extends StatefulWidget {
  const CommunityInviteDeepLinkHost({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<CommunityInviteDeepLinkHost> createState() =>
      _CommunityInviteDeepLinkHostState();
}

class _CommunityInviteDeepLinkHostState extends State<CommunityInviteDeepLinkHost> {
  final _repository = CommunityRepository();
  final _coordinator = CommunityInviteDeepLinkCoordinator.instance;
  bool _joining = false;

  @override
  void initState() {
    super.initState();
    _coordinator.addListener(_onPendingChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryJoinFromPending());
  }

  @override
  void dispose() {
    _coordinator.removeListener(_onPendingChanged);
    super.dispose();
  }

  void _onPendingChanged() {
    _tryJoinFromPending();
  }

  Future<void> _tryJoinFromPending() async {
    if (_joining || !mounted) return;
    if (_coordinator.pending == null) return;

    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthSuccess) return;
    if (!AppPreferences.hasCompletedEducationSetup) return;

    final link = _coordinator.pending!;
    _joining = true;
    await _coordinator.clearPending();

    final l10n = AppLocalizations.of(context)!;
    try {
      final community = await _repository.joinFromInviteLink(link);
      if (!mounted) return;
      await showCommunitySuccessDialog(
        context,
        message: l10n.communityJoinPrivateSuccess,
      );
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => CommunityHomeScreen(
            community: community,
            repository: _repository,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      CommunityStyles.showSnackBar(
        context,
        communityErrorMessage(e, l10n: l10n),
      );
      await _coordinator.restorePending(link);
    } finally {
      _joining = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthSuccess && previous is! AuthSuccess,
      listener: (_, __) => _tryJoinFromPending(),
      child: widget.child,
    );
  }
}
