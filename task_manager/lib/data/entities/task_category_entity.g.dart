// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_category_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskCategoryEntity _$TaskCategoryEntityFromJson(Map<String, dynamic> json) =>
    TaskCategoryEntity(
      id: json[categoryIdField] as int?,
      title: json[categoryIdField] as String?,
      colour: json[categoryColourField] as int?,
    );

Map<String, dynamic> _$TaskCategoryEntityToJson(TaskCategoryEntity instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'colour': instance.colour,
    };