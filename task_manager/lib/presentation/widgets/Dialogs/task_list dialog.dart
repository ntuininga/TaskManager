import 'package:flutter/material.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/presentation/widgets/task_card.dart';

Future<void> showTaskListDialog(BuildContext context,
    {required List<Task> tasks, String? title}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title ?? "Tasks",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300, // Limit the height of the list
                    width: double.maxFinite, // Allow the dialog to expand to full width
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: TaskCard(
                            task: tasks[index],
                            onCheckboxChanged: (value) {
                              setState(() {
                                tasks[index].isDone = value!;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}



