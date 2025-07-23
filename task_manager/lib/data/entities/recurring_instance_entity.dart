import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recurring_instance_entity.g.dart';

@JsonSerializable()
class RecurringInstanceEntity {
  final int? instanceId;
  final int? taskId;
  final DateTime? occurrenceDate;
  @TimeOfDayConverter()
  final TimeOfDay? occurrenceTime;
  final int? isDone;
  final DateTime? completedAt;

  RecurringInstanceEntity({
    this.instanceId,
    this.taskId,
    this.occurrenceDate,
    this.occurrenceTime,
    this.isDone,
    this.completedAt,
  });

  factory RecurringInstanceEntity.fromJson(Map<String, dynamic> json) =>
      _$RecurringInstanceEntityFromJson(json);

  Map<String, dynamic> toJson() => _$RecurringInstanceEntityToJson(this);
}



class TimeOfDayConverter implements JsonConverter<TimeOfDay?, String?> {
  const TimeOfDayConverter();

  @override
  TimeOfDay? fromJson(String? json) {
    if (json == null) return null;
    final parts = json.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  String? toJson(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour}:${time.minute}';
  }
}
