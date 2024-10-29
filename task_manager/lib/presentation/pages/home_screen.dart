import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TaskFilter selectedFilter = TaskFilter.today;
  bool isCompletedListExpanded = false;
  List<Task> uncompletedTasks = [];
  List<Task> completedTasks = [];

  @override
  void initState() {
    super.initState();
    context.read<TasksBloc>().add(const OnGettingTasksEvent(withLoading: true));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.dividerColor;
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
                        // Top bar with task categories and counts
                        SizedBox(
                          height: 75,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
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
                                    count: _getUrgentTasks(state)
                                        .where((task) => !task.isDone)
                                        .length,
                                    filter: TaskFilter.urgent),
                                _buildTopBarItem(
                                    label: "Today",
                                    count: _getTodayTasks(state)
                                        .where((task) => !task.isDone)
                                        .length,
                                    filter: TaskFilter.today),
                                _buildTopBarItem(
                                    label: "Overdue",
                                    count: _getOverdueTasks(state)
                                        .where((task) => !task.isDone)
                                        .length,
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

  // Build top bar items with label and count
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
                    : Theme.of(context)
                        .colorScheme
                        .onSurface, // Responsive text color
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build task list for uncompleted tasks
  Widget _buildUncompletedTaskList() {
    return ListView(
      children: [
        // Uncompleted tasks list
        if (uncompletedTasks.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No tasks available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          )
        else
          ...uncompletedTasks.map((task) {
            return TaskCard(
              task: task,
              onCheckboxChanged: (value) {
                // Handle checkbox state changes if necessary
              },
            );
          }).toList(),

        const SizedBox(height: 10),

        // Collapsible completed tasks section
        if (completedTasks.isNotEmpty)
          GestureDetector(
            onTap: () {
              setState(() {
                isCompletedListExpanded = !isCompletedListExpanded;
              });
            },
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Completed Tasks (${completedTasks.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      isCompletedListExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
                if (isCompletedListExpanded)
                  Column(
                    children: completedTasks.map((task) {
                      return TaskCard(
                        task: task,
                        onCheckboxChanged: (value) {
                          // Handle checkbox state changes if necessary
                        },
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  // Apply filter and update uncompleted and completed tasks lists
  void _applyFilter(SuccessGetTasksState state, TaskFilter filter) {
    List<Task> filteredTasks;
    switch (filter) {
      case TaskFilter.urgent:
        filteredTasks = _getUrgentTasks(state);
        break;
      case TaskFilter.today:
        filteredTasks = _getTodayTasks(state);
        break;
      case TaskFilter.overdue:
        filteredTasks = _getOverdueTasks(state);
        break;
    }

    uncompletedTasks = filteredTasks.where((task) => !task.isDone).toList();
    completedTasks = filteredTasks
        .where((task) =>
            task.isDone &&
            task.completedDate != null &&
            _isToday(task.completedDate!) ||
            task.date != null &&
            _isToday(task.date!))
        .toList();
  }

  // Functions to get filtered tasks
  List<Task> _getUrgentTasks(SuccessGetTasksState state) {
    return state.allTasks
        .where((task) => task.urgencyLevel == TaskPriority.high)
        .toList();
  }

  List<Task> _getTodayTasks(SuccessGetTasksState state) {
    final now = DateTime.now();
    return state.allTasks.where((task) {
      return task.date != null &&
          task.date!.year == now.year &&
          task.date!.month == now.month &&
          task.date!.day == now.day;
    }).toList();
  }

  List<Task> _getOverdueTasks(SuccessGetTasksState state) {
    final now = DateTime.now();

    return state.allTasks.where((task) {
      return task.date != null &&
          task.date!.isBefore(now) &&
          task.date!.day < now.day;
    }).toList();
  }
}

bool _isToday(DateTime date) {
  final now = DateTime.now();

  return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
}

// Enum for Task Filters
enum TaskFilter { urgent, today, overdue }
