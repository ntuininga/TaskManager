import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TasksIndicatorCard extends StatelessWidget {
  final String title;
  final int? min;
  final int? max;
  final String? description;
  final double? height;
  final double? percent;

  const TasksIndicatorCard({
    required this.title,
    this.min,
    this.max,
    this.description,
    this.height,
    this.percent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        child: Card(
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
                      percent: percent ?? 0.0,
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
        ),
      ),
    );
  }
}