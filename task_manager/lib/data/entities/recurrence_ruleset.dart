import 'package:json_annotation/json_annotation.dart';

part 'recurrence_ruleset.g.dart';


@JsonSerializable()
class RecurrenceRulesetEntity {
  final int? recurrenceId;
  final String? frequency;
  final int? count;
  final DateTime? endDate;

  RecurrenceRulesetEntity(
      {this.recurrenceId, this.frequency, this.count, this.endDate});

  factory RecurrenceRulesetEntity.fromJson(Map<String, dynamic> json) =>
      _$RecurrenceRulesetEntityFromJson(json);

  Map<String, dynamic> toJson() => _$RecurrenceRulesetEntityToJson(this);
}
