import 'package:flutter/material.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/recurrence_ruleset.dart';
import 'package:task_manager/domain/models/task_category.dart';

class Task {
  final int? id;
  String? title;
  String? description;
  bool isDone;
  DateTime? date;
  TaskCategory? taskCategory;
  TaskPriority? urgencyLevel;
  TimeOfDay? time;
  bool isRecurring;
  RecurrenceRuleset? recurrenceRuleset;
  int? recurrenceRuleId;
  DateTime? updatedOn;
  DateTime createdOn;
  DateTime? completedDate;

  Task({
    this.id,
    this.title,
    this.description,
    this.isDone = false,
    this.date,
    this.taskCategory,
    this.urgencyLevel = TaskPriority.none,
    this.time,
    this.isRecurring = false,
    this.recurrenceRuleId,
    this.recurrenceRuleset,
    this.completedDate,
    DateTime? createdOn,
    DateTime? updatedOn,
  })  : createdOn = createdOn ?? DateTime.now(),
        updatedOn = updatedOn ?? DateTime.now();

  static Task fromTaskEntity(TaskEntity entity) => Task(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        isDone: entity.isDone == 1,
        date: entity.date,
        urgencyLevel: entity.urgencyLevel,
        time: entity.time,
        isRecurring: entity.isRecurring == 1,
        completedDate: entity.completedDate,
        createdOn: entity.createdOn,
        updatedOn: entity.updatedOn,
      );

  static Future<TaskEntity> toTaskEntity(Task model) async => TaskEntity(
        id: model.id,
        title: model.title,
        description: model.description,
        isDone: model.isDone ? 1 : 0,
        date: model.date,
        taskCategoryId: model.taskCategory?.id ?? 0,
        urgencyLevel: model.urgencyLevel ?? TaskPriority.none,
        time: model.time,
        isRecurring: model.isRecurring ? 1 : 0,
        recurrenceId: model.recurrenceRuleset?.recurrenceId,
        updatedOn: model.updatedOn,
        createdOn: model.createdOn,
        completedDate: model.completedDate,
      );

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isDone,
    DateTime? date,
    DateTime? completedDate,
    DateTime? createdOn,
    DateTime? updatedOn,
    TaskCategory? taskCategory,
    TaskPriority? urgencyLevel,
    TimeOfDay? time,
    bool? isRecurring,
    RecurrenceRuleset? recurrenceRuleset,
    int? recurrenceRuleId,
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
        recurrenceRuleset: recurrenceRuleset ?? this.recurrenceRuleset,
        isRecurring: isRecurring ?? this.isRecurring,
        recurrenceRuleId: recurrenceRuleId ?? this.recurrenceRuleId,
      );

  // == operator override
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.isDone == isDone &&
        other.date == date &&
        other.taskCategory == taskCategory &&
        other.urgencyLevel == urgencyLevel &&
        other.time == time &&
        other.isRecurring == isRecurring &&
        other.recurrenceRuleId == recurrenceRuleId &&
        other.recurrenceRuleset == recurrenceRuleset &&
        other.updatedOn == updatedOn &&
        other.createdOn == createdOn &&
        other.completedDate == completedDate;
  }

  // hashCode override
  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        isDone,
        date,
        taskCategory,
        urgencyLevel,
        time,
        isRecurring,
        recurrenceRuleId,
        recurrenceRuleset,
        updatedOn,
        createdOn,
        completedDate,
      );
}
