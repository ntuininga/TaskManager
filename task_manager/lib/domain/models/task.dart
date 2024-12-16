import 'package:flutter/material.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task_category.dart';

class Task {
  final int? id;
  String? title;
  String? description;
  bool isDone;
  DateTime? date;
  DateTime? completedDate;
  DateTime createdOn;
  TaskCategory? taskCategory;
  TaskPriority? urgencyLevel;
  bool reminder;
  DateTime? reminderDate;
  TimeOfDay? reminderTime;
  int? notifyBeforeMinutes;
  TimeOfDay? time;
  RecurrenceType? recurrenceType;

  // New recurrence-related fields
  final int? recurrenceInterval; // How often the task repeats
  final DateTime? startDate; // When the recurrence starts
  final DateTime? endDate; // When the recurrence ends (nullable)
  final DateTime? nextOccurrence; // Date of the next occurrence

  Task({
    this.id,
    this.title,
    this.description,
    this.isDone = false,
    this.date,
    this.completedDate,
    DateTime? createdOn,
    this.taskCategory,
    this.urgencyLevel = TaskPriority.none,
    this.reminder = false,
    this.reminderDate,
    this.reminderTime,
    this.notifyBeforeMinutes,
    this.time,
    this.recurrenceType,
    this.recurrenceInterval,
    this.startDate,
    this.endDate,
    this.nextOccurrence,
  }) : createdOn = createdOn ?? DateTime.now();

  static Task fromTaskEntity(TaskEntity entity) => Task(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        isDone: entity.isDone == 1,
        date: entity.date,
        completedDate: entity.completedDate,
        createdOn: entity.createdOn,
        urgencyLevel: entity.urgencyLevel,
        reminder: entity.reminder == 1,
        reminderDate: entity.reminderDate,
        reminderTime: entity.reminderTime,
        notifyBeforeMinutes: entity.notifyBeforeMinutes,
        time: entity.time,
        recurrenceType: entity.recurrenceType,
        recurrenceInterval: entity.recurrenceInterval,
        startDate: entity.startDate,
        endDate: entity.endDate,
        nextOccurrence: entity.nextOccurrence,
      );

  static TaskEntity toTaskEntity(Task model) => TaskEntity(
        id: model.id,
        title: model.title,
        description: model.description,
        isDone: model.isDone ? 1 : 0,
        date: model.date,
        completedDate: model.completedDate,
        taskCategoryId: model.taskCategory != null ? model.taskCategory!.id : 0,
        createdOn: model.createdOn,
        urgencyLevel: model.urgencyLevel ?? TaskPriority.none,
        reminder: model.reminder ? 1 : 0,
        reminderDate: model.reminderDate,
        reminderTime: model.reminderTime,
        notifyBeforeMinutes: model.notifyBeforeMinutes,
        time: model.time,
        recurrenceType: model.recurrenceType,
        recurrenceInterval: model.recurrenceInterval,
        startDate: model.startDate,
        endDate: model.endDate,
        nextOccurrence: model.nextOccurrence,
      );

  Map<String, dynamic> toJson() => {
        idField: id,
        titleField: title,
        descriptionField: description,
        isDoneField: isDone ? 1 : 0,
        dateField: date?.toIso8601String(),
        completedDateField: completedDate?.toIso8601String(),
        createdOnField: createdOn.toIso8601String(),
        urgencyLevelField:
            urgencyLevel.toString().split('.').last, // Store as string
        reminderField: reminder ? 1 : 0,
        reminderDateField: reminderDate?.toIso8601String(),
        reminderTimeField: reminderTime != null ? "${reminderTime!.hour}:${reminderTime!.minute}" : null,
        notifyBeforeMinutesField: notifyBeforeMinutes.toString(),
        timeField: time != null ? "${time!.hour}:${time!.minute}" : null,
        recurrenceTypeField: recurrenceType?.toString().split('.').last,
        recurrenceIntervalField: recurrenceInterval,
        startDateField: startDate?.toIso8601String(),
        endDateField: endDate?.toIso8601String(),
        nextOccurrenceField: nextOccurrence?.toIso8601String(),
      };

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isDone,
    DateTime? date,
    DateTime? completedDate,
    DateTime? createdOn,
    TaskCategory? taskCategory,
    TaskPriority? urgencyLevel,
    bool? reminder,
    DateTime? reminderDate,
    TimeOfDay? reminderTime,
    int? notifyBeforeMinutes,
    TimeOfDay? time,
    RecurrenceType? recurrenceType,
    int? recurrenceInterval,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextOccurrence,
    bool copyNullValues = false
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        isDone: isDone ?? this.isDone,
        date: date ?? this.date,
        completedDate: completedDate ?? this.completedDate,
        createdOn: createdOn ?? this.createdOn,
        taskCategory: copyNullValues || taskCategory != null ? taskCategory : this.taskCategory,
        urgencyLevel: urgencyLevel ?? this.urgencyLevel,
        reminder: reminder ?? this.reminder,
        reminderDate: reminderDate ?? this.reminderDate,
        reminderTime: reminderTime ?? this.reminderTime,
        notifyBeforeMinutes: notifyBeforeMinutes ?? this.notifyBeforeMinutes,
        time: time ?? this.time,
        recurrenceType: copyNullValues || recurrenceType != null ? recurrenceType : this.recurrenceType,
        recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      );
}

