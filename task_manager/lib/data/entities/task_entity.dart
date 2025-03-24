import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
part 'task_entity.g.dart';

const String taskTableName = "tasks";

const String idField = "id";
const String titleField = "title";
const String descriptionField = "description";
const String isDoneField = "isDone";
const String dateField = "date";
const String completedDateField = "completedDate";
const String createdOnField = "createdOn";
const String taskCategoryField = "taskCategoryId";
const String urgencyLevelField = "urgencyLevel";
const String reminderField = "reminder";
const String reminderDateField = "reminderDate";
const String reminderTimeField = "reminderTime";
const String notifyBeforeMinutesField = "notifyBeforeMinutes";
const String timeField = "time";
const String recurrenceTypeField = "recurrenceType";
const String recurrenceIntervalField = "recurrenceInterval";
const String startDateField = "startDate";
const String endDateField = "endDate";
const String nextOccurrenceField = "nextOccurrence";
const String selectedDaysField = "selectedDays";
const String recurrenceOptionField = "recurrenceOption";
const String occurenceCountField = "occurrenceCount";
const String recurrenceRuleSetField = "recurrenceRuleset";

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

class BoolListConverter implements JsonConverter<List<bool>?, List<dynamic>?> {
  const BoolListConverter();

  @override
  List<bool>? fromJson(List<dynamic>? json) {
    // Convert List<int> to List<bool>
    return json?.map((e) => e == 1).toList();
  }

  @override
  List<int>? toJson(List<bool>? list) {
    if (list == null) return null;
    return list.map((e) => e ? 1 : 0).toList();
  }
}

@JsonSerializable()
class TaskEntity {
  final int? id;
  final String? title;
  final String? description;
  final int isDone;
  final DateTime? date;
  final DateTime? completedDate;
  final DateTime createdOn;
  final int? taskCategoryId;
  final TaskPriority urgencyLevel;
  @TimeOfDayConverter()
  final TimeOfDay? time;
  final DateTime? nextOccurrence;
  final String? recurrenceRuleset;

  TaskEntity({
    this.id,
    this.title,
    this.description,
    this.isDone = 0,
    this.date,
    this.completedDate,
    DateTime? createdOn,
    this.taskCategoryId = 0,
    this.urgencyLevel = TaskPriority.none,
    this.time,
    this.nextOccurrence,
    this.recurrenceRuleset,
  }) : createdOn = createdOn ?? DateTime.now();

  factory TaskEntity.fromJson(Map<String, dynamic> json) =>
      _$TaskEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TaskEntityToJson(this);

  TaskEntity copyWith({
    int? id,
    String? title,
    String? description,
    int? isDone,
    DateTime? date,
    DateTime? completedDate,
    DateTime? createdOn,
    int? taskCategoryId,
    TaskPriority? urgencyLevel,
    int? reminder,
    DateTime? reminderDate,
    TimeOfDay? reminderTime,
    int? notifyBeforeMinutes,
    TimeOfDay? time,
    DateTime? nextOccurrence,
    String? recurrenceRuleset,
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
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      recurrenceRuleset:
          recurrenceRuleset ?? this.recurrenceRuleset, 
    );
  }
}
