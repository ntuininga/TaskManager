import 'package:flutter/material.dart';

Future<void> showReminderDialog(
  BuildContext context, {
  required TimeOfDay? selectedTime,
  required int? notifyBeforeMinutes,
  required DateTime? selectedDate,
  required Function(TimeOfDay?, int) onReminderSet,
}) {
  TimeOfDay? tempSelectedTime = selectedTime;
  int tempNotifyBeforeMinutes = notifyBeforeMinutes ?? 0;

  final Map<String, int> notifyBeforeOptions = {
    '0 minutes': 0,
    '5 minutes': 5,
    '15 minutes': 15,
    '30 minutes': 30,
    '1 hour': 60,
    '1 day': 1440, // 1440 minutes = 24 hours = 1 day
  };

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text("Set Reminder"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Task Time",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.alarm),
                  title: Text(
                    tempSelectedTime != null
                        ? _formatTime(tempSelectedTime!)
                        : "Select Time",
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: tempSelectedTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        tempSelectedTime = pickedTime;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Notify Before:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Wrap(
                  spacing: 8.0,
                  children: notifyBeforeOptions.entries.map((entry) {
                    return ChoiceChip(
                      label: Text(entry.key),
                      selected: tempNotifyBeforeMinutes == entry.value,
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            tempNotifyBeforeMinutes = entry.value;
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog on cancel
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  // Ensure reminder time is calculated only if a time is selected
                  if (tempSelectedTime != null) {
                    // Call the callback function with the selected reminder time
                    onReminderSet(tempSelectedTime, tempNotifyBeforeMinutes);
                    Navigator.of(context).pop(); // Close dialog
                  } else {
                    // Show error if time is not selected
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a time for the reminder.'),
                      ),
                    );
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
    },
  );
}

String _formatTime(TimeOfDay time) {
  final hours =
      time.hour % 12 == 0 ? 12 : time.hour % 12; // Handle 12 AM/PM correctly
  final minutes =
      time.minute.toString().padLeft(2, '0'); // Ensure two digits for minutes
  final period = time.hour >= 12 ? 'PM' : 'AM';
  return '$hours:$minutes $period';
}

// Calculate the reminder time based on the selected time and notify before minutes
TimeOfDay _calculateReminderTime(
    TimeOfDay selectedTime, int notifyBeforeMinutes) {
  int totalMinutes =
      selectedTime.hour * 60 + selectedTime.minute - notifyBeforeMinutes;

  // Wrap around in case totalMinutes goes negative (i.e. reminder is before midnight)
  if (totalMinutes < 0) {
    totalMinutes = (24 * 60) + totalMinutes; // Wrap around to the previous day
  }

  final reminderHour = (totalMinutes ~/ 60) % 24; // Wrap for 24-hour format
  final reminderMinute = totalMinutes % 60;
  return TimeOfDay(hour: reminderHour, minute: reminderMinute);
}
