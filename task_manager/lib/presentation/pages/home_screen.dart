import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
  TaskFilter selectedFilter = TaskFilter.urgent; // Default filter

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
                      final todayTasks = _getTodayTasks(state);
                      final overdueTasks = _getOverdueTasks(state);

                      return Card(
                        child: Column(
                          children: [
                            // Tab-like buttons with task count
                            Row(
                              children: [
                                _buildFilterTab('Urgent', urgentTasks.length, TaskFilter.urgent),
                                _buildFilterTab('Today', todayTasks.length, TaskFilter.today),
                                _buildFilterTab('Overdue', overdueTasks.length, TaskFilter.overdue),
                              ],
                            ),
                            const SizedBox(height: 10), // Space between buttons and list
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView.builder(
                                  itemCount: filteredTasks.length,
                                  itemBuilder: (context, index) {
                                    final task = filteredTasks[index];
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
  Widget _buildFilterTab(String label, int count, TaskFilter filter) {
    final isSelected = selectedFilter == filter;
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
            color: isSelected ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
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
    return state.uncompleteTasks.where((task) {
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
}

// Enum for Task Filters
enum TaskFilter { urgent, today, overdue }
