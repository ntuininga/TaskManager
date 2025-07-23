import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecurrenceEndSelector extends StatefulWidget {
  const RecurrenceEndSelector({Key? key}) : super(key: key);

  @override
  State<RecurrenceEndSelector> createState() => _RecurrenceEndSelectorState();
}

class _RecurrenceEndSelectorState extends State<RecurrenceEndSelector> {
  String selectedEndCondition = 'Never';
  DateTime? startDate;
  DateTime? endDate;
  int occurrenceCount = 1;

  final List<String> endConditions = [
    'Never',
    'End on date',
    'End after occurrences',
  ];

  void _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = isStartDate ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now());
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: selectedEndCondition,
          decoration: const InputDecoration(
            labelText: 'Recurrence Ends',
          ),
          items: endConditions.map((String condition) {
            return DropdownMenuItem<String>(
              value: condition,
              child: Text(condition),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedEndCondition = newValue!;
            });
          },
        ),
        const SizedBox(height: 16),
        if (selectedEndCondition == 'End on date') ...[
          TextButton(
            onPressed: () => _selectDate(context, true),
            child: Text(startDate != null
                ? 'Start Date: ${DateFormat.yMMMd().format(startDate!)}'
                : 'Select Start Date'),
          ),
          TextButton(
            onPressed: () => _selectDate(context, false),
            child: Text(endDate != null
                ? 'End Date: ${DateFormat.yMMMd().format(endDate!)}'
                : 'Select End Date'),
          ),
        ],
        if (selectedEndCondition == 'End after occurrences') ...[
          TextFormField(
            initialValue: occurrenceCount.toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Number of Occurrences',
            ),
            onChanged: (value) {
              setState(() {
                occurrenceCount = int.tryParse(value) ?? 1;
              });
            },
          ),
        ],
      ],
    );
  }
}
