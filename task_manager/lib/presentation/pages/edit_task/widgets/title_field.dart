import 'package:flutter/material.dart';
import 'package:task_manager/data/entities/task_entity.dart';

Widget buildTitleField({
  required BuildContext context,
  required TextEditingController controller,
  required TaskPriority priority,
  required VoidCallback onPriorityChanged,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: TextFormField(
          autofocus: true,
          controller: controller,
          decoration: const InputDecoration(labelText: 'Title'),
          minLines: 3,
          maxLines: null,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              priority == TaskPriority.high ? Icons.flag : Icons.outlined_flag,
              color: priority == TaskPriority.high
                  ? Colors.red
                  : Theme.of(context).dividerColor,
            ),
            onPressed: onPriorityChanged,
          ),
        ],
      ),
    ],
  );
}
