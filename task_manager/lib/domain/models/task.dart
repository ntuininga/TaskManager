import 'package:task_manager/data/entities/task_entity.dart';

const String taskTableName = "tasks";

const String idField = "_id";
const String titleField = "title";
const String descriptionField = "description";
const String isDoneField = "is_done";
const String dateField = "date";
const String taskCategoryField = "FK_task_category";

const List<String> taskColumns = [
  idField,
  titleField,
  descriptionField,
  isDoneField,
  dateField,
  taskCategoryField
];

class Task {
  final int? id;
  final String title;
  final String? description;
  bool isDone;
  final DateTime? date;
  final int? taskCategoryId;

  Task({
    this.id,
    required this.title,
    this.description,
    this.isDone = false,
    this.date,
    this.taskCategoryId
  });

  static Task fromJson(Map<String, dynamic> json) => Task(
    id: json[idField] as int,
    title: json[titleField] as String,
    description: json[descriptionField] as String?,
    isDone: json[isDoneField] == 1,
    date: DateTime.parse(json[dateField] as String),
    taskCategoryId: json[taskCategoryField] != null
      ? int.tryParse(json[taskCategoryField] as String)
      : null,
  );

  static Task fromTaskEntity(TaskEntity entity) => Task(
    id: entity.id,
    title: entity.title,
    description: entity.description,
    isDone: entity.isDone,
    date: entity.date,
    taskCategoryId: entity.taskCategoryId
  );

  static TaskEntity toTaskEntity(Task model) => TaskEntity(
    id: model.id,
    title: model.title,
    description: model.description,
    isDone: model.isDone,
    date: model.date,
    taskCategoryId: model.taskCategoryId
  );

  Map<String, dynamic> toJson() => {
    idField: id,
    titleField: title,
    descriptionField: description,
    isDoneField: isDone,
    dateField: date?.toIso8601String(),
    taskCategoryField: taskCategoryId.toString()
  };

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isDone,
    DateTime? date,
    int? taskCategoryId,
  }) => Task (
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    isDone: isDone ?? this.isDone,
    date: date ?? this.date,
    taskCategoryId: taskCategoryId ?? this.taskCategoryId
  );
}