import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Live password rules checklist (reset / sign-up design).
class PasswordRequirementsCard extends StatelessWidget {
  const PasswordRequirementsCard({super.key, required this.password});

  final String password;

  bool get _lengthOk => password.length >= 8 && password.length <= 20;
  bool get _upperOk => RegExp(r'[A-Z]').hasMatch(password);
  bool get _numberOk => RegExp(r'[0-9]').hasMatch(password);
  bool get _specialOk =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/`~]').hasMatch(password);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.passwordRequirements,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: AppSizes.fontSizeMedium,
              fontWeight: FontWeight.w600,
              color: AppColors.mainDark,
            ),
          ),
          SizedBox(height: 10.h),
          _RequirementRow(met: _lengthOk, label: l10n.passwordRequirement1),
          _RequirementRow(met: _upperOk, label: l10n.passwordRequirement2),
          _RequirementRow(met: _numberOk, label: l10n.passwordRequirement3),
          _RequirementRow(met: _specialOk, label: l10n.passwordRequirement4),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.met, required this.label});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 18.w,
            height: 18.w,
            child: met
                ? Icon(Icons.check_circle, size: 18.w, color: AppColors.mainGold)
                : Icon(
                    Icons.circle_outlined,
                    size: 18.w,
                    color: AppColors.greyText,
                  ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeSmall,
                fontWeight: FontWeight.w500,
                color: AppColors.mainDark,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
