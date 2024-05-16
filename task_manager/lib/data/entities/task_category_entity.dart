import 'package:json_annotation/json_annotation.dart';

const String taskCategoryTableName = "taskcategories";

const String categoryIdField = "_id";
const String categoryTitleField = "title";
const String categoryColourField = "colour";

const List<String> taskColumns = [
  categoryIdField,
  categoryTitleField,
  categoryColourField
];

@JsonSerializable()
class TaskCategoryEntity{
  final int? id;
  final String title; 
  final int? colour;

  const TaskCategoryEntity({
    this.id,
    required this.title,
    this.colour
  });

  factory TaskCategoryEntity.fromJson(Map<String, dynamic> json) =>
    _$TaskModelFromJson(json);

  Map<String,dynamic> toJson() =>
    _$TaskModeltoJson(this);

  TaskCategoryEntity copyWith({
    int? id,
    String? title,
    int? colour
  }) => TaskCategoryEntity (
    id: id ?? this.id,
    title: title ?? this.title,
    colour: colour ?? this.colour
  );
}


TaskCategoryEntity _$TaskModelFromJson(Map<String, dynamic> json) => TaskCategoryEntity(
    id: json[categoryIdField] as int,
    title: json[categoryTitleField] as String,
    colour: json[categoryColourField]
  );

Map<String,dynamic> _$TaskModeltoJson(TaskCategoryEntity model) => {
    categoryIdField: model.id,
    categoryTitleField: model.title,
    categoryColourField: model.colour
};

