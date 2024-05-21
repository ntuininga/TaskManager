import 'package:task_manager/data/entities/task_entity.dart';

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
  String title;
  String? description;
  bool isDone;
  DateTime? date;
  int? taskCategoryId;

  Task({
    this.id,
    required this.title,
    this.description,
    this.isDone = false,
    this.date,
    this.taskCategoryId
  });

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
    dateField: date?.toString(),
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