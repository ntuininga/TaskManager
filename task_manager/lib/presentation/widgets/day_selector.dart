import 'package:flutter/material.dart';
import 'package:task_manager/core/weekday.dart';

class DaySelector extends StatefulWidget {
  final List<WeekDay> initialSelectedDays;
  final ValueChanged<List<WeekDay>> onSelectionChanged;

  const DaySelector({
    Key? key,
    required this.initialSelectedDays,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  _DaySelectorState createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  late List<WeekDay> selectedDays;

  @override
  void initState() {
    super.initState();
    selectedDays = List.from(widget.initialSelectedDays);
  }

  void _toggleDay(WeekDay day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
    });
    widget.onSelectionChanged(selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    final days = WeekDay.values;

    return Wrap(
      children: List.generate(days.length, (index) {
        final day = days[index];
        final isSelected = selectedDays.contains(day);
        final dayLabel = day.label.substring(0, 1); // First letter of the day

        return GestureDetector(
          onTap: () => _toggleDay(day),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? Colors.transparent : Theme.of(context).colorScheme.onSurface),
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
              ),
              alignment: Alignment.center,
              child: Text(
                dayLabel,
                style: TextStyle(
                  color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
