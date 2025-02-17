// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_task_details_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurringTaskDetails _$RecurringTaskDetailsFromJson(
        Map<String, dynamic> json) =>
    RecurringTaskDetails(
      taskId: (json['taskId'] as num?)?.toInt(),
      scheculedDates: (json['scheculedDates'] as List<dynamic>?)
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
        RecurringTaskDetails instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'scheculedDates':
          instance.scheculedDates?.map((e) => e.toIso8601String()).toList(),
      'completedOnDates':
          instance.completedOnDates?.map((e) => e.toIso8601String()).toList(),
      'missedDates':
          instance.missedDates?.map((e) => e.toIso8601String()).toList(),
    };
