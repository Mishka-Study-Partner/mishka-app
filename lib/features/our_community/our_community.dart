import 'package:flutter/material.dart';

import 'presentation/screens/community_hub_screen.dart';

/// Entry point for the Our Community feature (Category → Our Community).
class OurCommunity extends StatelessWidget {
  const OurCommunity({
    super.key,
    this.onBack,
    this.scrollToSaved = false,
  });

  final VoidCallback? onBack;
  final bool scrollToSaved;

  @override
  Widget build(BuildContext context) {
    return CommunityHubScreen(
      onBack: onBack,
      scrollToSaved: scrollToSaved,
    );
  }
}
