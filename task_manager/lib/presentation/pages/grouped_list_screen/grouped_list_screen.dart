import 'package:flutter/material.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/presentation/widgets/task_card.dart';

class GroupedListScreen extends StatelessWidget {
  final List<Task> tasks;
  final String title;

  const GroupedListScreen({super.key, required this.tasks, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (_, index) {
          final task = tasks[index];
          return TaskCard(task: task); // your existing TaskCard widget
        },
      ),
    );
  }
}
