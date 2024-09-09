import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/widgets/Dialogs/task_list%20dialog.dart';
import 'package:task_manager/presentation/widgets/stats_number_card.dart';
import 'package:task_manager/presentation/widgets/task_card.dart';
import 'package:task_manager/presentation/widgets/task_indicator_card.dart';

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
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Today's tasks
              BlocBuilder<TasksBloc, TasksState>(
                builder: (context, state) {
                  if (state is SuccessGetTasksState) {
                    final incompleteTasks = state.dueTodayTasks
                        .where((task) => !task.isDone)
                        .toList();
                    return Expanded(
                      flex: 4,
                      child: _buildTaskList(incompleteTasks),
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
              // Task completion indicator

              // BlocBuilder<TasksBloc, TasksState>(
              //   builder: (context, state) {
              //     if (state is SuccessGetTasksState) {
              //       final highPriorityTasks = state.uncompleteTasks
              //           .where((task) => task.urgencyLevel == TaskPriority.high)
              //           .toList();

              //       final overdueTasks = state.uncompleteTasks
              //           .where((task) =>
              //               task.date != null &&
              //               task.date!.isBefore(DateTime.now()))
              //           .toList();

              //       return Expanded(
              //         flex: 1,
              //         child: Row(
              //           children: [
              //             Expanded(
              //               child: StatsNumberCard(
              //                 title: "Tasks Overdue",
              //                 number: overdueTasks.length,
              //                 onTap: () {
              //                   showTaskListDialog(
              //                     context,
              //                     title: "Overdue Tasks",
              //                     tasks: overdueTasks,
              //                   );
              //                 },
              //               ),
              //             ),
              //             Expanded(
              //               child: StatsNumberCard(
              //                 title: "Urgent Tasks",
              //                 number: highPriorityTasks.length,
              //                 onTap: () {
              //                   showTaskListDialog(
              //                     context,
              //                     title: "Urgent Tasks",
              //                     tasks: highPriorityTasks,
              //                   );
              //                 },
              //               ),
              //             ),
              //           ],
              //         ),
              //       );
              //     } else if (state is LoadingGetTasksState) {
              //       return const Center(child: CircularProgressIndicator());
              //     } else if (state is ErrorState) {
              //       return Center(child: Text(state.errorMsg));
              //     } else {
              //       return const SizedBox.shrink();
              //     }
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("No Tasks Due Today",
              style: TextStyle(
                fontSize: 15, 
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge!.color)),
        ],
      ));
    }
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return TaskCard(
          isTappable: false,
          task: tasks[index],
          onCheckboxChanged: (value) {
            setState(() {
              tasks[index].isDone = value!;
            });
          },
        );
      },
    );
  }
}
