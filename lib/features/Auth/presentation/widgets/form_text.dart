import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';

class CustomInputField extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------- LABEL ----------------
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: "Pridi",
            fontSize: AppSizes.fontSizeLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.mainDark,
          ),
        ),
        SizedBox(height: 8.h),

        // ---------------- TEXT FIELD ----------------
        SizedBox(
          height: 44.h,
          width: double.infinity,
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscure : false,
            validator: widget.validator,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: AppColors.greyText,
                fontSize: AppSizes.fontSizeMedium,
              ),

              // Prefix widget (country flag + code OR icon)
              prefixIcon: widget.prefix != null
                  ? Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: 10.w,
                        end: 8.w,
                      ),
                      child: widget.prefix,
                    )
                  : null,

              // Password Toggle Icon
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.greyText,
                        size: AppSizes.iconSmall,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                    )
                  : null,

              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: 14.h,
              ),

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
            ),
          ),
        ),
      ],
    );
  }
}