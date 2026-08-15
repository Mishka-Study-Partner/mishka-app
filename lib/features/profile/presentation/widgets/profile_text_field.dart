import 'package:flutter/material.dart';

import 'package:mishka_app/features/profile/presentation/widgets/profile_field_metrics.dart';

class ProfileTextField extends StatelessWidget {
  final String label;
  final String value;

  const ProfileTextField({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ProfileFieldMetrics.labelStyle(context)),
        SizedBox(height: ProfileFieldMetrics.labelGap(context)),
        Container(
          width: double.infinity,
          height: ProfileFieldMetrics.fieldHeight(context),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(
            horizontal: ProfileFieldMetrics.horizontalPad(context),
          ),
          decoration: BoxDecoration(
            color: ProfileFieldMetrics.fieldBackground(context),
            borderRadius: BorderRadius.circular(
              ProfileFieldMetrics.fieldRadius(context),
            ),
            border: Border.all(color: ProfileFieldMetrics.fieldBorder(context)),
          ),
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ProfileFieldMetrics.valueStyle(context),
          ),
        ),
      ],
    );
  }
}
