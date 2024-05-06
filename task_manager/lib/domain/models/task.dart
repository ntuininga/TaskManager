import 'package:task_manager/data/entities/task_entity.dart';

const String taskTableName = "tasks";

const String idField = "_id";
const String titleField = "title";
const String descriptionField = "description";
const String isDoneField = "is_done";
const String taskCategoryField = "FK_task_category";

const List<String> taskColumns = [
  idField,
  titleField,
  descriptionField,
  isDoneField,
  taskCategoryField
];

class Task {
  final int? id;
  final String title;
  final String? description;
  bool isDone;
  final int? taskCategoryId;

  Task({
    this.id,
    required this.title,
    this.description,
    this.isDone = false,
    this.taskCategoryId
  });

  static Task fromJson(Map<String, dynamic> json) => Task(
    id: json[idField] as int,
    title: json[titleField] as String,
    description: json[descriptionField] as String?,
    isDone: json[isDoneField] == 1,
    taskCategoryId: json[taskCategoryField] != null
      ? int.tryParse(json[taskCategoryField] as String)
      : null,
  );

  static Task fromTaskEntity(TaskEntity entity) => Task(
    id: entity.id,
    title: entity.title,
    description: entity.description,
    isDone: entity.isDone,
    taskCategoryId: entity.taskCategoryId
  );

  Map<String, dynamic> toJson() => {
    idField: id,
    titleField: title,
    descriptionField: description,
    isDoneField: isDone,
    taskCategoryField: taskCategoryId.toString()
  };

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isDone,
    int? taskCategoryId,
  }) => Task (
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    isDone: isDone ?? this.isDone,
    taskCategoryId: taskCategoryId ?? this.taskCategoryId
  );
}