import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: Card(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 40,
                      child: Center(
                        child: Text(
                          "Today's Tasks",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    BlocBuilder<TasksBloc, TasksState>(
                        builder: (context, state) {
                      if (state is LoadingGetTasksState) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is SuccessGetTasksState) {
                        if (state.dueTodayTasks.isEmpty) {
                          return const Center(
                            child: Text("No Tasks Due Today")
                          );
                        } 
                        return _buildTaskList(state.dueTodayTasks);
                  } else if (state is NoTasksState) {
                    return const Center(child: Text("No Tasks"));
                  } else if (state is ErrorState) {
                    return Center(child: Text(state.errorMsg));
                  } else {
                    return const Center(child: Text("Unknown Error"));
                  }
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    return Expanded(
      child: ListView.builder(
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
      ),
    );
  }
}

class TasksIndicatorCard extends StatelessWidget {
  final String title;
  final int? min;
  final int? max;
  final String? description;
  final double? height;

  const TasksIndicatorCard({
    required this.title,
    this.min,
    this.max,
    this.description,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            if (min != null && max != null)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: CircularPercentIndicator(
                  radius: 50,
                  lineWidth: 7.0,
                  progressColor: Theme.of(context).colorScheme.primary,
                  percent: (min! / max!),
                  center: Text("$min / $max"),
                ),
              ),
            if (description != null)
              Text(
                description!,
                softWrap: true,
              ),
          ],
        ),
      ),
    );
  }
}

class StatsNumberCard extends StatelessWidget {
  final String? title;
  final int? number;
  final String? description;

  const StatsNumberCard({
    this.title,
    this.number,
    this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (title != null)
              Text(
                title!,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            if (number != null)
              Text(
                number.toString(),
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            if (description != null)
              Text(
                description!,
                softWrap: true,
              ),
          ],
        ),
      ),
    );
  }
}
