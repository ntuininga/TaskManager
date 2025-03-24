import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
part 'task_entity.g.dart';

const String taskTableName = "tasks";

const String idField = "id";
const String titleField = "title";
const String descriptionField = "description";
const String isDoneField = "isDone";
const String dateField = "date";
const String taskCategoryIdField = "taskCategoryId";
const String urgencyLevelField = "urgencyLevel";
const String timeField = "time";
const String isRecurringField = "isRecurring";
const String recurrenceIdField = "RecurrenceId";
const String createdOnField = "createdOn";
const String updatedOnField = "updatedOn";
const String completedDateField = "completedDate";

enum TaskPriority { none, high }

class TimeOfDayConverter implements JsonConverter<TimeOfDay?, String?> {
  const TimeOfDayConverter();

  @override
  TimeOfDay? fromJson(String? json) {
    if (json == null) return null;
    final parts = json.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  String? toJson(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour}:${time.minute}';
  }
}

@JsonSerializable()
class TaskEntity {
  final int? id;
  final String? title;
  final String? description;
  final int isDone;
  final DateTime? date;
  final int? taskCategoryId;
  final TaskPriority urgencyLevel;
  @TimeOfDayConverter()
  final TimeOfDay? time;
  final int isRecurring;
  final int? recurrenceId;
  final DateTime createdOn;
  final DateTime updatedOn;
  final DateTime? completedDate;

  TaskEntity({
    this.id,
    this.title,
    this.description,
    this.isDone = 0,
    this.date,
    this.completedDate,
    DateTime? createdOn,
    DateTime? updatedOn,
    this.taskCategoryId = 0,
    this.urgencyLevel = TaskPriority.none,
    this.time,
    this.isRecurring = 0,
    this.recurrenceId,
  }) : createdOn = createdOn ?? DateTime.now(),
        updatedOn = updatedOn ?? DateTime.now();

  factory TaskEntity.fromJson(Map<String, dynamic> json) =>
      _$TaskEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TaskEntityToJson(this);

TaskEntity copyWith({
  int? id,
  String? title,
  String? description,
  int? isDone,
  DateTime? date,
  int? taskCategoryId,
  TaskPriority? urgencyLevel,
  TimeOfDay? time,
  int? isRecurring,
  int? recurrenceId,
  DateTime? createdOn,
  DateTime? updatedOn,
  DateTime? completedDate,
}) {
  return TaskEntity(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    isDone: isDone ?? this.isDone,
    date: date ?? this.date,
    completedDate: completedDate ?? this.completedDate,
    createdOn: createdOn ?? this.createdOn,
    taskCategoryId: taskCategoryId ?? this.taskCategoryId,
    urgencyLevel: urgencyLevel ?? this.urgencyLevel,
    time: time ?? this.time,
    isRecurring: isRecurring ?? this.isRecurring,
    recurrenceId: recurrenceId ?? this.recurrenceId,
    updatedOn: updatedOn ?? this.updatedOn,
  );
}

}
