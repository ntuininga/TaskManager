import 'package:flutter/material.dart';
import 'package:task_manager/data/entities/recurrence_ruleset.dart';
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
  RecurrenceRuleset? recurrenceRuleset;
  final DateTime? nextOccurrence; // Date of the next occurrence

  Task(
      {this.id,
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
      this.nextOccurrence,
      this.recurrenceRuleset})
      : createdOn = createdOn ?? DateTime.now();

  static Task fromTaskEntity(TaskEntity entity) => Task(
    id: entity.id,
    title: entity.title,
    description: entity.description,
    isDone: entity.isDone == 1,
    date: entity.date,
    completedDate: entity.completedDate,
    createdOn: entity.createdOn,
    urgencyLevel: entity.urgencyLevel,
    time: entity.time,
    nextOccurrence: entity.nextOccurrence,
    recurrenceRuleset: entity.recurrenceRuleset != null
        ? RecurrenceRuleset.fromString(entity.recurrenceRuleset!)
        : null,
  );


  static Future<TaskEntity> toTaskEntity(Task model) async => TaskEntity(
        id: model.id,
        title: model.title,
        description: model.description,
        isDone: model.isDone ? 1 : 0,
        date: model.date,
        completedDate: model.completedDate,
        taskCategoryId: model.taskCategory?.id ?? 0,
        createdOn: model.createdOn,
        urgencyLevel: model.urgencyLevel ?? TaskPriority.none,
        time: model.time,
        nextOccurrence: model.nextOccurrence,
        recurrenceRuleset: model.recurrenceRuleset?.toShortString()
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isDone': isDone ? 1 : 0,
        'date': date?.toIso8601String(),
        'completedDate': completedDate?.toIso8601String(),
        'createdOn': createdOn.toIso8601String(),
        'urgencyLevel': urgencyLevel?.toString().split('.').last,
        'reminder': reminder ? 1 : 0,
        'reminderDate': reminderDate?.toIso8601String(),
        'reminderTime': reminderTime != null
            ? "${reminderTime!.hour}:${reminderTime!.minute}"
            : null,
        'notifyBeforeMinutes': notifyBeforeMinutes,
        'time': time != null ? "${time!.hour}:${time!.minute}" : null,
        'nextOccurrence': nextOccurrence?.toIso8601String(),
      };

  Task copyWith(
          {int? id,
          String? title,
          String? description,
          bool? isDone,
          DateTime? date,
          DateTime? completedDate,
          DateTime? createdOn,
          TaskCategory? taskCategory,
          TaskPriority? urgencyLevel,
          TimeOfDay? time,
          DateTime? nextOccurrence,
          DateTime? lastOccurrenceDate,
          RecurrenceRuleset? recurrenceRuleset,
          bool copyNullValues = false,
          }) =>
      Task(
          id: id ?? this.id,
          title: title ?? this.title,
          description: description ?? this.description,
          isDone: isDone ?? this.isDone,
          date: date ?? this.date,
          completedDate: completedDate ?? this.completedDate,
          createdOn: createdOn ?? this.createdOn,
          taskCategory: copyNullValues || taskCategory != null
              ? taskCategory
              : this.taskCategory,
          urgencyLevel: urgencyLevel ?? this.urgencyLevel,
          time: time ?? this.time,
          nextOccurrence: nextOccurrence ?? this.nextOccurrence,
          recurrenceRuleset: copyNullValues || recurrenceRuleset != null ? recurrenceRuleset : this.recurrenceRuleset,); 
}
