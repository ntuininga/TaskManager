import 'package:task_manager/data/datasources/local/dao/recurrence_dao.dart';
import 'package:task_manager/domain/models/recurrence_ruleset.dart';
import 'package:task_manager/domain/repositories/recurrence_rules_repository.dart';

class RecurrenceRulesRepositoryImpl implements RecurrenceRulesRepository {
  final RecurrenceDao dao;

  RecurrenceRulesRepositoryImpl(this.dao);

  @override
  Future<int> insertRule(RecurrenceRuleset rule) async {
    return await dao.insertRecurrenceRule(await rule.toEntity());
  }

  @override
  Future<RecurrenceRuleset?> getRuleById(int recurrenceId) async {
    final entity = await dao.getRecurrenceRuleById(recurrenceId);
    return entity != null ? RecurrenceRuleset.fromEntity(entity) : null;
  }

  @override
  Future<int> updateRule(RecurrenceRuleset rule) async {
    return await dao.updateRecurrenceRule(await rule.toEntity());
  }

  @override
  Future<int> deleteRule(int recurrenceId) async {
    return await dao.deleteRecurrenceRule(recurrenceId);
  }

  @override
  Future<List<RecurrenceRuleset>> getAllRules() async {
    final entities = await dao.getAllRecurrenceRules();
    return entities.map(RecurrenceRuleset.fromEntity).toList();
  }
}
