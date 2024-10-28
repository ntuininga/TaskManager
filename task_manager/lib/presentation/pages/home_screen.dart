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
              const SizedBox(height: 20),
              BlocBuilder<TasksBloc, TasksState>(
                builder: (context, state) {
                  if (state is SuccessGetTasksState) {
                    final urgentTasks = _getUrgentTasks(state);
                    final todayTasks = _getTodayTasks(state);
                    final overdueTasks = _getOverdueTasks(state);

                    return Column(
                      children: [
                        // Top bar with task categories and counts
// Top bar with task categories and counts
SizedBox(
  height: 75,
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white, // Background color of the top bar
      borderRadius: BorderRadius.circular(10), // Optional: Rounded corners
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1), // Shadow color
          spreadRadius: 1, // Spread radius
          blurRadius: 4, // Blur radius
          offset: Offset(0, 2), // Shadow position
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTopBarItem(
            label: "Urgent",
            count: urgentTasks.length,
            filter: TaskFilter.urgent),
        _buildTopBarItem(
            label: "Today",
            count: todayTasks.length,
            filter: TaskFilter.today),
        _buildTopBarItem(
            label: "Overdue",
            count: overdueTasks.length,
            filter: TaskFilter.overdue),
      ],
    ),
  ),
),

                        const SizedBox(height: 20),
                        // Wrap the ListView in ConstrainedBox to control its height
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.7,
                          ),
                          child: _buildTaskList(state),
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
            ? Theme.of(context).colorScheme.primary.withOpacity(0.2) // Highlight background
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10), // Optional: Rounded corners
      ),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : count > 0 ? Colors.red : Colors.green,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}


  // Build task list based on selected filter
  Widget _buildTaskList(SuccessGetTasksState state) {
    List<Task> filteredTasks;
    switch (selectedFilter) {
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

    return filteredTasks.isEmpty
        ? const Center(
            child: Text(
              'No tasks available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          )
        : ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return TaskCard(
                task: task,
                onCheckboxChanged: (value) {
                  // Handle checkbox state changes if necessary
                },
              );
            },
          );
  }

  // Functions to get filtered tasks
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
}

// Enum for Task Filters
enum TaskFilter { urgent, today, overdue }
