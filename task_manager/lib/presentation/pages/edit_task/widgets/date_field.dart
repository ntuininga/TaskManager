import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/presentation/widgets/Dialogs/date_picker.dart';
import 'package:task_manager/presentation/widgets/task_input_field.dart';

class DateField extends StatelessWidget {
  final TextEditingController controller;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;
  final String? Function(String?)? validator;

  const DateField({
    super.key,
    required this.controller,
    required this.selectedDate,
    required this.onDateSelected,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    return TaskInputField(
      child: TextFormField(
        controller: controller,
        decoration: const InputDecoration(
          icon: Icon(Icons.calendar_today_rounded),
          labelText: "Date",
          border: InputBorder.none,
        ),
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showCustomDatePicker(
            context,
            initialDate: selectedDate ?? DateTime.now(),
          );

          controller.text = pickedDate != null
              ? dateFormat.format(pickedDate)
              : '';
          onDateSelected(pickedDate);
        },
        validator: validator,
      ),
    );
  }
}
