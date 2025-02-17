// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_task_details_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurringTaskDetailsEntity _$RecurringTaskDetailsFromJson(
        Map<String, dynamic> json) =>
    RecurringTaskDetailsEntity(
      taskId: (json['taskId'] as num?)?.toInt(),
      scheduledDates: (json['scheculedDates'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList(),
      completedOnDates: (json['completedOnDates'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList(),
      missedDates: (json['missedDates'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList(),
    );

Map<String, dynamic> _$RecurringTaskDetailsToJson(
        RecurringTaskDetailsEntity instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'scheculedDates':
          instance.scheduledDates?.map((e) => e.toIso8601String()).toList(),
      'completedOnDates':
          instance.completedOnDates?.map((e) => e.toIso8601String()).toList(),
      'missedDates':
          instance.missedDates?.map((e) => e.toIso8601String()).toList(),
    };
