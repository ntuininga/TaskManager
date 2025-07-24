import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/presentation/bloc/settings_bloc/settings_bloc.dart';
import 'package:task_manager/presentation/widgets/task_card.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final bool isTappable;

  const TaskList({
    required this.tasks,
    this.isTappable = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final format = settingsState.dateFormat;
        final circleCheckbox = settingsState.isCircleCheckbox;
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TaskCard(
                task: task,
                isTappable: isTappable,
                dateFormat: format,
                circleCheckbox: circleCheckbox,
                onCheckboxChanged: (value) {
                  // Call your task completion logic here, e.g.:
                  // context.read<TasksBloc>().add(UpdateTask(...))
                },
              ),
            );
          },
        );
      },
    );
  }
}
