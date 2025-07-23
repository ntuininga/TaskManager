import 'package:json_annotation/json_annotation.dart';

part 'recurrence_ruleset_entity.g.dart';

@JsonSerializable()
class RecurrenceRulesetEntity {
  final int? recurrenceId;
  final String? frequency;
  final int? count;
  final DateTime? endDate;
  final int? isImmutable;

  RecurrenceRulesetEntity(
      {this.recurrenceId, this.frequency, this.count, this.endDate, this.isImmutable});

  factory RecurrenceRulesetEntity.fromJson(Map<String, dynamic> json) =>
      _$RecurrenceRulesetEntityFromJson(json);

  Map<String, dynamic> toJson() => _$RecurrenceRulesetEntityToJson(this);
}
