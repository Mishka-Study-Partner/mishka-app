import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum MonthDirection { next, previous }

class CustomCalendar extends StatefulWidget {
  final List<DateTime> taskDates;

  const CustomCalendar({
    super.key,
    required this.taskDates,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  DateTime currentMonth = DateTime(2025, 12);
  DateTime? selectedDay;
  MonthDirection direction = MonthDirection.next;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCA85E)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildWeekDays(),
          const SizedBox(height: 12),

          ///  Animated Month Change
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              final beginOffset =
              direction == MonthDirection.next
                  ? const Offset(1, 0)
                  : const Offset(-1, 0);

              return SlideTransition(
                position: Tween<Offset>(
                  begin: beginOffset,
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            child: _buildDaysGrid(
              key: ValueKey(currentMonth.month),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            setState(() {
              direction = MonthDirection.previous;
              currentMonth =
                  DateTime(currentMonth.year, currentMonth.month - 1);
            });
          },
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFCCA85E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            DateFormat('MMMM / yyyy').format(currentMonth),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            setState(() {
              direction = MonthDirection.next;
              currentMonth =
                  DateTime(currentMonth.year, currentMonth.month + 1);
            });
          },
        ),
      ],
    );
  }

  // ---------------- WEEK DAYS ----------------
  Widget _buildWeekDays() {
    final days = ['Mon', 'Tus', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      children: days
          .map(
            (day) => Expanded(
          child: Center(
            child: Text(
              day,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      )
          .toList(),
    );
  }

  // ---------------- DAYS GRID ----------------
  Widget _buildDaysGrid({required Key key}) {
    final firstDay =
    DateTime(currentMonth.year, currentMonth.month, 1);
    final daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday - 1;
    final totalCells = startWeekday + daysInMonth;

    return GridView.builder(
        key: key,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
    itemCount: totalCells,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 7,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
    ),
      itemBuilder: (context, index) {
        if (index < startWeekday) {
          return const SizedBox();
        }

        final dayNumber = index - startWeekday + 1;
        final date = DateTime(
          currentMonth.year,
          currentMonth.month,
          dayNumber,
        );

        final hasTask = widget.taskDates.any(
              (d) =>
          d.year == date.year &&
              d.month == date.month &&
              d.day == date.day,
        );

        final isSelected = selectedDay != null &&
            selectedDay!.day == date.day &&
            selectedDay!.month == date.month &&
            selectedDay!.year == date.year;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDay = date;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFCCA85E)
                  : hasTask
                  ? const Color(0xFFCCA85E).withOpacity(0.25)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                dayNumber.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : hasTask
                      ? const Color(0xFFCCA85E)
                      : Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}