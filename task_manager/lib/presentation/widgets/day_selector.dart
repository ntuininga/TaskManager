import 'package:flutter/material.dart';

class DaySelector extends StatefulWidget {
  final List<bool> initialSelectedDays;

  const DaySelector({
    Key? key,
    required this.initialSelectedDays,
  }) : super(key: key);

  @override
  _DaySelectorState createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  late List<bool> selectedDays;

  @override
  void initState() {
    super.initState();
    selectedDays = List.from(widget.initialSelectedDays);
  }

  void _toggleDay(int index) {
    setState(() {
      selectedDays[index] = !selectedDays[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Wrap(
      children: List.generate(days.length, (index) {
        return GestureDetector(
          onTap: () => _toggleDay(index),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selectedDays[index] ? Colors.transparent : Theme.of(context).colorScheme.onSurface),
                color: selectedDays[index] ? Theme.of(context).colorScheme.primary : Colors.transparent,
              ),
              alignment: Alignment.center,
              child: Text(
                days[index],
                style: TextStyle(
                  color: selectedDays[index] ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
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
