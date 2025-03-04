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
          json[scheduledTasksField] as String?),
      completedOnDates: RecurringTaskDetailsEntity._decodeDates(
          json[completedOnTasksField] as String?),
      missedDates: RecurringTaskDetailsEntity._decodeDates(
          json[missedDatesFields] as String?),
    );

Map<String, dynamic> _$RecurringTaskDetailsEntityToJson(
        RecurringTaskDetailsEntity instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'scheduledTasks':
          RecurringTaskDetailsEntity._encodeDates(instance.scheduledDates),
      'completedOnTasks':
          RecurringTaskDetailsEntity._encodeDates(instance.completedOnDates),
      'missedDatesField':
          RecurringTaskDetailsEntity._encodeDates(instance.missedDates),
    };
