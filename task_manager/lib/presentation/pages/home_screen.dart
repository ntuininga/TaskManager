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
  TaskFilter selectedFilter = TaskFilter.today; // Default filter

  @override
  void initState() {
    super.initState();
    context.read<TasksBloc>().add(const OnGettingTasksEvent(withLoading: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Expanded(
                child: BlocBuilder<TasksBloc, TasksState>(
                  builder: (context, state) {
                    if (state is SuccessGetTasksState) {
                      List<Task> filteredTasks = _getFilteredTasks(state);
                      final urgentTasks = _getUrgentTasks(state);
                      final allTodaysTasks = _getTodayTasks(state);
                      final todayTasks =
                          allTodaysTasks.where((task) => !task.isDone);
                      final overdueTasks = _getOverdueTasks(state);
                      final completedTodayTasks =
                          _getCompletedTodayTasks(state);
                      final completedTasks =
                          state.allTasks.where((task) => task.isDone);

                      bool hasTasksDueToday = allTodaysTasks.isNotEmpty;
                      double progressValue = hasTasksDueToday
                          ? (completedTodayTasks.length / allTodaysTasks.length)
                          : (completedTasks.length / state.allTasks.length);

                      // Calculate percentage for the progress meter
                      final progressPercentage = (progressValue.isNaN
                              ? 0
                              : progressValue * 100)
                          .toStringAsFixed(0);

                      return Column(
                        children: [
                          // Progress Indicator Card (1/3 height)
                          Expanded(
                            flex: 1,
                            child: Card(
                              elevation: 3,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      hasTasksDueToday
                                          ? 'Today\'s Progress'
                                          : 'Overall Progress',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          height: 75,
                                          width: 75,
                                          child: CircularProgressIndicator(
                                            value: progressValue.isNaN
                                                ? 0
                                                : progressValue,
                                            strokeWidth: 6,
                                            backgroundColor:
                                                Theme.of(context).canvasColor,
                                          ),
                                        ),
                                        // Display percentage in the center
                                        Text(
                                          '$progressPercentage%',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      hasTasksDueToday
                                          ? '${completedTodayTasks.length} of ${allTodaysTasks.length} tasks completed'
                                          : '${completedTasks.length} of ${state.allTasks.length} tasks completed',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                              height:
                                  20), // Space between progress card and task list

                          // Tab and Task List Card (2/3 height)
                          Expanded(
                            flex: 2,
                            child: Card(
                              child: Column(
                                children: [
                                  // Tab-like buttons with task count and bottom shadow
                                  Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .shadow
                                              .withOpacity(0.2),
                                          offset: const Offset(
                                              0, 3), // Shadow at bottom
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        _buildFilterTab(
                                          'Urgent',
                                          urgentTasks.length,
                                          TaskFilter.urgent,
                                          isFirst: true,
                                        ),
                                        _buildFilterTab(
                                          'Today',
                                          todayTasks.length,
                                          TaskFilter.today,
                                        ),
                                        _buildFilterTab(
                                          'Overdue',
                                          overdueTasks.length,
                                          TaskFilter.overdue,
                                          isLast: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                      height:
                                          10), // Space between buttons and list
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: filteredTasks.isEmpty
                                          ? const Center(
                                              child: Text(
                                                'No tasks available',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.grey),
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount: filteredTasks.length,
                                              itemBuilder: (context, index) {
                                                final task =
                                                    filteredTasks[index];
                                                return TaskCard(
                                                  task: task,
                                                  onCheckboxChanged: (value) {
                                                    // Handle checkbox state changes
                                                  },
                                                );
                                              },
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build tab-like filter buttons
  Widget _buildFilterTab(String label, int count, TaskFilter filter,
      {bool isFirst = false, bool isLast = false}) {
    final isSelected = selectedFilter == filter;

    // Define color based on whether there are tasks (red if count > 0, green if 0)
    final textColor =
        (filter == TaskFilter.urgent || filter == TaskFilter.overdue) &&
                count > 0
            ? Colors.red
            : Colors.green;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = filter;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).canvasColor,
            borderRadius: BorderRadius.only(
              topLeft: isFirst ? const Radius.circular(10) : Radius.zero,
              topRight: isLast ? const Radius.circular(10) : Radius.zero,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : textColor, // Use red/green based on count
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : textColor, // Use red/green based on count
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // Functions to get filtered tasks
  List<Task> _getFilteredTasks(SuccessGetTasksState state) {
    switch (selectedFilter) {
      case TaskFilter.urgent:
        return _getUrgentTasks(state);
      case TaskFilter.today:
        return _getTodayTasks(state);
      case TaskFilter.overdue:
        return _getOverdueTasks(state);
      default:
        return [];
    }
  }

  List<Task> _getUrgentTasks(SuccessGetTasksState state) {
    return state.uncompleteTasks
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
    return state.uncompleteTasks.where((task) {
      return task.date != null && task.date!.isBefore(now);
    }).toList();
  }

  List<Task> _getCompletedTodayTasks(SuccessGetTasksState state) {
    final now = DateTime.now();
    return state.allTasks.where((task) {
      return task.date != null &&
          task.date!.year == now.year &&
          task.date!.month == now.month &&
          task.date!.day == now.day &&
          task.isDone == true;
    }).toList();
  }
}

// Enum for Task Filters
enum TaskFilter { urgent, today, overdue }
