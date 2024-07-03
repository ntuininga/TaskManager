import 'package:flutter/material.dart';
import 'package:task_manager/data/entities/task_category_entity.dart';

class TaskCategory {
  final int? id;
  final String? title;
  final Color? colour;

  TaskCategory({
    this.id,
    this.title,
    this.colour,
  });

  factory TaskCategory.fromTaskCategoryEntity(TaskCategoryEntity entity) {
    return TaskCategory(
      id: entity.id,
      title: entity.title,
      colour: entity.colour != null ? Color(entity.colour!) : null,
    );
  }

  TaskCategoryEntity toTaskCategoryEntity() {
    return TaskCategoryEntity(
      id: id,
      title: title,
      colour: colour?.value,
    );
  }

  TaskCategory copyWith({
    int? id,
    String? title,
    Color? colour,
  }) {
    return TaskCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      colour: colour ?? this.colour,
    );
  }
}
