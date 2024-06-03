import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:task_manager/presentation/widgets/Dialogs/task_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                    const Expanded(child: TaskList()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(child: TasksIndicatorCard(
                  title: "Tasks Pending",
                  max: 4,
                  min: 1,
                  description: "You have 1 Task left to Complete",
                )),
                SizedBox(width: 10),
                Expanded(child: TasksIndicatorCard(
                  title: "Tasks Completed",
                  min: 3,
                  max: 4,
                  description: "Description",)),
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

  const TasksIndicatorCard({
    required this.title,
    this.min,
    this.max,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            if (min != null && max != null)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: CircularPercentIndicator(
                  radius: 60,
                  lineWidth: 7.0,
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
