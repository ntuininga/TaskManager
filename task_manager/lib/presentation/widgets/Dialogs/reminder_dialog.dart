import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> showReminderDialog(
  BuildContext context, {
  required TimeOfDay? selectedTime,
  required int? notifyBeforeMinutes,
  required Function(TimeOfDay?, int?) onSave,
}) {
  TimeOfDay? tempSelectedTime = selectedTime;
  int? tempNotifyBeforeMinutes = notifyBeforeMinutes ?? 0;
  final List<int> notifyBeforeOptions = [5, 10, 15, 30, 60]; // Minutes options

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Set Reminder"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Time Picker
            ListTile(
              leading: const Icon(Icons.alarm),
              title: Text(
                  tempSelectedTime != null
                      ? _formatTime(tempSelectedTime!)
                      : "Select Time",
                  style: const TextStyle(fontSize: 16)),
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: tempSelectedTime ?? TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  tempSelectedTime = pickedTime;
                }
              },
            ),
            const SizedBox(height: 20),
            // Notify Before Dropdown
            ListTile(
              leading: const Icon(Icons.notifications),
              // title: DropdownButton<int>(
              //   value: tempNotifyBeforeMinutes,
              //   isExpanded: true,
              //   hint: const Text("Notify Before"),
              //   items: notifyBeforeOptions.map((int value) {
              //     print(value);
              //     return DropdownMenuItem<int>(
              //       value: value,
              //       child: Text("$value minutes before"),
              //     );
              //   }).toList(),
              //   onChanged: (int? newValue) {
              //     if (newValue != null) {
              //       tempNotifyBeforeMinutes = newValue;
              //     }
              //   },
              // ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              onSave(tempSelectedTime, tempNotifyBeforeMinutes);
              Navigator.of(context).pop();
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}

// Time formatting function
String _formatTime(TimeOfDay time) {
  final hours = time.hour % 12;
  final minutes = time.minute.toString().padLeft(2, '0');
  final period = time.hour >= 12 ? 'PM' : 'AM';
  return '${hours == 0 ? 12 : hours}:$minutes $period';
}
