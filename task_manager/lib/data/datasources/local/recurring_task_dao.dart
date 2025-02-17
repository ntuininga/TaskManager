import 'package:task_manager/data/entities/recurring_task_details_entity.dart';
import 'package:sqflite/sqflite.dart';

class RecurringTaskDao {
  final Database db;

  RecurringTaskDao(this.db);

  Future<List<RecurringTaskDetailsEntity>> getAllRecurringTasks() async {
    final List<Map<String, dynamic>> maps = await db.query("recurringTaskDetails");
    return maps.map((map) => RecurringTaskDetailsEntity.fromJson(map)).toList();
  }

  Future<void> addScheduledDates(int taskId, List<DateTime> newDates) async {
    final String datesString = newDates.map((date) => date.toIso8601String()).join(",");
    await db.update("recurringTaskDetails", {"scheduledTasks": datesString}, where: "id = ?", whereArgs: [taskId]);
  }

  Future<void> updateCompletedOnDates(int taskId, List<DateTime> completedDates) async {
    final String datesString = completedDates.map((date) => date.toIso8601String()).join(",");
    await db.update("recurringTaskDetails", {"completedOnTasks": datesString}, where: "id = ?", whereArgs: [taskId]);
  }

  Future<void> updateMissedDates(int taskId, List<DateTime> missedDates) async {
    final String datesString = missedDates.map((date) => date.toIso8601String()).join(",");
    await db.update("recurringTaskDetails", {"missedDatesField": datesString}, where: "id = ?", whereArgs: [taskId]);
  }
}
