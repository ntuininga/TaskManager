import 'package:flutter/material.dart';
import 'package:task_manager/presentation/widgets/buttons/basic_button.dart';

class TimeButton extends StatelessWidget {
  final String? title;
  final bool? active;
  final Function(TimeOfDay) onPressed;

  const TimeButton({super.key, this.title, this.active, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BasicButton(
        text: title ?? "12:00 AM",
        icon: Icons.access_time,
        textColor: title != null ? theme.primaryColor : null,
        onPressed: () async {
          TimeOfDay? pickedTime = await showTimePicker(
              context: context, initialTime: TimeOfDay.now());

          if (pickedTime != null) {
            onPressed(pickedTime);
          }
        });
  }
}
