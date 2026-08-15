import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Result / completion screen that fits one viewport — no body scroll.
class StudyResultScreenScaffold extends StatelessWidget {
  const StudyResultScreenScaffold({
    super.key,
    required this.illustration,
    required this.content,
    this.showCollectButton = true,
    this.onDone,
  });

  final Widget illustration;
  final Widget content;
  final bool showCollectButton;
  final VoidCallback? onDone;

  static double _illustrationMaxHeight(
    BoxConstraints constraints,
    BuildContext context,
  ) {
    final fraction = AppBreakpoints.isTablet(context) ? 0.40 : 0.44;
    final cap = AppBreakpoints.isTablet(context) ? 300.0 : 240.0;
    return (constraints.maxHeight * fraction).clamp(96.0, cap);
  }

  static double _contentGap(BoxConstraints constraints) {
    return (constraints.maxHeight * 0.03).clamp(8.0, 20.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.result,
        showBack: true,
        showBottomBar: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final imageMaxH =
                      _illustrationMaxHeight(constraints, context);
                  final gap = _contentGap(constraints);

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 11,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: imageMaxH,
                                maxWidth: constraints.maxWidth,
                              ),
                              child: illustration,
                            ),
                          ),
                        ),
                        SizedBox(height: gap),
                        Flexible(
                          flex: 10,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth,
                                ),
                                child: content,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (showCollectButton)
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 12.h),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onDone ??
                        () {
                          Navigator.of(context).pop();
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.mainGold,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                    ),
                    child: Text(
                      l10n.collectBadge,
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: AppSizes.fontSizeLarge,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(height: AppSizes.screenEndPadding),
          ],
        ),
      ),
    );
  }
}
