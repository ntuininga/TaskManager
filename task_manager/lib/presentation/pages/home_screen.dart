import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/widgets/Dialogs/task_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskRepository taskRepository = GetIt.instance<TaskRepository>();

  int pendingTasks = 0;
  int completedTasks = 0;

  @override
  void initState() {
    super.initState();
    _fetchTaskData();
  }

  Future<void> _fetchTaskData() async {
    final taskDatasource = await AppDatabase.instance.taskDatasource;

    final pendingTasksList = await taskDatasource.getUnfinishedTasks();
    final completedTasksList = await taskDatasource.getCompletedTasks();

    setState(() {
      pendingTasks = pendingTasksList.length;
      completedTasks = completedTasksList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              height: 300,
              child: Card(
                child: Column(
                  children: [
                    Container(
                      height: 40,
                      child: const Center(
                        child: Text(
                          "Today's Tasks",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const Expanded(child: TaskList(isTappable: false)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Container(
                  height: 200,
                  child: StatsNumberCard(
                    title: "Tasks Pending",
                    number: pendingTasks,
                    description: "You have 1 Task left to Complete",
                  ),
                )),
                const SizedBox(width: 10),
                Expanded(child: Container(
                  height: 200,
                  child: StatsNumberCard(
                    title: "Completed Today",
                    number: completedTasks,
                    description: "You have completed 4 Tasks today",
                  ),
                )),
              ],
            ),
          ],
        ),
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
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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