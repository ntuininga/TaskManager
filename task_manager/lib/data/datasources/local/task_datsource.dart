import 'package:sqflite/sqflite.dart' as sqflite;
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
      rethrow;
    }
  }

  Future<void> addTask(TaskEntity task) async {
    try {
      await db.insert(taskTableName, task.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAllTasks() async {
    try {
      await db.delete(taskTableName);
    } catch (e) {
      rethrow;
    }
  }

  //Task Categories
  Future<List<TaskCategoryEntity>> getAllCategories() async {
    try {
      final result = await db.query(taskCategoryTableName);
      return result.map((json) => TaskCategoryEntity.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addTaskCategory(TaskCategoryEntity category) async {
    try {
      await db.insert(taskCategoryTableName, category.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskCategoryEntity> getCategoryById(int id) async {
    try {
      final List<Map<String,dynamic>> result = await db.query(
        taskCategoryTableName,
        where: '$categoryIdField = ?',
        whereArgs: [id]
      );

      if (result.isNotEmpty) {
        return TaskCategoryEntity.fromJson(result.first);
      } else {
        throw Exception('Task Category with ID $id not found');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  
}