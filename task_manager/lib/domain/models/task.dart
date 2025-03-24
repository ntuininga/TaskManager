import 'package:flutter/material.dart';
import 'package:task_manager/data/entities/recurrence_ruleset_entity.dart';
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
  TimeOfDay? time;
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
      this.time,
      this.nextOccurrence,
      })
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
        'time': time != null ? "${time!.hour}:${time!.minute}" : null,
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
          ); 
}
