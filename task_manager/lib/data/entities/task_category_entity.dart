import 'package:json_annotation/json_annotation.dart';

part 'task_category_entity.g.dart';

const String taskCategoryTableName = "taskcategories";

const String categoryIdField = "id";
const String categoryTitleField = "title";
const String categoryColourField = "colour";

@JsonSerializable()
class TaskCategoryEntity {
  final int? id;
  final String? title;
  final int? colour;

  const TaskCategoryEntity({this.id, this.title, this.colour});

  factory TaskCategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$TaskCategoryEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TaskCategoryEntityToJson(this);

  TaskCategoryEntity copyWith({int? id, String? title, int? colour}) =>
      TaskCategoryEntity(
          id: id ?? this.id,
          title: title ?? this.title,
          colour: colour ?? this.colour);
}
