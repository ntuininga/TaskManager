// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_task_details_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurringTaskDetailsEntity _$RecurringTaskDetailsEntityFromJson(
        Map<String, dynamic> json) =>
    RecurringTaskDetailsEntity(
      taskId: (json['taskId'] as num?)?.toInt(),
      scheduledDates: RecurringTaskDetailsEntity._decodeDates(
          json['scheduledDates'] as String?),
      completedOnDates: RecurringTaskDetailsEntity._decodeDates(
          json['completedOnDates'] as String?),
      missedDates: RecurringTaskDetailsEntity._decodeDates(
          json['missedDates'] as String?),
    );

Map<String, dynamic> _$RecurringTaskDetailsEntityToJson(
        RecurringTaskDetailsEntity instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'scheduledDates':
          RecurringTaskDetailsEntity._encodeDates(instance.scheduledDates),
      'completedOnDates':
          RecurringTaskDetailsEntity._encodeDates(instance.completedOnDates),
      'missedDates':
          RecurringTaskDetailsEntity._encodeDates(instance.missedDates),
    };
