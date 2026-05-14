import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/todo_lists/data/models/list_item_model.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key, this.lists = const [], this.preselectedListId});

  final List<TodoListItemModel> lists;
  final String? preselectedListId;

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  String? _selectedListId;
  int _selectedHour = 7;
  int _selectedMinute = 0;
  bool _isPM = true;

  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;
  late final FixedExtentScrollController _ampmController;

  @override
  void initState() {
    super.initState();
    _selectedListId = widget.preselectedListId ?? widget.lists.firstOrNull?.id;
    _hourController = FixedExtentScrollController(initialItem: _selectedHour - 1);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute ~/ 15);
    _ampmController = FixedExtentScrollController(initialItem: _isPM ? 1 : 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _ampmController.dispose();
    super.dispose();
  }

  void _save() {
    DateTime? deadline;
    final day = int.tryParse(_dayController.text.trim());
    final month = int.tryParse(_monthController.text.trim());
    final year = int.tryParse(_yearController.text.trim());
    if (day != null && month != null && year != null) {
      var hour24 = _selectedHour;
      if (_isPM && hour24 != 12) hour24 += 12;
      if (!_isPM && hour24 == 12) hour24 = 0;
      deadline = DateTime(year, month, day, hour24, _selectedMinute);
    }
    Navigator.pop(context, {
      'title': _titleController.text.trim(),
      'deadline': deadline,
      'listId': _selectedListId,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width * 0.85;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: width,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            border: Border.all(color: AppColors.stroke),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.add_box_outlined, color: AppColors.mainDark, size: 18.w),
                    SizedBox(width: 6.w),
                    Text(
                      l10n.addNewTask,
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mainDark,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                // --- List selector row ---
                Row(
                  children: [
                    Expanded(
                      child: _buildListDropdown(l10n),
                    ),
                    SizedBox(width: 8.w),
                    _buildAddNewListButton(l10n),
                  ],
                ),

                SizedBox(height: 18.h),

                // --- Task label ---
                Text(
                  l10n.theTask,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainDark,
                  ),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: _titleController,
                  style: TextStyle(fontFamily: 'Pridi', fontSize: 13.sp),
                  decoration: InputDecoration(
                    hintText: l10n.typeYourTaskHere,
                    hintStyle: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: 12.sp,
                      color: AppColors.greyText,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: AppColors.stroke),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: AppColors.stroke),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: AppColors.mainGold),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // --- Date label + fields ---
                Text(
                  l10n.date,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainDark,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Expanded(child: _miniField(_dayController, l10n.day)),
                    SizedBox(width: 6.w),
                    Expanded(child: _miniField(_monthController, l10n.month)),
                    SizedBox(width: 6.w),
                    Expanded(child: _miniField(_yearController, l10n.year)),
                  ],
                ),

                SizedBox(height: 16.h),

                // --- Time picker ---
                Text(
                  l10n.time,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainDark,
                  ),
                ),
                SizedBox(height: 6.h),
                _buildTimePicker(),

                SizedBox(height: 20.h),

                // --- Buttons ---
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40.h,
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainGold,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.save,
                            style: TextStyle(
                              color: AppColors.white,
                              fontFamily: 'Pridi',
                              fontSize: 13.sp,
                              height: 1.0,
                            ),
                            strutStyle: StrutStyle(
                              fontFamily: 'Pridi',
                              fontSize: 13.sp,
                              height: 1.4,
                              leading: 0,
                              forceStrutHeight: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: SizedBox(
                        height: 40.h,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            l10n.cancel,
                            style: TextStyle(
                              color: AppColors.red,
                              fontFamily: 'Pridi',
                              fontSize: 13.sp,
                              height: 1.0,
                            ),
                            strutStyle: StrutStyle(
                              fontFamily: 'Pridi',
                              fontSize: 13.sp,
                              height: 1.4,
                              leading: 0,
                              forceStrutHeight: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListDropdown(AppLocalizations l10n) {
    return Container(
      height: 34.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.mainGold,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedListId,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.white, size: 18.w),
          dropdownColor: AppColors.white,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: 12.sp,
            color: AppColors.white,
          ),
          hint: Text(
            l10n.selectList,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: 12.sp,
              color: AppColors.white,
            ),
          ),
          selectedItemBuilder: (context) {
            return widget.lists.map((item) {
              return Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: 12.sp,
                    color: AppColors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList();
          },
          items: widget.lists.map((item) {
            return DropdownMenuItem<String>(
              value: item.id,
              child: Text(
                item.title,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: 12.sp,
                  color: AppColors.mainDark,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedListId = value),
        ),
      ),
    );
  }

  Widget _buildAddNewListButton(AppLocalizations l10n) {
    return SizedBox(
      height: 34.h,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pop(context, {'action': 'addList'}),
        icon: Icon(Icons.arrow_forward_ios, size: 12.w, color: AppColors.white),
        label: Text(
          l10n.addNewList,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: 11.sp,
            color: AppColors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mainGold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    final hours = List.generate(12, (i) => i + 1);
    final minutes = [0, 15, 30, 45];
    final periods = ['AM', 'PM'];

    return Container(
      height: 110.h,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.stroke),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          // Hour
          Expanded(
            child: CupertinoPicker(
              scrollController: _hourController,
              itemExtent: 34.h,
              selectionOverlay: _pickerOverlay(),
              onSelectedItemChanged: (i) => _selectedHour = hours[i],
              children: hours
                  .map((h) => Center(
                        child: Text(
                          '$h',
                          style: TextStyle(fontFamily: 'Pridi', fontSize: 15.sp),
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Minute
          Expanded(
            child: CupertinoPicker(
              scrollController: _minuteController,
              itemExtent: 34.h,
              selectionOverlay: _pickerOverlay(),
              onSelectedItemChanged: (i) => _selectedMinute = minutes[i],
              children: minutes
                  .map((m) => Center(
                        child: Text(
                          m.toString().padLeft(2, '0'),
                          style: TextStyle(fontFamily: 'Pridi', fontSize: 15.sp),
                        ),
                      ))
                  .toList(),
            ),
          ),
          // AM / PM
          Expanded(
            child: CupertinoPicker(
              scrollController: _ampmController,
              itemExtent: 34.h,
              selectionOverlay: _pickerOverlay(),
              onSelectedItemChanged: (i) => _isPM = i == 1,
              children: periods
                  .map((p) => Center(
                        child: Text(
                          p,
                          style: TextStyle(fontFamily: 'Pridi', fontSize: 15.sp),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pickerOverlay() {
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.mainGold.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  Widget _miniField(TextEditingController controller, String label) {
    return SizedBox(
      height: 38.h,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Pridi', fontSize: 13.sp),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
            fontFamily: 'Pridi',
            fontSize: 11.sp,
            color: AppColors.greyText,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: AppColors.stroke),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: AppColors.stroke),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: AppColors.mainGold),
          ),
        ),
      ),
    );
  }
}
