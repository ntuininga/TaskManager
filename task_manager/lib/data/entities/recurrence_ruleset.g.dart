// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurrence_ruleset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurrenceRulesetEntity _$RecurrenceRulesetEntityFromJson(
        Map<String, dynamic> json) =>
    RecurrenceRulesetEntity(
      recurrenceId: (json['recurrenceId'] as num?)?.toInt(),
      frequency: json['frequency'] as String?,
      count: (json['count'] as num?)?.toInt(),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$RecurrenceRulesetEntityToJson(
        RecurrenceRulesetEntity instance) =>
    <String, dynamic>{
      'recurrenceId': instance.recurrenceId,
      'frequency': instance.frequency,
      'count': instance.count,
      'endDate': instance.endDate?.toIso8601String(),
    };
