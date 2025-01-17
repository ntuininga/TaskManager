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
      taskCategoryId: (json['taskCategoryId'] as num?)?.toInt() ?? 0,
      urgencyLevel:
          $enumDecodeNullable(_$TaskPriorityEnumMap, json['urgencyLevel']) ??
              TaskPriority.none,
      reminder: (json['reminder'] as num?)?.toInt() ?? 0,
      reminderDate: json['reminderDate'] == null
          ? null
          : DateTime.parse(json['reminderDate'] as String),
      reminderTime:
          const TimeOfDayConverter().fromJson(json['reminderTime'] as String?),
      notifyBeforeMinutes: (json['notifyBeforeMinutes'] as num?)?.toInt(),
      time: const TimeOfDayConverter().fromJson(json['time'] as String?),
      recurrenceType:
          $enumDecodeNullable(_$RecurrenceTypeEnumMap, json['recurrenceType']),
      recurrenceInterval: (json['recurrenceInterval'] as num?)?.toInt(),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      nextOccurrence: json['nextOccurrence'] == null
          ? null
          : DateTime.parse(json['nextOccurrence'] as String),
    );

Map<String, dynamic> _$TaskEntityToJson(TaskEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'isDone': instance.isDone,
      'date': instance.date?.toIso8601String(),
      'completedDate': instance.completedDate?.toIso8601String(),
      'createdOn': instance.createdOn.toIso8601String(),
      'taskCategoryId': instance.taskCategoryId,
      'urgencyLevel': _$TaskPriorityEnumMap[instance.urgencyLevel]!,
      'reminder': instance.reminder,
      'reminderDate': instance.reminderDate?.toIso8601String(),
      'reminderTime': const TimeOfDayConverter().toJson(instance.reminderTime),
      'notifyBeforeMinutes': instance.notifyBeforeMinutes,
      'time': const TimeOfDayConverter().toJson(instance.time),
      'recurrenceType': _$RecurrenceTypeEnumMap[instance.recurrenceType],
      'recurrenceInterval': instance.recurrenceInterval,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'nextOccurrence': instance.nextOccurrence?.toIso8601String(),
    };

const _$TaskPriorityEnumMap = {
  TaskPriority.none: 'none',
  TaskPriority.high: 'high',
};

const _$RecurrenceTypeEnumMap = {
  RecurrenceType.daily: 'daily',
  RecurrenceType.weekly: 'weekly',
  RecurrenceType.monthly: 'monthly',
  RecurrenceType.yearly: 'yearly',
};
