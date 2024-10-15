import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskRepository taskRepository = GetIt.instance<TaskRepository>();

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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Task Summary Section
              BlocBuilder<TasksBloc, TasksState>(
                builder: (context, state) {
                  if (state is SuccessGetTasksState) {
                    final incompleteTasks = state.dueTodayTasks
                        .where((task) => !task.isDone)
                        .toList();
                    final completedTasks = state.dueTodayTasks
                        .where((task) => task.isDone)
                        .toList();
                    final overdueTasks = List.from(state.uncompleteTasks.where(
                        (task) =>
                            task.date != null &&
                            task.date!.isBefore(DateTime.now())));
                    final totalTasks =
                        incompleteTasks.length + completedTasks.length;
                    final upcomingTasks =
                        _getUpcomingTasks(state.uncompleteTasks).length;

                    return Column(
                      children: [
                        _buildSummarySection(
                          totalTasks: totalTasks,
                          completedTasks: completedTasks.length,
                          overdueTasks: overdueTasks.length,
                          upcomingTasks: upcomingTasks,
                        ),
                        const SizedBox(height: 20),
                        _buildProgressIndicator(
                          totalTasks: totalTasks,
                          completedTasks: completedTasks.length,
                        ),
                        const SizedBox(height: 20),
                        _buildUrgentTaskList(incompleteTasks),
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
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Function to get upcoming tasks
  List<Task> _getUpcomingTasks(List<Task> allTasks) {
    final now = DateTime.now();
    return allTasks.where((task) {
      return task.date != null && task.date!.isAfter(now) && !task.isDone;
    }).toList();
  }

  // Task Summary Section
  Widget _buildSummarySection({
    required int totalTasks,
    required int completedTasks,
    required int overdueTasks,
    required int upcomingTasks,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSummaryTile("Total", totalTasks),
        _buildSummaryTile("Completed", completedTasks),
        _buildSummaryTile("Overdue", overdueTasks),
        _buildSummaryTile("Upcoming", upcomingTasks),
      ],
    );
  }

  Widget _buildSummaryTile(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  // Progress Indicator
  Widget _buildProgressIndicator(
      {required int totalTasks, required int completedTasks}) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: completedTasks /
              (totalTasks == 0 ? 1 : totalTasks), // prevent division by 0
          backgroundColor: Colors.grey[300],
          color: Colors.green,
        ),
        const SizedBox(height: 10),
        Text(
          "${(completedTasks / (totalTasks == 0 ? 1 : totalTasks) * 100).toStringAsFixed(1)}% Completed",
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

Widget _buildUrgentTaskList(List<Task> tasks) {
  final now = DateTime.now();
  final soonDeadline = now.add(const Duration(hours: 1));

  return SizedBox(
    height: 300,
    child: ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isUrgent = task.date != null && task.date!.isBefore(soonDeadline);
        final taskColor = isUrgent ? Colors.redAccent : Colors.black;
    
        return ListTile(
          title: Text(
            task.title!,
            style: TextStyle(
              color: taskColor,
              fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            'Due: ${DateFormat('yyyy-MM-dd – HH:mm').format(task.date!)}',
            style: TextStyle(color: taskColor),
          ),
          trailing: Checkbox(
            value: task.isDone,
            onChanged: (bool? value) {
              setState(() {
                tasks[index].isDone = value!;
              });
            },
          ),
        );
      },
    ),
  );
}


}
