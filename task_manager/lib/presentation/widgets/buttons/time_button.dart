import 'package:flutter/material.dart';
import 'package:task_manager/presentation/widgets/buttons/basic_button.dart';

class TimeButton extends StatelessWidget {
  final String? title;
  final Function(TimeOfDay) onPressed;

  const TimeButton({super.key, this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BasicButton(
        text: title ?? "12:00 AM",
        icon: Icons.access_time,
        onPressed: () async {
          TimeOfDay? pickedTime = await showTimePicker(
              context: context, initialTime: TimeOfDay.now());

          if (pickedTime != null) {
            onPressed(pickedTime);
          }
        });
  }
}
