import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/utils/colour_utils.dart';
import 'package:task_manager/core/utils/datetime_utils.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/widgets/task_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TaskFilter selectedFilter = TaskFilter.today;
  List<Task> uncompletedTasks = [];

  @override
  void initState() {
    super.initState();
    context.read<TasksBloc>().add(const OnGettingTasksEvent(withLoading: true));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              BlocBuilder<TasksBloc, TasksState>(
                builder: (context, state) {
                  if (state is SuccessGetTasksState) {
                    _applyFilter(state, selectedFilter);

                    return Column(
                      children: [
                        SizedBox(
                          height: 75,
                          child: Container(
                            decoration: BoxDecoration(
                              color: lightenColor(theme.colorScheme.surface, 0.05),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildTopBarItem(
                                    label: "Urgent",
                                    count: state.urgentCount,
                                    filter: TaskFilter.urgent),
                                _buildTopBarItem(
                                    label: "Today",
                                    count: state.todayCount,
                                    filter: TaskFilter.today),
                                _buildTopBarItem(
                                    label: "Overdue",
                                    count: state.overdueCount,
                                    filter: TaskFilter.overdue),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Main task list for uncompleted tasks
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.7,
                          ),
                          child: _buildUncompletedTaskList(),
                        ),
                      ],
                    );
                  } else if (state is LoadingGetTasksState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ErrorState) {
                    return Center(child: Text(state.errorMsg));
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBarItem({
    required String label,
    required int count,
    required TaskFilter filter,
  }) {
    final isSelected = selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : count > 0
                        ? Colors.red
                        : Colors.green,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUncompletedTaskList() {
    return TaskList(
      tasks: uncompletedTasks,
      isTappable: true,  // or false based on your needs
    );
  }

  // Widget _buildUncompletedTaskList() {
  //   return ListView(
  //     children: [
  //       if (uncompletedTasks.isEmpty)
  //         const Center(
  //           child: Padding(
  //             padding: EdgeInsets.symmetric(vertical: 20),
  //             child: Text(
  //               'No tasks available',
  //               style: TextStyle(fontSize: 18, color: Colors.grey),
  //             ),
  //           ),
  //         )
  //       else
  //         ...uncompletedTasks.map((task) {
  //           return Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 4.0),
  //             child: TaskCard(
  //               task: task,
  //               onCheckboxChanged: (value) {
  //                 // Handle checkbox state changes if necessary
  //               },
  //             ),
  //           );
  //         }).toList(),
  //     ],
  //   );
  // }

  void _applyFilter(SuccessGetTasksState state, TaskFilter filter) {
    switch (filter) {
      case TaskFilter.urgent:
        uncompletedTasks = state.displayTasks.where((task) => task.urgencyLevel == TaskPriority.high && !task.isDone).toList();
        break;
      case TaskFilter.today:
        uncompletedTasks = state.displayTasks.where((task) => isToday(task.date) && !task.isDone).toList();
        break;
      case TaskFilter.overdue:
        uncompletedTasks = state.displayTasks.where((task) => !task.isDone && isOverdue(task.date)).toList();
        break;
    }
  }
}

// Enum for Task Filters
enum TaskFilter { urgent, today, overdue }
