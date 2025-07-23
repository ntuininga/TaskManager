import 'package:flutter/material.dart';
import 'package:task_manager/core/utils/datetime_utils.dart';

class ReminderField extends StatelessWidget {
  final TextEditingController controller;
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay?> onTimeSelected;

  const ReminderField({
    super.key,
    required this.controller,
    required this.selectedTime,
    required this.onTimeSelected,
  });

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final formattedTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return formatTime(TimeOfDay.fromDateTime(formattedTime));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            icon: Icon(Icons.alarm),
            labelText: "Reminder Time",
            border: InputBorder.none,
          ),
          readOnly: true,
          onTap: () async {
            final pickedTime = await showTimePicker(
              context: context,
              initialTime: selectedTime ?? TimeOfDay.now(),
            );

            if (pickedTime != null) {
              controller.text = _formatTime(pickedTime);
              onTimeSelected(pickedTime);
            }
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
