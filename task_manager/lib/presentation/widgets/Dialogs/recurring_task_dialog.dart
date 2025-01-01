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
  EditRecurringTaskDialogState createState() => EditRecurringTaskDialogState();
}

class EditRecurringTaskDialogState extends State<EditRecurringTaskDialog> {
  late String selectedType;
  late DateTime startDate;
  DateTime? endDate;
  late List<bool> selectedDays;
  late String recurrenceOption;
  int count = 1;
  late TextEditingController countController;

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialType;
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
    selectedDays = List.from(widget.initialSelectedDays);
    recurrenceOption = 'End Date'; // Default recurrence option
    countController = TextEditingController(text: count.toString());
  }

  @override
  void dispose() {
    countController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, DateTime initialDate,
      Function(DateTime) onDatePicked) async {
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

          // Dropdown for recurrence options
          DropdownButtonFormField<String>(
            value: recurrenceOption,
            items: const [
              DropdownMenuItem(value: 'End Date', child: Text('End Date')),
              DropdownMenuItem(value: 'Count', child: Text('Count')),
              DropdownMenuItem(value: 'Infinite', child: Text('Infinite')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  recurrenceOption = value;
                });
              }
            },
            decoration: const InputDecoration(labelText: 'Recurrence Option'),
          ),

          const SizedBox(height: 16),

          // Conditionally display widgets based on recurrence option
          if (recurrenceOption == 'End Date')
            ListTile(
              title: const Text('End Date'),
              subtitle: Text(endDate != null
                  ? '${endDate!.toLocal()}'.split(' ')[0]
                  : 'No End Date'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () =>
                  _pickDate(context, endDate ?? DateTime.now(), (date) {
                setState(() {
                  endDate = date;
                });
              }),
            ),

          if (recurrenceOption == 'Count')
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: countController,
                    decoration: const InputDecoration(
                      labelText: 'Occurrences',
                    ),
                    onChanged: (value) {
                      setState(() {
                        count = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      count++;
                      countController.text = count.toString();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (count > 1) count--;
                      countController.text = count.toString();
                    });
                  },
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Day Selector for Daily Recurrence
          if (selectedType == 'Daily') ...[
            const Text('Select Days',
                style: TextStyle(fontWeight: FontWeight.bold)),
            DaySelector(initialSelectedDays: selectedDays),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, null), // Cancel without saving
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'type': selectedType,
              'startDate': startDate,
              'endDate': endDate,
              'selectedDays': selectedDays,
              'recurrenceOption': recurrenceOption,
              if (recurrenceOption == 'Count') 'count': count,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
