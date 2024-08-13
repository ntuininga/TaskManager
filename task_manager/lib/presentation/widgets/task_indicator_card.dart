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
    return Container(
      width: double.infinity,
      height: height,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (min != null && max != null)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CircularPercentIndicator(
                    radius: height != null ? height! * 0.3 : 70,
                    lineWidth: 10.0,
                    progressColor: Theme.of(context).colorScheme.primary,
                    percent: percent ?? 0.0,
                    center: Text("$min / $max", style: const TextStyle(fontSize: 20)),
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
    );
  }
}