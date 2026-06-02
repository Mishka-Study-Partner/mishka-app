import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';

/// Square OTP boxes (auth design).
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
  });

  final int length;
  final void Function(String code)? onChanged;
  final void Function(String code)? onCompleted;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(widget.length, (_) => TextEditingController());
    focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => controllers.map((c) => c.text).join();

  void _notify() {
    widget.onChanged?.call(_code);
    if (controllers.every((c) => c.text.isNotEmpty)) {
      widget.onCompleted?.call(_code);
    }
  }

  void _onChanged(String value, int index) {
    if (value.length > 1) {
      controllers[index].text = value.substring(value.length - 1);
      controllers[index].selection = TextSelection.collapsed(
        offset: controllers[index].text.length,
      );
    }

    if (value.isNotEmpty && index < widget.length - 1) {
      focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    final boxSize = 48.w;
    final gap = 10.w;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Padding(
          padding: EdgeInsetsDirectional.only(
            end: index < widget.length - 1 ? gap : 0,
          ),
          child: SizedBox(
            width: boxSize,
            height: boxSize,
            child: TextField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              maxLength: 1,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                fontSize: AppSizes.fontSizeXLarge,
                fontWeight: FontWeight.w600,
                fontFamily: 'Pridi',
                color: AppColors.mainDark,
              ),
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: const BorderSide(color: AppColors.stroke),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: const BorderSide(
                    color: AppColors.mainGold,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (v) => _onChanged(v, index),
            ),
          ),
        );
      }),
    );
  }
}
