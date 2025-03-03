import 'package:task_manager/data/entities/recurring_task_details_entity.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_manager/data/entities/task_entity.dart';

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
      final Map<String, String> updates = {};

      if (newScheduledDates != null) {
        final String scheduledDatesString = newScheduledDates
            .map((date) => date.toIso8601String())
            .join(",");
        updates[scheduledTasksField] = scheduledDatesString;
      }

      if (newCompletedDates != null) {
        final String completedDatesString = newCompletedDates
            .map((date) => date.toIso8601String())
            .join(",");
        updates[completedOnTasksField] = completedDatesString;
      }

      if (newMissedDates != null) {
        final String missedDatesString = newMissedDates
            .map((date) => date.toIso8601String())
            .join(",");
        updates[missedDatesFields] = missedDatesString;
      }

      if (updates.isNotEmpty) {
        await db.transaction((txn) async {
          final rowsAffected = await txn.insert(
            recurringDetailsTableName,
            updates,
          );
          if (rowsAffected == 0) {
            print('No rows were updated for task ID $taskId');
          }
        });

        // Fetch the updated record to confirm the update
        final updatedRecord = await db.query(
          recurringDetailsTableName,
          where: "$taskIdField = ?",
          whereArgs: [taskId],
        );
        final allRecords = await db.query(recurringDetailsTableName);
        print("All Records: $allRecords");

        if (updatedRecord.isNotEmpty) {
          final updatedFields = updatedRecord.first;
          print("Updated task (ID: $taskId):");
          print("Scheduled Tasks: ${updatedFields[scheduledTasksField]}");
          print("Completed Tasks: ${updatedFields[completedOnTasksField]}");
          print("Missed Dates: ${updatedFields[missedDatesFields]}");
        } else {
          print("No task found with ID $taskId.");
        }
      }
    } catch (e) {
      print('Error inserting new dates: $e');
      rethrow;
    }
  }




}
