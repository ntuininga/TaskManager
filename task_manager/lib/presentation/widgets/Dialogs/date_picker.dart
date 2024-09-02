import 'package:flutter/material.dart';
import 'package:task_manager/presentation/widgets/buttons/basic_button.dart';

Future<DateTime?> showCustomDatePicker(BuildContext context,
    {DateTime? initialDate}) async {
  DateTime selectedDate = initialDate ?? DateTime.now();

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
                    CalendarDatePicker(
                      key: ValueKey<DateTime>(selectedDate),
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(3000),
                      onDateChanged: (DateTime date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BasicButton(
                          onPressed: () {
                            Navigator.of(context).pop(null);
                          },
                          text: "No Date",
                        ),
                        BasicButton(
                          onPressed: () {
                            setState(() {
                              selectedDate = DateTime.now();
                            });
                          },
                          text: "Today",
                        ),
                        BasicButton(
                          onPressed: () {
                            setState(() {
                              selectedDate =
                                  DateTime.now().add(const Duration(days: 1));
                            });
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
