import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/uiw.dart';

import '../../../../core/utils/app_colors.dart';
import '../../data/model/uploaded_item.dart';


import 'package:iconify_flutter/icons/ph.dart';

class UploadOptionsMenu extends StatelessWidget {
  final void Function(UploadType) onSelect;

  const UploadOptionsMenu({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 190,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        children: [
          _OptionItem(
            icon: Uiw.file_excel,
            label: 'Upload Files',
            onTap: () => onSelect(UploadType.file),
          ),
          _OptionItem(
            icon: Uiw.file_pdf,
            label: 'Upload PDF',
            onTap: () => onSelect(UploadType.pdf),
          ),
          _OptionItem(
            icon: Ph.image,
            label: 'Upload Image',
            onTap: () => onSelect(UploadType.image),
          ),
          _OptionItem(
            icon: Ph.video_camera_bold,
            label: 'Upload Video',
            onTap: () => onSelect(UploadType.video),
          ),


        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Iconify(icon, size: 16, color: AppColors.mainGold),
               SizedBox(width: 10.w),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
