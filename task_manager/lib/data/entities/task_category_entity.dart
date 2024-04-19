import 'package:json_annotation/json_annotation.dart';

const String taskTableName = "tasks";

const String categoryIdField = "_id";
const String categoryTitleField = "title";

const List<String> taskColumns = [
  categoryIdField,
  categoryTitleField
];

@JsonSerializable()
class TaskCategoryEntity{
  final int? id;
  final String title; 

  const TaskCategoryEntity({
    this.id,
    required this.title
  });

  factory TaskCategoryEntity.fromJson(Map<String, dynamic> json) =>
    _$TaskModelFromJson(json);

  Map<String,dynamic> toJson() =>
    _$TaskModeltoJson(this);
}


TaskCategoryEntity _$TaskModelFromJson(Map<String, dynamic> json) => TaskCategoryEntity(
    id: json[categoryIdField] as int,
    title: json[categoryTitleField] as String
  );

Map<String,dynamic> _$TaskModeltoJson(TaskCategoryEntity model) => {
    categoryIdField: model.id,
    categoryTitleField: model.title
};

