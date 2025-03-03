part of 'recurring_details_bloc.dart';

sealed class RecurringDetailsEvent extends Equatable {
  const RecurringDetailsEvent();

  @override
  List<Object> get props => [];
}

class FetchRecurringTaskDetails extends RecurringDetailsEvent {
  final int taskId;

  const FetchRecurringTaskDetails({required this.taskId});

  @override
  List<Object> get props => [taskId];
}

class ScheduleRecurringTaskDates extends RecurringDetailsEvent {
  final int taskId;
  final DateTime startDate;
  final Frequency frequency; // Added to handle recurrence logic

  const ScheduleRecurringTaskDates({
    required this.taskId,
    required this.startDate,
    required this.frequency,
  });

  @override
  List<Object> get props => [taskId, startDate, frequency];
}
