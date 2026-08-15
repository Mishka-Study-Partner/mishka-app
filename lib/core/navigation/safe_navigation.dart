import 'package:flutter/material.dart';

/// Wraps the app's root shell so the home route cannot be popped off the stack,
/// which would otherwise leave a blank screen with no way back.
class RootBackGuard extends StatelessWidget {
  const RootBackGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: child,
    );
  }
}

abstract final class SafeNavigator {
  static void popIfPossible(BuildContext context, [Object? result]) {
    final navigator = Navigator.maybeOf(context);
    if (navigator == null || !navigator.canPop()) return;
    navigator.pop(result);
  }
}
