import 'package:task_manager/data/entities/recurring_task_details_entity.dart';

class RecurringTaskDetails {
  final int? taskId;
  final List<DateTime>? scheduledDates;
  final List<DateTime>? completedOnDates;
  final List<DateTime>? missedDates;

  RecurringTaskDetails({
    this.taskId,
    this.scheduledDates,
    this.completedOnDates,
    this.missedDates,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RecurringTaskDetails &&
        other.taskId == taskId &&
        other.scheduledDates == scheduledDates &&
        other.completedOnDates == completedOnDates &&
        other.missedDates == missedDates;
  }

  @override
  int get hashCode =>
      Object.hash(taskId, scheduledDates, completedOnDates, missedDates);

  factory RecurringTaskDetails.fromEntity(RecurringTaskDetailsEntity entity) {
    return RecurringTaskDetails(
      taskId: entity.taskId,
      scheduledDates: entity.scheduledDates,
      completedOnDates: entity.completedOnDates,
      missedDates: entity.missedDates,
    );
  }

  RecurringTaskDetailsEntity toEntity() {
    return RecurringTaskDetailsEntity(
      taskId: taskId,
      scheduledDates: scheduledDates,
      completedOnDates: completedOnDates,
      missedDates: missedDates,
    );
  }

  RecurringTaskDetails copyWith({
    int? taskId,
    List<DateTime>? scheduledDates,
    List<DateTime>? completedOnDates,
    List<DateTime>? missedDates,
  }) {
    return RecurringTaskDetails(
      taskId: taskId ?? this.taskId,
      scheduledDates: scheduledDates ?? this.scheduledDates,
      completedOnDates: completedOnDates ?? this.completedOnDates,
      missedDates: missedDates ?? this.missedDates,
    );
  }
}
