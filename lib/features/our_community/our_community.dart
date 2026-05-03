import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../Auth/presentation/widgets/custom_segmanted_button.dart';
class OurCommunity extends StatefulWidget {
  final VoidCallback? onBack;
  
  const OurCommunity({
    super.key,
    this.onBack,
  });

  @override
  State<OurCommunity> createState() => _OurCommunityState();
}

class _OurCommunityState extends State<OurCommunity> {
  int selectedIndex = 0; // 0 = Email, 1 = Phone

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: "Our Community",
        showBack: true,
        showBottomBar: false,
        onBackTap: widget.onBack,
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child:  CustomSegmentedButton(
              selectedIndex: selectedIndex,
              onChanged: (i) => setState(() => selectedIndex = i),
              segments: const ['Email', 'phone Number'],
            ),

          ),
          const SizedBox(height: 20),
          /*
          // Here content changes
          Expanded(
            child: selectedIndex == 0
                ? const EmailLoginForm()
                : const PhoneLoginForm(),
          ),
      */
        ],
      ),
    );
  }

}