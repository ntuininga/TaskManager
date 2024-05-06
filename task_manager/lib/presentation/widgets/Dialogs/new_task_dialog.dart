import 'package:flutter/material.dart';

Future<void> showNewTaskDialog(BuildContext context) async {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

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
