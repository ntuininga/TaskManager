import 'package:sqflite/sqflite.dart';
import 'package:task_manager/data/entities/recurring_instance_entity.dart';

class RecurringInstanceDao {
  final Database db;

  RecurringInstanceDao(this.db);

  Future<int> insertRecurringInstance(RecurringInstanceEntity instance) async {
    return await db.insert('recurringInstances', instance.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertRecurringInstances(List<RecurringInstanceEntity> instances) async {
    final dbClient = await db;

    for (final instance in instances) {
      await dbClient.insert(
        'recurring_instances', // Replace with your actual table name
        instance.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> insertRecurringInstancesBatch(
      List<RecurringInstanceEntity> instances) async {
    final batch = db.batch();
    for (var instance in instances) {
      batch.insert('recurringInstances', instance.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }


  /// Get all recurring instances by taskId
  Future<List<RecurringInstanceEntity>> getInstancesByTaskId(int taskId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'recurringInstances',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );
    return List.generate(maps.length, (i) => RecurringInstanceEntity.fromJson(maps[i]));
  }

  /// Get a specific instance by ID
  Future<RecurringInstanceEntity?> getInstanceById(int instanceId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'recurringInstances',
      where: 'instanceId = ?',
      whereArgs: [instanceId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return RecurringInstanceEntity.fromJson(maps.first);
    }
    return null;
  }

  /// Update a recurring instance
  Future<int> updateRecurringInstance(RecurringInstanceEntity instance) async {
    return await db.update(
      'recurringInstances',
      instance.toJson(),
      where: 'instanceId = ?',
      whereArgs: [instance.instanceId],
    );
  }

  /// Batch update multiple recurring instances
  Future<void> updateRecurringInstancesBatch(List<RecurringInstanceEntity> instances) async {
    final batch = db.batch();
    for (var instance in instances) {
      batch.update(
        'recurringInstances',
        instance.toJson(),
        where: 'instanceId = ?',
        whereArgs: [instance.instanceId],
      );
    }
    await batch.commit(noResult: true);
  }

  /// Delete a recurring instance by ID
  Future<int> deleteRecurringInstance(int instanceId) async {
    return await db.delete(
      'recurringInstances',
      where: 'instanceId = ?',
      whereArgs: [instanceId],
    );
  }

  /// Delete all recurring instances for a task
  Future<int> deleteInstancesByTaskId(int taskId) async {
    return await db.delete(
      'recurringInstances',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );
  }

  /// Get all recurring instances within a date range
  Future<List<RecurringInstanceEntity>> getInstancesByDateRange(DateTime start, DateTime end) async {
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM recurringInstances
      WHERE occurenceDate BETWEEN ? AND ?
      ORDER BY occurenceDate ASC
    ''', [start.toIso8601String(), end.toIso8601String()]);

    return List.generate(maps.length, (i) => RecurringInstanceEntity.fromJson(maps[i]));
  }

  /// Get all recurring instances that are not marked as done
  Future<List<RecurringInstanceEntity>> getUncompletedInstances() async {
    final List<Map<String, dynamic>> maps = await db.query(
      'recurringInstances',
      where: 'isDone = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => RecurringInstanceEntity.fromJson(maps[i]));
  }

  /// Mark a recurring instance as completed
  Future<int> completeInstance(int instanceId, DateTime completedAt) async {
    return await db.update(
      'recurringInstances',
      {
        'isDone': 1,
        'completedAt': completedAt.toIso8601String(),
      },
      where: 'instanceId = ?',
      whereArgs: [instanceId],
    );
  }

  /// Count all instances linked to a specific task
  Future<int> countInstancesByTaskId(int taskId) async {
    final result = await db.rawQuery('''
      SELECT COUNT(*) AS count FROM recurringInstances
      WHERE taskId = ?
    ''', [taskId]);

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
