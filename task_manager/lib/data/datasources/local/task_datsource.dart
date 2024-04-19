import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:task_manager/data/datasources/local/app_database.dart';
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
}