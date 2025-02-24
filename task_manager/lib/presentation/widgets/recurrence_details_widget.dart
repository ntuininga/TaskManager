import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/domain/models/recurring_task_details.dart';

class RecurringTaskDetailsWidget extends StatelessWidget {
  final RecurringTaskDetails? details;

  const RecurringTaskDetailsWidget({Key? key, this.details}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (details == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("No recurring details available."),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection("Scheduled Dates", details!.scheduledDates),
        _buildSection("Completed On", details!.completedOnDates),
        _buildSection("Missed Dates", details!.missedDates),
      ],
    );
  }

  Widget _buildSection(String title, List<DateTime>? dates) {
    if (dates == null || dates.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 100, // Adjust height as needed
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat.yMMMd().format(dates[index]),
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
