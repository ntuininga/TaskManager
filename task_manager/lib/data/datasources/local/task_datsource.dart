import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/data/entities/task_category_entity.dart';
import 'package:task_manager/data/entities/task_entity.dart';

class TaskDatasource {
  final sqflite.Database db;

  TaskDatasource(this.db);

  Future<List<TaskEntity>> getAllTasks() async {
    try {
      final result = await db.query(taskTableName);
      return result.map((json) => TaskEntity.fromJson(json)).toList();
    } catch (e) {
      print('Error getting all tasks: $e'); // Logging error
      rethrow;
    }
  }

  Future<List<TaskEntity>> getUnfinishedTasks() async {
    try {
      final result = await db.query(
        taskTableName,
        where: '$isDoneField = ?',
        whereArgs: [0], // SQLite does not have a boolean type
      );
      return result.map((json) => TaskEntity.fromJson(json)).toList();
    } catch (e) {
      print('Error getting unfinished tasks: $e'); // Logging error
      rethrow;
    }
  }

  Future<List<TaskEntity>> getCompletedTasks() async {
    try {
      final result = await db.query(
        taskTableName,
        where: '$isDoneField = ?',
        whereArgs: [1], // SQLite does not have a boolean type
      );
      return result.map((json) => TaskEntity.fromJson(json)).toList();
    } catch (e) {
      print('Error getting completed tasks: $e'); // Logging error
      rethrow;
    }
  }

  Future<List<TaskEntity>> getTasksBetweenDates(
      DateTime start, DateTime end) async {
    try {
      final result = await db.query(
        taskTableName,
        where: 'date >= ? AND date < ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
      );
      return result.map((json) => TaskEntity.fromJson(json)).toList();
    } catch (e) {
      print('Error getting tasks between dates: $e'); // Logging error
      rethrow;
    }
  }

  Future<TaskEntity> addTask(TaskEntity task) async {
    try {
      final taskId = await db.insert(taskTableName, task.toJson());
      return task.copyWith(id: taskId);
    } catch (e) {
      print('Error adding task: $e'); // Logging error
      rethrow;
    }
  }

  Future<TaskEntity> updateTask(TaskEntity task) async {
    try {
      await db.update(
        taskTableName,
        task.toJson(),
        where: '$idField = ?',
        whereArgs: [task.id],
      );
      return task;
    } catch (e) {
      print('Error updating task: $e'); // Logging error
      rethrow;
    }
  }

  Future<void> completeTask(TaskEntity task) async {
    try {
      var completedTask =
          task.copyWith(completedDate: DateTime.now(), isDone: 1);
      await db.update(
        taskTableName,
        completedTask.toJson(),
        where: '$idField = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      print('Error completing task: $e'); // Logging error
      rethrow;
    }
  }

  Future<void> deleteAllTasks() async {
    try {
      await db.rawQuery("DROP TABLE IF EXISTS $taskTableName");
      await AppDatabase.instance.createTaskTable(db); // Recreate the table
    } catch (e) {
      print('Error deleting all tasks: $e'); // Logging error
      rethrow;
    }
  }

  Future<void> deleteTaskById(int id) async {
    try {
      await db.delete(
        taskTableName,
        where: "$idField = ?",
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting task by id: $e'); // Logging error
      rethrow;
    }
  }

  // Task Categories
  Future<List<TaskCategoryEntity>> getAllCategories() async {
    try {
      final result = await db.query(taskCategoryTableName);
      return result.map((json) => TaskCategoryEntity.fromJson(json)).toList();
    } catch (e) {
      print('Error getting all categories: $e'); // Logging error
      rethrow;
    }
  }

  Future<TaskCategoryEntity> addTaskCategory(TaskCategoryEntity category) async {
    try {
      final categoryId = await db.insert(taskCategoryTableName, category.toJson());
      return category.copyWith(id: categoryId);
    } catch (e) {
      print('Error adding task category: $e'); // Logging error
      rethrow;
    }
  }

  Future<TaskCategoryEntity> updateTaskCategory(TaskCategoryEntity category) async {
    try {
      await db.update(
        taskCategoryTableName,
        category.toJson(),
        where: '$categoryIdField = ?',
        whereArgs: [category.id],
      );
      return category;
    } catch (e) {
      print('Error updating task category: $e'); // Logging error
      rethrow;
    }
  }

  Future<void> deleteTaskCategory(int id) async {
    try {
      await db.delete(
        taskCategoryTableName,
        where: "$categoryIdField = ?",
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting task category: $e'); // Logging error
      rethrow;
    }
  }

  Future<TaskCategoryEntity> getCategoryById(int id) async {
    try {
      final List<Map<String, dynamic>> result = await db.query(
        taskCategoryTableName,
        where: '$categoryIdField = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        return TaskCategoryEntity.fromJson(result.first);
      } else {
        throw Exception('Task Category with ID $id not found');
      }
    } catch (e) {
      print('Error getting category by id: $e'); // Logging error
      rethrow;
    }
  }
}
