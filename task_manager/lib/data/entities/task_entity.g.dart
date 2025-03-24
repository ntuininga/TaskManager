// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskEntity _$TaskEntityFromJson(Map<String, dynamic> json) => TaskEntity(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      isDone: (json['isDone'] as num?)?.toInt() ?? 0,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      completedDate: json['completedDate'] == null
          ? null
          : DateTime.parse(json['completedDate'] as String),
      createdOn: json['createdOn'] == null
          ? null
          : DateTime.parse(json['createdOn'] as String),
      updatedOn: json['updatedOn'] == null
          ? null
          : DateTime.parse(json['updatedOn'] as String),
      taskCategoryId: (json['taskCategoryId'] as num?)?.toInt() ?? 0,
      urgencyLevel:
          $enumDecodeNullable(_$TaskPriorityEnumMap, json['urgencyLevel']) ??
              TaskPriority.none,
      time: const TimeOfDayConverter().fromJson(json['time'] as String?),
      isRecurring: (json['isRecurring'] as num?)?.toInt() ?? 0,
      recurrenceId: (json['recurrenceId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TaskEntityToJson(TaskEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'isDone': instance.isDone,
      'date': instance.date?.toIso8601String(),
      'taskCategoryId': instance.taskCategoryId,
      'urgencyLevel': _$TaskPriorityEnumMap[instance.urgencyLevel]!,
      'time': const TimeOfDayConverter().toJson(instance.time),
      'isRecurring': instance.isRecurring,
      'recurrenceId': instance.recurrenceId,
      'createdOn': instance.createdOn.toIso8601String(),
      'updatedOn': instance.updatedOn.toIso8601String(),
      'completedDate': instance.completedDate?.toIso8601String(),
    };

const _$TaskPriorityEnumMap = {
  TaskPriority.none: 'none',
  TaskPriority.high: 'high',
};
