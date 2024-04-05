import 'package:flutter/material.dart';
import 'package:task_manager/models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(bool?) onCheckboxChanged;

  const TaskCard({
    required this.task,
    required this.onCheckboxChanged,
    super.key
    });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(task.title, style: TextStyle(fontSize: 15),),
            Text(task.taskCategoryId.toString()),
            SizedBox(
              height: 20,
              width: 20,
              child: Checkbox(
                value: task.isDone, 
                onChanged: onCheckboxChanged
              ),
            ),
          ],
        ),
      ),
    );
  }
}