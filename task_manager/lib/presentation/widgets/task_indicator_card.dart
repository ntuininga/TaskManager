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
    return LayoutBuilder(
      builder: (context, constraints) {
        double effectiveHeight = height ?? constraints.maxHeight;

        return Container(
          width: double.infinity,
          height: effectiveHeight,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: effectiveHeight * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (min != null && max != null)
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: CircularPercentIndicator(
                        radius: effectiveHeight * 0.25,
                        lineWidth: 7,
                        progressColor: Theme.of(context).colorScheme.primary,
                        percent: percent ?? 0.0,
                        center: Text(
                          "$min / $max",
                          style: TextStyle(
                            fontSize: effectiveHeight * 0.10,
                          ),
                        ),
                      ),
                    ),
                  if (description != null)
                    Text(
                      description!,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: effectiveHeight * 0.06,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
