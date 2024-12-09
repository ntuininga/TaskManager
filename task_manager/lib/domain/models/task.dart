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
      );
}
