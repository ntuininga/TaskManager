import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirmed;

  const DeleteConfirmationDialog({Key? key, required this.onConfirmed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete All Tasks'),
      content: const Text('Are you sure you want to delete all tasks?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirmed();
          },
          child: const Text('DELETE'),
        ),
      ],
    );
  }
}
