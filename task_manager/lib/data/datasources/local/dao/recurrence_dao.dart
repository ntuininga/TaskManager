import 'package:sqflite/sqflite.dart';
import 'package:task_manager/data/entities/recurrence_ruleset_entity.dart';

class RecurrenceDao {
  final Database db;

  RecurrenceDao(this.db);

  Future<int> insertRecurrenceRule(RecurrenceRulesetEntity recurrence) async {
    return await db.insert('recurrenceRules', recurrence.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<RecurrenceRulesetEntity?> getRecurrenceRuleById(
      int recurrenceId) async {
    final List<Map<String, dynamic>> result = await db.query(
      'recurrenceRules',
      where: 'recurrenceId = ?',
      whereArgs: [recurrenceId],
    );

    if (result.isNotEmpty) {
      return RecurrenceRulesetEntity.fromJson(result.first);
    }
    return null;
  }

  Future<int> updateRecurrenceRule(RecurrenceRulesetEntity recurrence) async {
    return await db.update(
      'recurrenceRules',
      recurrence.toJson(),
      where: 'recurrenceId = ?',
      whereArgs: [recurrence.recurrenceId],
    );
  }

  Future<int> deleteRecurrenceRule(int recurrenceId) async {
    return await db.delete(
      'recurrenceRules',
      where: 'recurrenceId = ?',
      whereArgs: [recurrenceId],
    );
  }

  Future<List<RecurrenceRulesetEntity>> getAllRecurrenceRules() async {
    final List<Map<String, dynamic>> result = await db.query('recurrenceRules');

    return result
        .map((json) => RecurrenceRulesetEntity.fromJson(json))
        .toList();
  }
}
