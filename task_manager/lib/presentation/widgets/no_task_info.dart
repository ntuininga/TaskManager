import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';

class NoTaskInfo extends StatefulWidget {
  const NoTaskInfo({super.key});

  @override
  State<NoTaskInfo> createState() => _NoTaskInfoState();
}

class _NoTaskInfoState extends State<NoTaskInfo> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          if (state is SuccessGetTasksState) {
            final overdueTasksCount = state.uncompleteTasks
                .where((task) =>
                    task.date != null && task.date!.isBefore(DateTime.now()))
                .length;
            final highPriorityCount = state.uncompleteTasks
                .where((task) => task.urgencyLevel == TaskPriority.high)
                .length;
      
            final completedTasksCount = state.uncompleteTasks.length; 
      
            final primaryColor = Theme.of(context).primaryColor;
            final errorColor = Theme.of(context).colorScheme.error;
            final secondaryColor = Theme.of(context).colorScheme.secondary; // Slightly transparent version of primary color
            final tertiaryColor = Theme.of(context).colorScheme.primary; // More transparent
      
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Centers vertically
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Centers horizontally
                children: [
                  const Text("No Tasks Due Today",
                    style: TextStyle(
                      fontSize: 17,
                    ),),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Centers the Row
                    children: [
                      Column(
                        children: [
                          Text(
                            overdueTasksCount > 10 ? "10+" : overdueTasksCount.toString(),
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.w900,
                              color: overdueTasksCount > 10 ? errorColor : primaryColor, // Primary color
                            ),
                          ),
                          const Text("Overdue"),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          const Text("Urgent"),
                          Text(
                            highPriorityCount > 10 ? "10+" : highPriorityCount.toString(),
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.w900,
                              color: highPriorityCount > 10 ? errorColor : secondaryColor, // Lighter version of primary
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
      
                      Text(
                        completedTasksCount.toString(),
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                          color: tertiaryColor, // Even lighter version
                        ),
                      ),
                      const Text("Completed"),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text("No Tasks Due Today"),
            );
          }
        },
      ),
    );
  }
}
