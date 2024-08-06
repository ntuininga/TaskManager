// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_category_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskCategoryEntity _$TaskCategoryEntityFromJson(Map<String, dynamic> json) =>
    TaskCategoryEntity(
      id: json['id'] as int?,
      title: json['title'] as String?,
      colour: json['colour'] as int?,
    );

Map<String, dynamic> _$TaskCategoryEntityToJson(TaskCategoryEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'colour': instance.colour,
    };
