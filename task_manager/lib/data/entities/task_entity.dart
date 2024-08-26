import 'package:json_annotation/json_annotation.dart';

part 'task_entity.g.dart';

const String taskTableName = "tasks";

const String idField = "id";
const String titleField = "title";
const String descriptionField = "description";
const String isDoneField = "isDone";
const String dateField = "date";
const String completedDateField = "completedDate";
const String createdOnField = "createdOn";
const String taskCategoryField = "taskCategoryId";
const String urgencyLevelField = "urgencyLevel";

enum TaskPriority { none, high }

@JsonSerializable()
class TaskEntity {
  final int? id;
  final String? title;
  final String? description;
  final int isDone;
  final DateTime? date;
  final DateTime? completedDate;
  final DateTime createdOn;
  final int? taskCategoryId;
  final TaskPriority urgencyLevel;

  TaskEntity({
    this.id,
    this.title,
    this.description,
    this.isDone = 0,
    this.date,
    this.completedDate,
    DateTime? createdOn,
    this.taskCategoryId = 0,
    this.urgencyLevel = TaskPriority.none,
  }) : createdOn = createdOn ?? DateTime.now();

  factory TaskEntity.fromJson(Map<String, dynamic> json) => _$TaskEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TaskEntityToJson(this);

  TaskEntity copyWith({
    int? id,
    String? title,
    String? description,
    int? isDone,
    DateTime? date,
    DateTime? completedDate,
    DateTime? createdOn,
    int? taskCategoryId,
    TaskPriority? urgencyLevel,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      date: date ?? this.date,
      completedDate: completedDate ?? this.completedDate,
      createdOn: createdOn ?? this.createdOn,
      taskCategoryId: taskCategoryId ?? this.taskCategoryId,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
    );
  }
}
