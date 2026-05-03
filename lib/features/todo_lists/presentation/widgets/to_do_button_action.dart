import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
class TodoBottomActions extends StatelessWidget {
  final VoidCallback onAddTask;
  final VoidCallback onAddList;

  const TodoBottomActions({
    super.key,
    required this.onAddTask,
    required this.onAddList,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: onAddTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Add New Task",style: TextStyle(color: AppColors.white,fontSize: 12),),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: onAddList,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Add New List",style: TextStyle(color: AppColors.white,fontSize: 12),),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
