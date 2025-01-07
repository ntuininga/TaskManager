import 'dart:typed_data';

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

enum TaskPriority { none, high }

enum RecurrenceType { daily, weekly, monthly, yearly }

enum RecurrenceOption { endDate, count, infinite }

extension RecurrenceOptionExtension on RecurrenceOption {
  // A helper method to convert a string to a RecurrenceOption
  static RecurrenceOption fromString(String? value) {
    if (value != null) {
      switch (value.toLowerCase()) {
        case 'end date':
          return RecurrenceOption.endDate;
        case 'count':
          return RecurrenceOption.count;
        case 'infinite':
          return RecurrenceOption.infinite;
        default:
          throw ArgumentError('Invalid recurrence option: $value');
      }
    } else {
      throw ArgumentError('Invalid recurrence option: $value');
    }
  }
}

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
    // Convert List<bool> to List<int>
    return Uint8List.fromList(list!.map((e) => e ? 1 : 0).toList());
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
  final int reminder;
  final DateTime? reminderDate;
  @TimeOfDayConverter()
  final TimeOfDay? reminderTime;
  final int? notifyBeforeMinutes;
  @TimeOfDayConverter()
  final TimeOfDay? time;
  final RecurrenceType? recurrenceType;
  final int? recurrenceInterval;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? nextOccurrence;
  @BoolListConverter()
  final List<bool>? selectedDays; // For weekly recurrence (e.g., Mon, Tue)
  final RecurrenceOption? recurrenceOption;
  final int? occurrenceCount;

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
    this.reminder = 0,
    this.reminderDate,
    this.reminderTime,
    this.notifyBeforeMinutes,
    this.time,
    this.recurrenceType,
    this.recurrenceInterval,
    this.startDate,
    this.endDate,
    this.nextOccurrence,
    this.selectedDays,
    this.recurrenceOption,
    this.occurrenceCount,
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
    RecurrenceType? recurrenceType,
    int? recurrenceInterval,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextOccurrence,
    List<bool>? selectedDays,
    RecurrenceOption? recurrenceOption,
    int? occurrenceCount,
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
      reminder: reminder ?? this.reminder,
      reminderDate: reminderDate ?? this.reminderDate,
      reminderTime: reminderTime ?? this.reminderTime,
      notifyBeforeMinutes: notifyBeforeMinutes ?? this.notifyBeforeMinutes,
      time: time ?? this.time,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      selectedDays: selectedDays ?? this.selectedDays,
      recurrenceOption: recurrenceOption ?? this.recurrenceOption,
      occurrenceCount: occurrenceCount ?? this.occurrenceCount,
    );
  }
}
