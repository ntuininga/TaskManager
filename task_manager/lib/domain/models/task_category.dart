import 'package:task_manager/data/entities/task_category_entity.dart';

const String taskCategoryTableName = "taskcategories";

const String categoryIdField = "_id";
const String categoryTitleField = "title";

const List<String> taskCategoryColumns = [
  categoryIdField,
  categoryTitleField
];

class TaskCategory {
  final int? id;
  final String title;

  TaskCategory({
    this.id,
    required this.title
  });

  static TaskCategory fromTaskCategoryEntity(TaskCategoryEntity entity) => TaskCategory(
    id: entity.id,
    title: entity.title,
  );

  static TaskCategoryEntity toTaskCategoryEntity(TaskCategory category) => TaskCategoryEntity(
    id: category.id,
    title: category.title
  );

  TaskCategory copyWith({
    int? id,
    String? title
  }) => TaskCategory (
    id: id ?? this.id,
    title: title ?? this.title
  );
}
