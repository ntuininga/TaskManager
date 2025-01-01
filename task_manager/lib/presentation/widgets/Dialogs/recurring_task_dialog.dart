import 'package:flutter/material.dart';
import 'package:task_manager/presentation/widgets/day_selector.dart';

class EditRecurringTaskDialog extends StatefulWidget {
  final String initialType;
  final DateTime initialStartDate;
  final DateTime? initialEndDate;
  final List<bool> initialSelectedDays;

  const EditRecurringTaskDialog({
    Key? key,
    required this.initialType,
    required this.initialStartDate,
    this.initialEndDate,
    required this.initialSelectedDays,
  }) : super(key: key);

  @override
  _EditRecurringTaskDialogState createState() => _EditRecurringTaskDialogState();
}

class _EditRecurringTaskDialogState extends State<EditRecurringTaskDialog> {
  late String selectedType;
  late DateTime startDate;
  DateTime? endDate;
  late List<bool> selectedDays;

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialType;
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
    selectedDays = List.from(widget.initialSelectedDays);
  }

  Future<void> _pickDate(BuildContext context, DateTime initialDate, Function(DateTime) onDatePicked) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      onDatePicked(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Recurring Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dropdown for recurrence type
          DropdownButtonFormField<String>(
            value: selectedType,
            items: const [
              DropdownMenuItem(value: 'Daily', child: Text('Daily')),
              DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
              DropdownMenuItem(value: 'Yearly', child: Text('Yearly')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedType = value;
                });
              }
            },
            decoration: const InputDecoration(labelText: 'Recurrence Type'),
          ),

          const SizedBox(height: 16),

          // Start Date Picker
          ListTile(
            title: const Text('Start Date'),
            subtitle: Text('${startDate.toLocal()}'.split(' ')[0]),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _pickDate(context, startDate, (date) {
              setState(() {
                startDate = date;
              });
            }),
          ),

          const SizedBox(height: 16),

          // End Date Picker
          ListTile(
            title: const Text('End Date'),
            subtitle: Text(endDate != null ? '${endDate!.toLocal()}'.split(' ')[0] : 'No End Date'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _pickDate(context, endDate ?? DateTime.now(), (date) {
              setState(() {
                endDate = date;
              });
            }),
          ),

          const SizedBox(height: 16),

          // Day Selector for Daily Recurrence
          if (selectedType == 'Daily') ...[
            const Text('Select Days', style: TextStyle(fontWeight: FontWeight.bold)),
            DaySelector(initialSelectedDays: selectedDays),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null), // Cancel without saving
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'type': selectedType,
              'startDate': startDate,
              'endDate': endDate,
              'selectedDays': selectedDays,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
