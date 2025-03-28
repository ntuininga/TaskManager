import 'package:flutter/material.dart';
import 'package:task_manager/data/entities/recurring_instance_entity.dart';

class RecurringInstance {
  final int? id;
  final int? taskId;
  final DateTime? occurrenceDate;
  final TimeOfDay? occurrenceTime;
  final bool isDone;
  final DateTime? completedAt;

  RecurringInstance({
    this.id,
    this.taskId,
    this.occurrenceDate,
    this.occurrenceTime,
    this.isDone = false,
    this.completedAt,
  });

  /// Convert from RecurringInstanceEntity to RecurringInstance
  factory RecurringInstance.fromEntity(RecurringInstanceEntity entity) {
    return RecurringInstance(
      id: entity.instanceId,
      taskId: entity.taskId,
      occurrenceDate: entity.occurrenceDate,
      occurrenceTime: entity.occurrenceTime,
      isDone: entity.isDone == 1,
      completedAt: entity.completedAt,
    );
  }

  /// Convert to RecurringInstanceEntity
  RecurringInstanceEntity toEntity() {
    return RecurringInstanceEntity(
      instanceId: id,
      taskId: taskId,
      occurrenceDate: occurrenceDate,
      occurrenceTime: occurrenceTime,
      isDone: isDone ? 1 : 0,
      completedAt: completedAt,
    );
  }

  /// Create a new instance with modified fields
  RecurringInstance copyWith({
    int? id,
    int? taskId,
    DateTime? occurrenceDate,
    TimeOfDay? occurrenceTime,
    bool? isDone,
    DateTime? completedAt,
  }) {
    return RecurringInstance(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      occurrenceTime: occurrenceTime ?? this.occurrenceTime,
      isDone: isDone ?? this.isDone,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
