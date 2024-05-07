import 'package:flutter/material.dart';
import 'package:task_manager/domain/models/task_category.dart';

Future<void> showTaskDialog(BuildContext context, {String? title, String? description, TaskCategory? category}) async {
  TextEditingController titleController = TextEditingController(text: title);
  TextEditingController descriptionController = TextEditingController(text: description);

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('New Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            // Additional field for date can be added here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder()
            ),
            onPressed: () {
              // Handle saving the task here
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.save),
          ),
        ],
      );
    },
  );
}

