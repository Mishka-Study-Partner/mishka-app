import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/layout/app_scale.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';

class CustomInputField extends StatefulWidget {
  /// Vertical gap between stacked auth fields.
  static double get spacingBetweenFields => 16.h;

  /// Shared input box height for email, password, phone, etc.
  static double get fieldHeight => AppScale.h(48);

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final Widget? prefix;
  final String? Function(String?)? validator;

  const CustomInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.prefix,
    this.validator,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscure = true;

  InputDecoration _decoration(BuildContext context) {
    final height = CustomInputField.fieldHeight;
    final iconBox = Size(AppScale.w(44), height);

    return InputDecoration(
      isDense: true,
      hintText: widget.hint,
      hintStyle: TextStyle(
        color: AppColors.greyText,
        fontSize: AppSizes.fontSizeMedium,
      ),
      prefixIcon: widget.prefix != null
          ? Padding(
              padding: EdgeInsetsDirectional.only(
                start: 10.w,
                end: 8.w,
              ),
              child: widget.prefix,
            )
          : null,
      prefixIconConstraints: BoxConstraints(
        minWidth: iconBox.width,
        minHeight: iconBox.height,
        maxHeight: iconBox.height,
      ),
      suffixIcon: widget.isPassword
          ? IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: iconBox.width,
                maxWidth: iconBox.width,
                minHeight: iconBox.height,
                maxHeight: iconBox.height,
              ),
              icon: Icon(
                _obscure ? Icons.visibility_off : Icons.visibility,
                color: AppColors.greyText,
                size: AppSizes.iconSmall,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            )
          : null,
      suffixIconConstraints: BoxConstraints(
        minWidth: iconBox.width,
        minHeight: iconBox.height,
        maxHeight: iconBox.height,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppScale.h(12),
      ),
      constraints: BoxConstraints(minHeight: height),
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      errorMaxLines: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: "Pridi",
            fontSize: AppSizes.fontSizeLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.mainDark,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscure : false,
          validator: widget.validator,
          style: TextStyle(
            fontSize: AppSizes.fontSizeMedium,
            fontFamily: 'Pridi',
            height: 1.2,
          ),
          decoration: _decoration(context),
        ),
      ],
    );
  }
}