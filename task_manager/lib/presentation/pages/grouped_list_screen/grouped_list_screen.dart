import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/widgets/task_card.dart';

class GroupedListScreen extends StatelessWidget {
  final TaskCategory? category;
  final String? title;
  final FilterType? specialFilter; // for today/urgent/overdue

  const GroupedListScreen({
    super.key,
    this.category,
    this.title,
    this.specialFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title ?? category?.title ?? '')),
      body: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          if (state is! SuccessGetTasksState) return const SizedBox();

          List<Task> tasks;
          if (specialFilter != null) {
            switch (specialFilter) {
              case FilterType.dueToday:
                tasks = state.today;
                break;
              case FilterType.urgency:
                tasks = state.urgent;
                break;
              case FilterType.overdue:
                tasks = state.overdue;
                break;
              default:
                tasks = [];
            }
          } else {
            tasks = state.tasksByCategory[category] ?? [];
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: tasks.length,
            itemBuilder: (_, index) => TaskCard(task: tasks[index]),
          );
        },
      ),
    );
  }
}

