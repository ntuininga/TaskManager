import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/domain/models/recurring_task_details.dart';
import 'package:task_manager/presentation/bloc/recurring_details/recurring_details_bloc.dart';

class RecurringTaskDetailsWidget extends StatefulWidget {
  final int taskId;

  const RecurringTaskDetailsWidget({Key? key, required this.taskId}) : super(key: key);

  @override
  _RecurringTaskDetailsWidgetState createState() => _RecurringTaskDetailsWidgetState();
}

class _RecurringTaskDetailsWidgetState extends State<RecurringTaskDetailsWidget> {
  @override
  void initState() {
    super.initState();
    context.read<RecurringDetailsBloc>().add(FetchRecurringTaskDetails(taskId: widget.taskId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecurringDetailsBloc, RecurringDetailsState>(
      builder: (context, state) {
        if (state is RecurringTaskDetailsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RecurringTaskDetailsLoaded) {
          return _buildDetails(state.details);
        } else if (state is RecurringTaskDetailsError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Error: ${state.message}"),
          );
        }
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("No recurring details available."),
        );
      },
    );
  }

  Widget _buildDetails(RecurringTaskDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection("Scheduled Dates", details.scheduledDates),
        _buildSection("Completed On", details.completedOnDates),
        _buildSection("Missed Dates", details.missedDates),
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
