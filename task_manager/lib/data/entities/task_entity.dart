import 'package:json_annotation/json_annotation.dart';

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

@JsonSerializable()
class TaskModel{
  final int? id;
  final String title;
  final String? description;
  final bool isDone;
  final int? taskCategoryId; 

  const TaskModel({
    this.id,
    required this.title,
    this.description,
    this.isDone = false,
    this.taskCategoryId
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
    _$TaskModelFromJson(json);

  Map<String,dynamic> toJson() =>
    _$TaskModeltoJson(this);
}


TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
    id: json[idField] as int,
    title: json[titleField] as String,
    description: json[descriptionField] as String?,
    isDone: json[isDoneField] == 1,
    taskCategoryId: json[taskCategoryField] != null
      ? int.tryParse(json[taskCategoryField] as String)
      : null,
  );

Map<String,dynamic> _$TaskModeltoJson(TaskModel model) => {
    idField: model.id,
    titleField: model.title,
    descriptionField: model.description,
    isDoneField: model.isDone,
    taskCategoryField: model.taskCategoryId.toString()
};

