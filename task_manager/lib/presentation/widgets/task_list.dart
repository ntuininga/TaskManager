import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/widgets/task_card.dart';

class TaskList extends StatefulWidget {
  final List<Task> tasks;
  final bool isTappable;

  const TaskList({
    required this.tasks,
    this.isTappable = true,
    super.key
    });

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final TaskRepository taskRepository = GetIt.instance<TaskRepository>();

  @override
  Widget build(BuildContext context) {
    return _buildTaskList(widget.tasks);
  }

  Widget _buildTaskList(List<Task?> tasks) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: TaskCard(
            isTappable: widget.isTappable,
            task: tasks[index]!,
            onCheckboxChanged: (value) {
              setState(() {
                // tasks[index]!.isDone = value!;
                // context.read<TasksBloc>().add(UpdateTask(taskToUpdate: tasks[index]))
              });
            },
          ),
        );
      },
    );
  }
}

