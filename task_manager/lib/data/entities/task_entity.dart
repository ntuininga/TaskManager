import 'package:json_annotation/json_annotation.dart';

const String taskTableName = "tasks";

const String idField = "_id";
const String titleField = "title";
const String descriptionField = "description";
const String isDoneField = "is_done";
const String dateField = "date";
const String completedDateField = "completed_date";
const String createdOnField = "created_on";
const String taskCategoryField = "FK_task_category";
const String urgencyLevelField = "urgency_level";

const List<String> taskColumns = [
  idField,
  titleField,
  descriptionField,
  isDoneField,
  dateField,
  completedDateField,
  createdOnField,
  taskCategoryField,
  urgencyLevelField
];

@JsonSerializable()
class TaskEntity {
  final int? id;
  final String title;
  final String? description;
  final bool isDone;
  final DateTime? date;
  final DateTime? completedDate;
  final DateTime? createdOn;
  final int? taskCategoryId;
  final int? urgencyLevel;

  TaskEntity({
    this.id,
    required this.title,
    this.description,
    this.isDone = false,
    this.date,
    this.completedDate,
    DateTime? createdOn,
    this.taskCategoryId,
    this.urgencyLevel
  }) : createdOn = createdOn ?? DateTime.now();

  factory TaskEntity.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModeltoJson(this);
}

TaskEntity _$TaskModelFromJson(Map<String, dynamic> json) => TaskEntity(
  id: json[idField] as int?,
  title: json[titleField] as String,
  description: json[descriptionField] as String?,
  isDone: json[isDoneField] == 1,
  date: json[dateField] == null ? null : DateTime.parse(json[dateField]),
  completedDate: json[completedDateField] == null ? null : DateTime.parse(json[completedDateField]),
  createdOn: DateTime.parse(json[createdOnField] as String),
  taskCategoryId: json[taskCategoryField] != null ? int.tryParse(json[taskCategoryField] as String) : null,
  urgencyLevel: json[urgencyLevelField] != null ? int.tryParse(json[urgencyLevelField] as String) : null,
);

Map<String, dynamic> _$TaskModeltoJson(TaskEntity model) => {
  idField: model.id,
  titleField: model.title,
  descriptionField: model.description,
  isDoneField: model.isDone ? 1 : 0, // Convert boolean to integer
  dateField: model.date?.toIso8601String(),
  completedDateField: model.completedDate?.toIso8601String(),
  createdOnField: model.createdOn?.toIso8601String(),
  taskCategoryField: model.taskCategoryId?.toString(),
  urgencyLevelField: model.urgencyLevel?.toString()
};
