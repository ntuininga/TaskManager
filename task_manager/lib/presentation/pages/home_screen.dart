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
                Expanded(child: PendingTaskCard()),
                SizedBox(width: 10),
                Expanded(child: CompletedTasksCard()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CompletedTasksCard extends StatelessWidget {
  const CompletedTasksCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tasks Completed",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CircularPercentIndicator(
                radius: 60,
                lineWidth: 7.0,
                percent: 0.25,
                center: Text("1 / 4"),
              ),
            ),
            const Text(
              "You have 3 tasks left to complete",
              softWrap: true,
            ),
          ],
        ),
      ),
    );
  }
}

class PendingTaskCard extends StatelessWidget {
  const PendingTaskCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tasks Pending",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CircularPercentIndicator(
                radius: 60,
                lineWidth: 7.0,
                percent: 0.75,
                center: Text("3 / 4"),
              ),
            ),
            const Text(
              "You have 1 task left to complete",
              softWrap: true,
            ),
          ],
        ),
      ),
    );
  }
}
