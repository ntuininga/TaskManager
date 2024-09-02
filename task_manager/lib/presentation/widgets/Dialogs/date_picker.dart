import 'package:flutter/material.dart';
import 'package:task_manager/presentation/widgets/buttons/basic_button.dart';

Future<DateTime?> showCustomDatePicker(BuildContext context, {DateTime? initialDate}) async {
  DateTime? selectedDate = initialDate;

  return await showDialog<DateTime?>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Select Date'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: CalendarDatePicker(
                        initialDate: initialDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(3000),
                        onDateChanged: (DateTime date) {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BasicButton(
                          onPressed: () {
                            setState(() {
                              selectedDate = null;
                            });
                            Navigator.of(context).pop(selectedDate);
                          },
                          text: "No Date",
                        ),
                        BasicButton(
                          onPressed: () {
                            setState(() {
                              selectedDate = null;
                            });
                            Navigator.of(context).pop(selectedDate);
                          },
                          text: "Today",
                        ),
                        BasicButton(
                          onPressed: () {
                            setState(() {
                              selectedDate = null;
                            });
                            Navigator.of(context).pop(selectedDate);
                          },
                          text: "Tomorrow",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(selectedDate);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}
