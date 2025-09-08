import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/widgets/bottom_sheets/new_task_bottom_sheet.dart';
import 'package:task_manager/presentation/widgets/task_list.dart';

class GroupedListScreen extends StatelessWidget {
  final TaskCategory? category;
  final String? title;
  final FilterType? specialFilter;

  const GroupedListScreen({
    super.key,
    this.category,
    this.title,
    this.specialFilter,
  });

  void _onAddButtonPressed(BuildContext context, TaskCategory? category) {
    showNewTaskBottomSheet(context, initialCategory: category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title ?? category?.title ?? '')),
      body: SafeArea(
        child: BlocBuilder<TasksBloc, TasksState>(
          builder: (context, state) {
            if (state is ErrorState) {
              return Center(
                child: Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            if (state is NoTasksState) {
              return Center(
                child: Text(
                  'No tasks found',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            if (state is! SuccessGetTasksState) {
              return const Center(child: CircularProgressIndicator());
            }

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
              tasks = state.tasksByCategory[category]
                      ?.where((task) => !task.isDone)
                      .toList() ??
                  [];
            }

            if (tasks.isEmpty) {
              return Center(
                child: Text(
                  'No tasks',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: TaskList(tasks: tasks),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddButtonPressed(context, category),
        child: const Icon(Icons.add),
      ),
    );
  }
}
