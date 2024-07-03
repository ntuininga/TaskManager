import 'package:flutter/material.dart';
import 'package:task_manager/data/entities/task_category_entity.dart';

class TaskCategory {
  final int? id;
  final String? title;
  final Color? colour;

  TaskCategory({
    this.id,
    this.title,
    this.colour
  });

  static TaskCategory fromTaskCategoryEntity(TaskCategoryEntity entity) => TaskCategory(
    id: entity.id,
    title: entity.title,
    colour: entity.colour == null ? null : Color(entity.colour!)
  );

  static TaskCategoryEntity toTaskCategoryEntity(TaskCategory category) => TaskCategoryEntity(
    id: category.id,
    title: category.title,
    colour: category.colour?.value
  );

  TaskCategory copyWith({
    int? id,
    String? title,
    Color? colour
  }) => TaskCategory (
    id: id ?? this.id,
    title: title ?? this.title,
    colour: colour ?? this.colour
  );
}
