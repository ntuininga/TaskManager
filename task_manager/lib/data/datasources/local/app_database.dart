import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:task_manager/data/datasources/local/task_datsource.dart';
import 'package:task_manager/data/entities/task_category_entity.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';

const String filename = "task_manager_database.db";

const String boolType = "BOOLEAN NOT NULL";
const String idType = "INTEGER PRIMARY KEY AUTOINCREMENT";
const String foreignKeyType = "FOREIGN KEY";
const String textTypeNullable = "TEXT";
const String textType = "TEXT NOT NULL";
const String dateType = "DATETIME";

class AppDatabase {
  AppDatabase._init();

  static final AppDatabase instance = AppDatabase._init();

  static sqflite.Database? _database;

  Future<sqflite.Database> get database async {
   if (_database != null) return _database!;

    _database = await _initializeDB(filename);

    return _database!;
  }

  Future<TaskDatasource> get taskDatasource async {
      final db = await database;
      return TaskDatasource(db);
  }

  Future _createDB(sqflite.Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON');

    print("Creating tables");
    await db.execute('''
      CREATE TABLE $taskTableName (
        $idField $idType,
        $titleField $textType,
        $descriptionField $textTypeNullable,
        $isDoneField $boolType,
        $taskCategoryField $textTypeNullable,
        $dateField $dateType,
        FOREIGN KEY ($taskCategoryField) REFERENCES $taskCategoryTableName ($categoryIdField)
      )
    ''');

    await db.execute('''
      CREATE TABLE $taskCategoryTableName (
        $categoryIdField $idType,
        $categoryTitleField $textType
      )
    ''');
  }

  Future<sqflite.Database> _initializeDB(String filename) async {
    print("Initializing Database");
    final dbPath = await sqflite.getDatabasesPath();
    final path = p.join(dbPath, filename);
    return await sqflite.openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Future<Task> createTask(Task task) async {
  //   final db = await instance.database;
  //   final id = await db.insert(taskTableName, task.toJson());
  //   return task.copyWith(id: id);
  // }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return await db.update(taskTableName, task.toJson(), where: '$idField = ?', whereArgs: [task.id]);
  }

  //TODO - Order by
  // Future<List<Task?>> fetchAllTasks() async {
  //   final db = await instance.database;
  //   final result = await db.query(taskTableName);
  //   return result.map((json) => Task.fromJson(json)).toList();
  // }

  Future<List<TaskCategoryEntity?>> fetchAllTaskCategories() async {
    final db = await instance.database;
    final result = await db.query(taskCategoryTableName);
    return result.map((json) => TaskCategoryEntity.fromJson(json)).toList();
  }

  Future<void> clearTasks() async {
    final db = await instance.database;
    await db.delete(taskTableName);
    await db.delete(taskCategoryTableName);
  }

  Future<TaskCategoryEntity> createTaskCategory(TaskCategoryEntity category) async {
    final db = await instance.database;
    final id = await db.insert(taskCategoryTableName, category.toJson());
    return category.copyWith(id: id);
  }

  Future<void> close() async {
    final db = await instance.database;
    return db.close();
  }
}