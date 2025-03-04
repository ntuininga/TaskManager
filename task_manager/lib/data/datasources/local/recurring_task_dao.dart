import 'package:task_manager/data/entities/recurring_task_details_entity.dart';
import 'package:sqflite/sqflite.dart';

class RecurringTaskDao {
  final Database db;

  RecurringTaskDao(this.db);

  Future<RecurringTaskDetailsEntity> fetchDetailsByTaskId(taskId) async {
    try {
      final result = await db.query(
        recurringDetailsTableName,
        where: '$taskIdField = ?',
        whereArgs: [taskId],
      );

      if (result.isNotEmpty) {
        return RecurringTaskDetailsEntity.fromJson(result.first);
      } else {
        throw Exception('Recurring Details with ID $taskId not found');
      }
    } catch (e) {
      print('Error getting Recurring Details by Id: $e');
      rethrow;
    }
  }

  Future<List<RecurringTaskDetailsEntity>> getAllRecurringTasks() async {
    final List<Map<String, dynamic>> maps =
        await db.query(recurringDetailsTableName);
    return maps.map((map) => RecurringTaskDetailsEntity.fromJson(map)).toList();
  }

  Future<void> addScheduledDates(int taskId, List<DateTime> newDates) async {
    final String datesString =
        newDates.map((date) => date.toIso8601String()).join(",");
    await db.update(recurringDetailsTableName, {"scheduledTasks": datesString},
        where: "id = ?", whereArgs: [taskId]);
  }

  Future<void> updateCompletedOnDates(
      int taskId, List<DateTime> completedDates) async {
    final String datesString =
        completedDates.map((date) => date.toIso8601String()).join(",");
    await db.update(recurringDetailsTableName, {"completedOnTasks": datesString},
        where: "id = ?", whereArgs: [taskId]);
  }

  Future<void> updateMissedDates(int taskId, List<DateTime> missedDates) async {
    final String datesString =
        missedDates.map((date) => date.toIso8601String()).join(",");
    await db.update(recurringDetailsTableName, {"missedDatesField": datesString},
        where: "id = ?", whereArgs: [taskId]);
  }

  Future<void> insertNewDates({
    required int taskId,
    List<DateTime>? newScheduledDates,
    List<DateTime>? newCompletedDates,
    List<DateTime>? newMissedDates,
  }) async {
    try {
      RecurringTaskDetailsEntity entity;


      // No existing record, create a new one
      entity = RecurringTaskDetailsEntity(taskId: taskId);

      // Append new dates if provided
      entity.scheduledDates = [
        ...?entity.scheduledDates,
        ...?newScheduledDates
      ];
      entity.completedOnDates = [
        ...?entity.completedOnDates,
        ...?newCompletedDates
      ];
      entity.missedDates = [
        ...?entity.missedDates,
        ...?newMissedDates
      ];

      // Convert entity to JSON and update DB
      final updatedData = entity.toJson();

      final rowsAffected = await db.insert(
        recurringDetailsTableName,
        updatedData,
      );

      if (rowsAffected == 0) {
        print('No rows were updated for task ID $taskId');
      } else {
        print('Successfully updated task ID $taskId');
      }

      // Fetch and print updated record
      final updatedRecord = await db.query(
        recurringDetailsTableName,
        where: "$taskIdField = ?",
        whereArgs: [taskId],
      );
      print("Updated Record: $updatedRecord");
    } catch (e) {
      print('Error inserting new dates: $e');
      rethrow;
    }
  }





}
