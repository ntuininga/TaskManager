import 'package:json_annotation/json_annotation.dart';

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

@JsonSerializable()
class TaskEntity{
  final int? id;
  final String title;
  final String? description;
  final bool isDone;
  final int? taskCategoryId; 
  final DateTime? date;

  const TaskEntity({
    this.id,
    required this.title,
    this.description,
    this.isDone = false,
    this.date,
    this.taskCategoryId
  });

  factory TaskEntity.fromJson(Map<String, dynamic> json) =>
    _$TaskModelFromJson(json);

  Map<String,dynamic> toJson() =>
    _$TaskModeltoJson(this);
}


TaskEntity _$TaskModelFromJson(Map<String, dynamic> json) => TaskEntity(
    id: json[idField] as int,
    title: json[titleField] as String,
    description: json[descriptionField] as String?,
    isDone: json[isDoneField] == 1,
    date: DateTime.parse(json[dateField] as String),
    taskCategoryId: json[taskCategoryField] != null
      ? int.tryParse(json[taskCategoryField] as String)
      : null,
  );

Map<String,dynamic> _$TaskModeltoJson(TaskEntity model) => {
    idField: model.id,
    titleField: model.title,
    descriptionField: model.description,
    isDoneField: model.isDone,
    dateField: model.date?.toIso8601String(),
    taskCategoryField: model.taskCategoryId.toString()
};

