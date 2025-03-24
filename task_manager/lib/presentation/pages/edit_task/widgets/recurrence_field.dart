import 'package:flutter/material.dart';

class RecurrenceField extends StatelessWidget {
  final bool isRecurrenceEnabled;
  final ValueChanged<bool> onRecurrenceToggle;
  final String? selectedFrequency;
  final ValueChanged<String?> onFrequencySelected;
  final VoidCallback? onEditPressed;

  const RecurrenceField({
    super.key,
    required this.isRecurrenceEnabled,
    required this.onRecurrenceToggle,
    required this.selectedFrequency,
    required this.onFrequencySelected,
    this.onEditPressed,
  });

  List<DropdownMenuItem<String?>> _getRecurrenceTypeDropdownItems() {
    return const [
      DropdownMenuItem<String?>(
        value: null,
        child: Text('None'),
      ),
      DropdownMenuItem<String>(
        value: 'daily',
        child: Text('Daily'),
      ),
      DropdownMenuItem<String>(
        value: 'weekly',
        child: Text('Weekly'),
      ),
      DropdownMenuItem<String>(
        value: 'monthly',
        child: Text('Monthly'),
      ),
      DropdownMenuItem<String>(
        value: 'yearly',
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
                child: DropdownButton<String?>(
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
            // Uncomment this if you want to use the edit button
            // IconButton(
            //   icon: const Icon(Icons.more_horiz),
            //   onPressed: (isRecurrenceEnabled && selectedFrequency != null)
            //       ? onEditPressed
            //       : null,
            //   disabledColor: Theme.of(context).dividerColor,
            // ),
          ],
        ),
      ],
    );
  }
}
