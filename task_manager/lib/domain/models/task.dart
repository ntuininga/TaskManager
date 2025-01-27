import 'package:flutter/material.dart';
import 'package:rrule/rrule.dart';
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
  RecurrenceRule? recurrenceRule;

  // New recurrence-related fields
  final int? recurrenceInterval; // How often the task repeats
  final DateTime? startDate; // When the recurrence starts
  final DateTime? endDate; // When the recurrence ends (nullable)
  final DateTime? nextOccurrence; // Date of the next occurrence

  final List<bool>? selectedDays;
  final RecurrenceOption? recurrenceOption;
  final int? occurenceCount;

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
      this.recurrenceType,
      this.recurrenceInterval,
      this.startDate,
      this.endDate,
      this.nextOccurrence,
      this.selectedDays,
      this.recurrenceOption,
      this.occurenceCount,
      this.recurrenceRule})
      : createdOn = createdOn ?? DateTime.now();

  static Task fromTaskEntity(TaskEntity entity) => Task(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        isDone: entity.isDone == 1, // Assuming 1 is 'done', 0 is 'not done'
        date: entity.date,
        completedDate: entity.completedDate,
        createdOn: entity.createdOn,
        urgencyLevel: entity.urgencyLevel,
        reminder: entity.reminder == 1, // Assuming 1 is 'true', 0 is 'false'
        reminderDate: entity.reminderDate,
        reminderTime: entity.reminderTime,
        notifyBeforeMinutes: entity.notifyBeforeMinutes,
        time: entity.time,
        recurrenceType: entity.recurrenceType,
        recurrenceInterval: entity.recurrenceInterval,
        startDate: entity.startDate,
        endDate: entity.endDate,
        nextOccurrence: entity.nextOccurrence,
        selectedDays: entity.selectedDays,
        recurrenceOption: entity.recurrenceOption,
        occurenceCount: entity.occurrenceCount,
        recurrenceRule: entity.recurrenceRule
      );

  static TaskEntity toTaskEntity(Task model) => TaskEntity(
      id: model.id,
      title: model.title,
      description: model.description,
      isDone: model.isDone ? 1 : 0, // Storing as 1 (done) or 0 (not done)
      date: model.date,
      completedDate: model.completedDate,
      taskCategoryId: model.taskCategory?.id ??
          0, // Assuming 0 is a default value for no category
      createdOn: model.createdOn,
      urgencyLevel: model.urgencyLevel ?? TaskPriority.none,
      reminder: model.reminder ? 1 : 0, // Storing as 1 (true) or 0 (false)
      reminderDate: model.reminderDate,
      reminderTime: model.reminderTime,
      notifyBeforeMinutes: model.notifyBeforeMinutes,
      time: model.time,
      recurrenceType: model.recurrenceType,
      recurrenceInterval: model.recurrenceInterval,
      startDate: model.startDate,
      endDate: model.endDate,
      nextOccurrence: model.nextOccurrence,
      selectedDays: model.selectedDays,
      recurrenceOption: model.recurrenceOption,
      occurrenceCount: model.occurenceCount,
      recurrenceRule: model.recurrenceRule);

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
        'recurrenceType': recurrenceType?.toString().split('.').last,
        'recurrenceInterval': recurrenceInterval,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
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
          List<bool>? selectedDays,
          RecurrenceOption? recurrenceOption,
          int? occurenceCount,
          RecurrenceRule? recurrenceRule,
          bool copyNullValues = false}) =>
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
          reminder: reminder ?? this.reminder,
          reminderDate: reminderDate ?? this.reminderDate,
          reminderTime: reminderTime ?? this.reminderTime,
          notifyBeforeMinutes: notifyBeforeMinutes ?? this.notifyBeforeMinutes,
          time: time ?? this.time,
          recurrenceType: copyNullValues || recurrenceType != null
              ? recurrenceType
              : this.recurrenceType,
          recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
          startDate: startDate ?? this.startDate,
          endDate: endDate ?? this.endDate,
          nextOccurrence: nextOccurrence ?? this.nextOccurrence,
          selectedDays: selectedDays ?? this.selectedDays,
          recurrenceOption: recurrenceOption ?? this.recurrenceOption,
          occurenceCount: occurenceCount ?? this.occurenceCount,
          recurrenceRule: recurrenceRule ?? this.recurrenceRule);
}
