import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/widgets/stats_number_card.dart';
import 'package:task_manager/presentation/widgets/task_card.dart';
import 'package:task_manager/presentation/widgets/task_indicator_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TaskRepository taskRepository = GetIt.instance<TaskRepository>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<TasksBloc>().add(const OnGettingTasksEvent(withLoading: true));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // const SizedBox(height: 20),
              Expanded(
                flex: 3,
                child: Card(
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: "Today's Tasks"),
                          Tab(text: "Completed Tasks"),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildIncompleteTasksTab(),
                              _buildCompletedTasksTab(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // const SizedBox(height: 20),
              BlocBuilder<TasksBloc, TasksState>(
                builder: (context, state) {
                  if (state is SuccessGetTasksState) {
                    final int completedCount =
                        state.dueTodayTasks.where((task) => task.isDone).length;
                    final int dueTodayCount = state.dueTodayTasks.length;
                    final double completionRate =
                        dueTodayCount > 0 ? completedCount / dueTodayCount : 0;
          
                    return Expanded(
                      flex: 2,
                      child: TasksIndicatorCard(
                        title: "Tasks Due Today",
                        min: completedCount,
                        max: dueTodayCount,
                        description:
                            "Completed: $completedCount / $dueTodayCount",
                        height: screenHeight * 0.25,
                        percent: completionRate,
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
              // const SizedBox(height: 20),
              BlocBuilder<TasksBloc, TasksState>(
                builder: (context, state) {
                  if (state is SuccessGetTasksState) {
                    final int overdueCount =
                        state.uncompleteTasks.where((task) {
                      if (task.date != null) {
                        final DateTime now = DateTime.now();
                        return task.date!.year < now.year ||
                            (task.date!.year == now.year &&
                                task.date!.month < now.month) ||
                            (task.date!.year == now.year &&
                                task.date!.month == now.month &&
                                task.date!.day < now.day);
                      }
                      return false;
                    }).length;
          
                    final int highPriorityCount = state.uncompleteTasks
                        .where((task) => task.urgencyLevel == TaskPriority.high)
                        .length;
          
                    return Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Expanded(
                            child: StatsNumberCard(
                              title: "Tasks Overdue",
                              number: overdueCount,
                            ),
                          ),
                          Expanded(
                            child: StatsNumberCard(
                              title: "High Priority Tasks",
                              number: highPriorityCount,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncompleteTasksTab() {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        if (state is LoadingGetTasksState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SuccessGetTasksState) {
          final incompleteTasks =
              state.dueTodayTasks.where((task) => !task.isDone).toList();
          if (incompleteTasks.isEmpty) {
            return const Center(child: Text("No Incomplete Tasks"));
          }
          return _buildTaskList(incompleteTasks);
        } else if (state is NoTasksState) {
          return const Center(child: Text("No Tasks"));
        } else if (state is ErrorState) {
          return Center(child: Text(state.errorMsg));
        } else {
          return const Center(child: Text("Unknown Error"));
        }
      },
    );
  }

  Widget _buildCompletedTasksTab() {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        if (state is LoadingGetTasksState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SuccessGetTasksState) {
          final completedTodayTasks = state.allTasks.where((task) {
            final now = DateTime.now();
            return task.isDone &&
                task.completedDate != null &&
                task.completedDate!.year == now.year &&
                task.completedDate!.month == now.month &&
                task.completedDate!.day == now.day;
          }).toList();
          if (completedTodayTasks.isEmpty) {
            return const Center(child: Text("No Tasks Completed Today"));
          }
          return _buildTaskList(completedTodayTasks);
        } else if (state is NoTasksState) {
          return const Center(child: Text("No Tasks"));
        } else if (state is ErrorState) {
          return Center(child: Text(state.errorMsg));
        } else {
          return const Center(child: Text("Unknown Error"));
        }
      },
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return TaskCard(
          isTappable: false,
          task: tasks[index],
          onCheckboxChanged: (value) {
            setState(() {
              tasks[index].isDone = value!;
              // db.updateTask(tasks[index]);
            });
          },
        );
      },
    );
  }
}
