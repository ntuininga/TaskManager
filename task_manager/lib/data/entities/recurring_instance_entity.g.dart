// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_instance_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurringInstanceEntity _$RecurringInstanceEntityFromJson(
        Map<String, dynamic> json) =>
    RecurringInstanceEntity(
      instanceId: (json['instanceId'] as num?)?.toInt(),
      taskId: (json['taskId'] as num?)?.toInt(),
      occurrenceDate: json['occurrenceDate'] == null
          ? null
          : DateTime.parse(json['occurrenceDate'] as String),
      occurrenceTime: const TimeOfDayConverter()
          .fromJson(json['occurrenceTime'] as String?),
      isDone: (json['isDone'] as num?)?.toInt(),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$RecurringInstanceEntityToJson(
        RecurringInstanceEntity instance) =>
    <String, dynamic>{
      'instanceId': instance.instanceId,
      'taskId': instance.taskId,
      'occurrenceDate': instance.occurrenceDate?.toIso8601String(),
      'occurrenceTime':
          const TimeOfDayConverter().toJson(instance.occurrenceTime),
      'isDone': instance.isDone,
      'completedAt': instance.completedAt?.toIso8601String(),
    };
