import 'package:task_manager/domain/models/recurrence_ruleset.dart';

abstract class RecurrenceRulesRepository {
  Future<int> insertRule(RecurrenceRuleset rule);
  Future<RecurrenceRuleset?> getRuleById(int recurrenceId);
  Future<int> updateRule(RecurrenceRuleset rule);
  Future<int> deleteRule(int recurrenceId);
  Future<List<RecurrenceRuleset>> getAllRules();
}
