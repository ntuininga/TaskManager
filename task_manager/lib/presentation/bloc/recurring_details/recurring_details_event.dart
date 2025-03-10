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
  final Task task;
  final DateTime startDate;
  final Frequency frequency; // Added to handle recurrence logic

  const ScheduleRecurringTaskDates({
    required this.taskId,
    required this.task,
    required this.startDate,
    required this.frequency,
  });

  @override
  List<Object> get props => [taskId, startDate, frequency];
}

class ClearRecurringTaskDates extends RecurringDetailsEvent {
  final int taskId;

  const ClearRecurringTaskDates({required this.taskId});

  @override
  List<Object> get props => [taskId];
}

class UpdateRecurringTaskDates extends RecurringDetailsEvent {
  final int taskId;
  final Task task;
  final List<DateTime>? newScheduledDates;
  final List<DateTime>? newCompletedDates;
  final List<DateTime>? newMissedDates;

  const UpdateRecurringTaskDates({
    required this.taskId,
    required this.task,
    this.newScheduledDates,
    this.newCompletedDates,
    this.newMissedDates,
  });

  @override
  List<Object> get props => [
        taskId,
        newScheduledDates ?? [],
        newCompletedDates ?? [],
        newMissedDates ?? [],
      ];
}

class CompleteRecurringTask extends RecurringDetailsEvent {
  final Task task;
  final DateTime? completedDate;

  const CompleteRecurringTask({
    required this.task,
    this.completedDate,
  });

  @override
  List<Object> get props => [task, completedDate ?? DateTime.now()];
}
