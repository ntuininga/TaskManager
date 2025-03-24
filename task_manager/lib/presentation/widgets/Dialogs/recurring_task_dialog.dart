import 'package:flutter/material.dart';
import 'package:task_manager/core/frequency.dart';
import 'package:task_manager/core/weekday.dart';
import 'package:task_manager/data/entities/recurrence_ruleset_entity.dart';
import 'package:task_manager/presentation/widgets/day_selector.dart';

enum RecurrenceOption { until, count, infinite }

class EditRecurringTaskDialog extends StatefulWidget {
  final RecurrenceRuleset? initialRuleset;

  const EditRecurringTaskDialog({
    Key? key,
    this.initialRuleset,
  }) : super(key: key);

  @override
  EditRecurringTaskDialogState createState() => EditRecurringTaskDialogState();
}

class EditRecurringTaskDialogState extends State<EditRecurringTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  Frequency? selectedFrequency;
  DateTime? endDate;
  List<WeekDay> selectedDays = WeekDay.values;
  int count = 1;
  late TextEditingController countController;
  RecurrenceOption? recurrenceOption = RecurrenceOption.infinite;

  @override
  void initState() {
    super.initState();

    if (widget.initialRuleset?.count != 0 &&
        widget.initialRuleset?.count != null) {
      recurrenceOption = RecurrenceOption.count;
    } else if (widget.initialRuleset?.until != null) {
      recurrenceOption = RecurrenceOption.until;
    } else {
      recurrenceOption = RecurrenceOption.infinite;
    }

    selectedFrequency = widget.initialRuleset?.frequency;
    endDate = widget.initialRuleset!.until;
    selectedDays = widget.initialRuleset?.weekDays ?? WeekDay.values;
    count = widget.initialRuleset?.count ?? 1;
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
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Frequency>(
                value: selectedFrequency,
                items: const [
                  DropdownMenuItem(value: Frequency.daily, child: Text('Daily')),
                  DropdownMenuItem(value: Frequency.weekly, child: Text('Weekly')),
                  DropdownMenuItem(value: Frequency.monthly, child: Text('Monthly')),
                  DropdownMenuItem(value: Frequency.yearly, child: Text('Yearly')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedFrequency = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Recurrence Type'),
                validator: (value) => value == null ? 'Please select a frequency' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RecurrenceOption>(
                value: recurrenceOption,
                items: const [
                  DropdownMenuItem(value: RecurrenceOption.until, child: Text('End Date')),
                  DropdownMenuItem(value: RecurrenceOption.count, child: Text('Count')),
                  DropdownMenuItem(value: RecurrenceOption.infinite, child: Text('Infinite')),
                ],
                onChanged: (value) {
                  setState(() {
                    recurrenceOption = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Recurrence Option'),
                validator: (value) => value == null ? 'Please select a recurrence option' : null,
              ),
              const SizedBox(height: 16),
              if (recurrenceOption == RecurrenceOption.until)
                ListTile(
                  title: const Text('End Date'),
                  subtitle: Text(endDate != null
                      ? '${endDate!.toLocal()}'.split(' ')[0]
                      : 'No End Date'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate(context, endDate ?? DateTime.now(), (date) {
                    setState(() {
                      endDate = date;
                    });
                  }),
                ),
              if (recurrenceOption == RecurrenceOption.count)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: countController,
                        decoration: const InputDecoration(labelText: 'Occurrences'),
                        onChanged: (value) {
                          setState(() {
                            count = int.tryParse(value) ?? 1;
                          });
                        },
                        validator: (value) {
                          if (recurrenceOption == RecurrenceOption.count) {
                            int? val = int.tryParse(value ?? '');
                            if (val == null || val <= 0) {
                              return 'Enter a valid number greater than 0';
                            }
                            if (selectedFrequency == Frequency.daily) {
                              if (selectedDays.length > val){
                                return 'Count is less than number of days selected';
                              }
                            }
                          }
                          return null;
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
              if (selectedFrequency == Frequency.daily) ...[
                const Text('Select Days',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                DaySelector(
                  initialSelectedDays: selectedDays,
                  onSelectionChanged: (List<WeekDay> newSelectedDays) {
                    setState(() {
                      selectedDays = newSelectedDays;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (recurrenceOption == RecurrenceOption.until) {
                count = 0;
              } else if (recurrenceOption == RecurrenceOption.count) {
                endDate = null;
              } else {
                count = 0;
                endDate = null;
              }

              Navigator.pop(context, {
                'ruleset': RecurrenceRuleset(
                    frequency: selectedFrequency,
                    until: endDate,
                    weekDays: selectedDays,
                    count: count),
              });
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
