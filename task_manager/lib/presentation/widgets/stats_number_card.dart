import 'package:flutter/material.dart';

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