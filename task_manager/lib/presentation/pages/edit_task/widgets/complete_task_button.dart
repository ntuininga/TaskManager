import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';

class CompleteTaskButton extends StatelessWidget {
  final Task task;


  const CompleteTaskButton({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final Task completedTask = task.copyWith(isDone: true);

    return Align(
      alignment: Alignment.bottomCenter,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          context
              .read<TasksBloc>()
              .add(CompleteTask(taskToComplete: completedTask));
          Navigator.of(context).pop();
        },
        child: const Text("Complete Task"),
      ),
    );
  }
}
