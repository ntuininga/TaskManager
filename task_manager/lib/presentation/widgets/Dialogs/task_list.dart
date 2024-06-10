import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/widgets/task_card.dart';

class TaskList extends StatefulWidget {
  final bool isTappable;

  const TaskList({
    this.isTappable = true,
    super.key
    });

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final TaskRepository taskRepository = GetIt.instance<TaskRepository>();
  List<Task?> tasks = [];

void refreshTaskList() async {
  var allTasks = await taskRepository.getUnfinishedTasks();
  DateTime today = DateTime.now();
  
  // Only keep the date part
  var refreshTasks = allTasks.where((task) {
    if (task.date != null) {
      DateTime taskDate = DateTime(task.date!.year, task.date!.month, task.date!.day);
      DateTime currentDate = DateTime(today.year, today.month, today.day);
      return taskDate == currentDate;
    }
    return false;
  }).toList(); // Make sure to convert it to a list
  
  if (refreshTasks.isEmpty) {
    refreshTasks = allTasks..shuffle();
    refreshTasks = refreshTasks.take(5).toList();
  }

  setState(() {
    tasks = refreshTasks;
  });
}

  @override
  void initState() {
    refreshTaskList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTaskList(tasks);
  }

  Widget _buildTaskList(List<Task?> tasks) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return TaskCard(
          isTappable: widget.isTappable,
          task: tasks[index]!,
          onCheckboxChanged: (value) {
            setState(() {
              tasks[index]!.isDone = value!;
              // taskRepository.completeTask(tasks[index]!);
              // db.updateTask(tasks[index]!);
            });
          },
        );
      },
    );
  }
}

