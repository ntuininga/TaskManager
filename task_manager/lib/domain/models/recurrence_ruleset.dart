import 'package:task_manager/core/frequency.dart';
import 'package:task_manager/data/entities/recurrence_ruleset_entity.dart';

class RecurrenceRuleset {
  final int? recurrenceId;
  final Frequency? frequency;
  final int? count;
  final DateTime? endDate;

  RecurrenceRuleset({
    this.recurrenceId,
    this.frequency,
    this.count,
    this.endDate,
  });

  /// Create a model from an entity
  static RecurrenceRuleset fromEntity(RecurrenceRulesetEntity entity) {
    return RecurrenceRuleset(
      recurrenceId: entity.recurrenceId,
      frequency: FrequencyExtension.fromString(entity.frequency!),
      count: entity.count,
      endDate: entity.endDate,
    );
  }

  /// Convert the model to an entity
  Future<RecurrenceRulesetEntity> toEntity() async {
    return RecurrenceRulesetEntity(
      recurrenceId: recurrenceId,
      frequency: frequency?.toShortString(),
      count: count,
      endDate: endDate,
    );
  }

  /// Create a copy of the object with updated values
  RecurrenceRuleset copyWith({
    int? recurrenceId,
    Frequency? frequency,
    int? count,
    DateTime? endDate,
  }) {
    return RecurrenceRuleset(
      recurrenceId: recurrenceId ?? this.recurrenceId,
      frequency: frequency ?? this.frequency,
      count: count ?? this.count,
      endDate: endDate ?? this.endDate,
    );
  }
}
