import 'package:flutter/material.dart';
import 'package:task_manager/core/frequency.dart';


class RecurrenceField extends StatelessWidget {
  final bool isRecurrenceEnabled;
  final ValueChanged<bool> onRecurrenceToggle;
  final Frequency? selectedFrequency;
  final ValueChanged<Frequency?> onFrequencySelected;
  final VoidCallback? onEditPressed;

  const RecurrenceField({
    super.key,
    required this.isRecurrenceEnabled,
    required this.onRecurrenceToggle,
    required this.selectedFrequency,
    required this.onFrequencySelected,
    this.onEditPressed,
  });

  List<DropdownMenuItem<Frequency?>> _getRecurrenceTypeDropdownItems() {
    return const [
      DropdownMenuItem<Frequency?>(
        value: null,
        child: Text('None'),
      ),
      DropdownMenuItem<Frequency>(
        value: Frequency.daily,
        child: Text('Daily'),
      ),
      DropdownMenuItem<Frequency>(
        value: Frequency.weekly,
        child: Text('Weekly'),
      ),
      DropdownMenuItem<Frequency>(
        value: Frequency.monthly,
        child: Text('Monthly'),
      ),
      DropdownMenuItem<Frequency>(
        value: Frequency.yearly,
        child: Text('Yearly'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recurring",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Switch(
              value: isRecurrenceEnabled,
              onChanged: onRecurrenceToggle,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHigh
                      .withOpacity(0.95),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButton<Frequency?> (
                  value: selectedFrequency,
                  hint: const Text("Select Recurrence Type"),
                  isExpanded: true,
                  underline: const SizedBox(),
                  onChanged: isRecurrenceEnabled ? onFrequencySelected : null,
                  items: _getRecurrenceTypeDropdownItems(),
                  dropdownColor: Theme.of(context).cardColor,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: (isRecurrenceEnabled && selectedFrequency != null) ? onEditPressed : null,
              disabledColor: Theme.of(context).dividerColor,
            ),
          ],
        ),
      ],
    );
  }
}
