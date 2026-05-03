import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:iconify_flutter/icons/uiw.dart';

import '../../../../core/utils/app_colors.dart';
import '../../data/model/uploaded_item.dart';

class UploadedFileCard extends StatelessWidget {
  final UploadedItem item;
  final VoidCallback onRemove;

  const UploadedFileCard({
    super.key,
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(
                  Icons.close,
                  size: 12,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4), // ✅ reduced spacing

          Row(
            children: [
              Iconify(
                _iconForType(item.type),
                size: 14,
                color: AppColors.mainGold,
              ),
              const SizedBox(width: 6),
              Text(
                item.type.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


String _iconForType(UploadType type) {
  switch (type) {
    case UploadType.file:
      return Uiw.file_excel;

    case UploadType.pdf:
      return Uiw.file_pdf;

    case UploadType.image:
      return Ph.image;

    case UploadType.video:
      return Ph.video_camera_bold;


    default:
      return Uiw.file_excel;
  }
}

