import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'task_card.dart'; // Assuming you are using the TaskCard you implemented earlier

class CollapsibleTaskLists extends StatelessWidget {
  const CollapsibleTaskLists({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        if (state is SuccessGetTasksState) {
          final urgentTasks = state.uncompleteTasks
              .where((task) => task.urgencyLevel == TaskPriority.high)
              .toList();

          final todayTasks = state.uncompleteTasks.where((task) {
            final today = DateTime.now();
            return task.date != null &&
                task.date!.year == today.year &&
                task.date!.month == today.month &&
                task.date!.day == today.day;
          }).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildCollapsibleTaskList(
                  title: 'Urgent Tasks',
                  tasks: urgentTasks,
                ),
                _buildCollapsibleTaskList(
                  title: 'Tasks Due Today',
                  tasks: todayTasks,
                ),
              ],
            ),
          );
        } else if (state is LoadingGetTasksState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ErrorState) {
          return Center(child: Text(state.errorMsg));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  // Widget for collapsible task list
  Widget _buildCollapsibleTaskList({required String title, required List<Task> tasks}) {
    return ExpansionTile(
      title: Text(title),
      initiallyExpanded: true, // You can change this to false if you want it collapsed initially
      children: [
        if (tasks.isEmpty) 
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No tasks due today'),
          ),
        if(tasks.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200), // Limit the height of each list
            child: ListView.builder(
              shrinkWrap: true, // Makes the ListView fit within the ExpansionTile
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TaskCard(
                    task: task,
                    onCheckboxChanged: (value) {
                      // Handle checkbox state changes here
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
