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
    await db.update(
        recurringDetailsTableName, {"completedOnTasks": datesString},
        where: "id = ?", whereArgs: [taskId]);
  }

  Future<void> updateMissedDates(int taskId, List<DateTime> missedDates) async {
    final String datesString =
        missedDates.map((date) => date.toIso8601String()).join(",");
    await db.update(
        recurringDetailsTableName, {"missedDatesField": datesString},
        where: "id = ?", whereArgs: [taskId]);
  }

  Future<void> clearAllScheduledDates(int taskId) async {
    try {
      await _printAllRows();
      // Update the database to clear scheduled dates for the given taskId
      await db.update(
        recurringDetailsTableName,
        {"scheduledTasks": ""}, // Clears the scheduled tasks
        where: "$taskIdField = ?",
        whereArgs: [taskId],
      );
      print('Successfully cleared all scheduled dates for task ID $taskId');
      await _printAllRows();
    } catch (e) {
      print('Error clearing scheduled dates: $e');
      rethrow;
    }
  }

  Future<void> _printAllRows() async {
    try {
      final result = await db.query(recurringDetailsTableName);

      print("Current Table Content:");
      for (var row in result) {
        print(row);
      }
    } catch (e) {
      print('Error printing all rows: $e');
    }
  }

  Future<void> insertNewDates({
    required int taskId,
    List<DateTime>? newScheduledDates,
    List<DateTime>? newCompletedDates,
    List<DateTime>? newMissedDates,
  }) async {
    try {
      // Create a new entity and populate it with the provided dates
      final entity = RecurringTaskDetailsEntity(taskId: taskId);
      entity.scheduledDates = newScheduledDates ?? [];
      entity.completedOnDates = newCompletedDates ?? [];
      entity.missedDates = newMissedDates ?? [];

      // Convert entity to JSON
      final data = entity.toJson();

      // Insert the new record into the database
      final rowsAffected = await db.insert(
        recurringDetailsTableName,
        data,
      );

      if (rowsAffected == 0) {
        print('Failed to insert new dates for task ID $taskId');
      } else {
        print('Successfully inserted new dates for task ID $taskId');
      }

      // Fetch and print the inserted record
      final insertedRecord = await db.query(
        recurringDetailsTableName,
        where: "$taskIdField = ?",
        whereArgs: [taskId],
      );
      print("Inserted Record: $insertedRecord");
    } catch (e) {
      print('Error inserting new dates: $e');
      rethrow;
    }
  }

  Future<void> updateExistingDates({
    required int taskId,
    List<DateTime>? newScheduledDates,
    List<DateTime>? newCompletedDates,
    List<DateTime>? newMissedDates,
  }) async {
    try {
      // Check if the record already exists by taskId
      final result = await db.query(
        recurringDetailsTableName,
        where: "$taskIdField = ?",
        whereArgs: [taskId],
      );

      if (result.isNotEmpty) {
        // Record exists, update it
        final entity = RecurringTaskDetailsEntity.fromJson(result.first);

        // Override the date lists with the new ones, if provided
        if (newScheduledDates != null) {
          entity.scheduledDates = newScheduledDates;
        }
        if (newCompletedDates != null) {
          entity.completedOnDates = newCompletedDates;
        }
        if (newMissedDates != null) {
          entity.missedDates = newMissedDates;
        }

        // Convert entity to JSON
        final updatedData = entity.toJson();

        // Update the existing record
        final rowsAffected = await db.update(
          recurringDetailsTableName,
          updatedData,
          where: "$taskIdField = ?",
          whereArgs: [taskId],
        );

        if (rowsAffected == 0) {
          print('No rows were updated for task ID $taskId');
        } else {
          print('Successfully updated dates for task ID $taskId');
        }

        // Fetch and print the updated record
        final updatedRecord = await db.query(
          recurringDetailsTableName,
          where: "$taskIdField = ?",
          whereArgs: [taskId],
        );
        print("Updated Record: $updatedRecord");
      } else {
        print('No record found for task ID $taskId to update');
      }
    } catch (e) {
      print('Error updating existing dates: $e');
      rethrow;
    }
  }

  Future<List<DateTime>> getAllScheduledDates(int taskId) async {
    try {
      final result = await db.query(
        recurringDetailsTableName,
        where: "$taskIdField = ?",
        whereArgs: [taskId],
      );

      if (result.isNotEmpty) {
        final entity = RecurringTaskDetailsEntity.fromJson(result.first);

        // Ensure scheduledDates is not null and return an empty list if it's null
        return entity.scheduledDates ??
            []; // Returning the list of scheduled dates or an empty list if null
      } else {
        throw Exception('No scheduled dates found for task ID $taskId');
      }
    } catch (e) {
      print('Error getting scheduled dates for task ID $taskId: $e');
      rethrow;
    }
  }

  Future<void> addCompletedDate(int taskId, DateTime completedDate) async {
    try {
      final result = await db.query(
        recurringDetailsTableName,
        where: "$taskIdField = ?",
        whereArgs: [taskId],
      );

      if (result.isNotEmpty) {
        final entity = RecurringTaskDetailsEntity.fromJson(result.first);

        // Ensure completedOnDates is not null and initialize it if necessary
        final completedOnDates = entity.completedOnDates ?? [];

        // Add the new completed date to the list
        entity.completedOnDates!.add(completedDate);

        // Convert entity to JSON
        final updatedData = entity.toJson();

        // Update the record in the database
        final rowsAffected = await db.update(
          recurringDetailsTableName,
          updatedData,
          where: "$taskIdField = ?",
          whereArgs: [taskId],
        );

        if (rowsAffected == 0) {
          print('Failed to add completed date for task ID $taskId');
        } else {
          print('Successfully added completed date for task ID $taskId');
        }
      } else {
        print('No record found for task ID $taskId');
      }
    } catch (e) {
      print('Error adding completed date: $e');
      rethrow;
    }
  }

  Future<RecurringTaskDetailsEntity?> getRecurringTaskDetails(int taskId) async {
    try {
      final result = await db.query(
        recurringDetailsTableName,
        where: "$taskIdField = ?",
        whereArgs: [taskId],
      );

      if (result.isNotEmpty) {
        return RecurringTaskDetailsEntity.fromJson(result.first);
      }
      return null; // Return null if no matching record is found
    } catch (e) {
      print('Error fetching recurring task details for task ID $taskId: $e');
      rethrow;
    }
  }


  Future<void> removeScheduledDate(int taskId, DateTime scheduledDate) async {
    try {
      final result = await db.query(
        recurringDetailsTableName,
        where: "$taskIdField = ?",
        whereArgs: [taskId],
      );

      if (result.isNotEmpty) {
        final entity = RecurringTaskDetailsEntity.fromJson(result.first);

        // Ensure scheduledDates is not null and initialize it if necessary
        entity.scheduledDates = entity.scheduledDates ?? [];

        // Remove the scheduled date from the list
        entity.scheduledDates!
            .removeWhere((date) => date.isAtSameMomentAs(scheduledDate));

        // Convert entity to JSON
        final updatedData = entity.toJson();

        // Update the record in the database
        final rowsAffected = await db.update(
          recurringDetailsTableName,
          updatedData,
          where: "$taskIdField = ?",
          whereArgs: [taskId],
        );

        if (rowsAffected == 0) {
          print('Failed to remove scheduled date for task ID $taskId');
        } else {
          print('Successfully removed scheduled date for task ID $taskId');
        }
      } else {
        print('No record found for task ID $taskId');
      }
    } catch (e) {
      print('Error removing scheduled date: $e');
      rethrow;
    }
  }
}
