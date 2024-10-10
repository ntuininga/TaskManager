import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> showReminderDialog(
  BuildContext context, {
  required TimeOfDay? selectedTime,
  required int? notifyBeforeMinutes,
  required DateTime? selectedDate,
  required Function(DateTime?, TimeOfDay?, int?) onSave,
}) {
  TimeOfDay? tempSelectedTime = selectedTime;
  DateTime? tempSelectedDate = selectedDate ?? DateTime.now();
  int? tempNotifyBeforeMinutes = notifyBeforeMinutes ?? 0;
  TimeOfDay? customTime;

  // Predefined notify-before options (in minutes) and 1 day before
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
                // Time Picker
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
                // Notify Before Options
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
                            customTime = null; // Reset custom time to "Custom"
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8.0),
                // Custom Time Chip
                ChoiceChip(
                  label: Text(
                    customTime != null
                        ? 'Custom: ${_formatTime(customTime!)}'
                        : 'Custom',
                  ),
                  selected: customTime != null,
                  onSelected: (bool selected) async {
                    if (selected) {
                      TimeOfDay? pickedCustomTime =
                          await _showCustomTimePicker(context);
                      if (pickedCustomTime != null) {
                        setState(() {
                          customTime = pickedCustomTime;
                          // Calculate minutes before from now based on selected custom time
                          final now = TimeOfDay.now();
                          tempNotifyBeforeMinutes =
                              _calculateMinutesDifference(customTime!, now);
                        });
                      }
                    }
                  },
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
                  onSave(tempSelectedDate, tempSelectedTime, tempNotifyBeforeMinutes);
                  Navigator.of(context).pop();
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

// Time formatting function
String _formatTime(TimeOfDay time) {
  final hours = time.hour % 12;
  final minutes = time.minute.toString().padLeft(2, '0');
  final period = time.hour >= 12 ? 'PM' : 'AM';
  return '${hours == 0 ? 12 : hours}:$minutes $period';
}

// Show custom time picker dialog
Future<TimeOfDay?> _showCustomTimePicker(BuildContext context) {
  return showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );
}

// Calculate the difference in minutes between the custom time and current time
int _calculateMinutesDifference(TimeOfDay customTime, TimeOfDay now) {
  final customTimeMinutes = customTime.hour * 60 + customTime.minute;
  final nowMinutes = now.hour * 60 + now.minute;
  return (customTimeMinutes - nowMinutes) % (24 * 60);
}
