import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:task_manager/data/datasources/local/task_datsource.dart';
import 'package:task_manager/data/datasources/local/user_datasource.dart';
import 'package:task_manager/data/entities/task_category_entity.dart';
import 'package:task_manager/data/entities/task_entity.dart';

const String filename = "tasks_database.db";

const String idType = "INTEGER PRIMARY KEY AUTOINCREMENT";
const String foreignKeyType = "FOREIGN KEY";
const String textTypeNullable = "TEXT";
const String textType = "TEXT NOT NULL";
const String dateType = "DATETIME";
const String intType = "INTEGER";

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

  Future<UserDatasource> get userDatasource async {
    final db = await database;
    return UserDatasource(db);
  }

  Future _createDB(sqflite.Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON');

    print("Creating tables");
    await createTaskTable(db);

    await db.execute('''
      CREATE TABLE $taskCategoryTableName (
        $categoryIdField $idType,
        $categoryTitleField $textType,
        $categoryColourField $intType
      )
    ''');

    await _insertDefaultCategories(db);
  }

  Future<void> createTaskTable(sqflite.Database db) async {
    await db.execute('''
      CREATE TABLE $taskTableName (
        $idField $idType,
        $titleField $textType,
        $descriptionField $textTypeNullable,
        $isDoneField $intType,
        $taskCategoryField $intType DEFAULT 0,
        $dateField $dateType,
        $completedDateField $dateType,
        $createdOnField $dateType,
        $urgencyLevelField $intType,
        FOREIGN KEY ($taskCategoryField) REFERENCES $taskCategoryTableName ($categoryIdField)
      )
    ''');
  }

  Future<void> _insertDefaultCategories(sqflite.Database db) async {
    final defaultCategories = [
      const TaskCategoryEntity(id: 0, title: 'No Category', colour: 0xFFBDBDBD),  // Ensure ID 0
      const TaskCategoryEntity(title: 'Personal', colour: 0xFF42A5F5),
      const TaskCategoryEntity(title: 'Work', colour: 0xFF66BB6A),
      const TaskCategoryEntity(title: 'Shopping', colour: 0xFFFFCA28),
    ];

    for (var category in defaultCategories) {
      await db.insert(taskCategoryTableName, category.toJson());
      print("Inserted Category: ${category.title}");
    }
  }

  Future<sqflite.Database> _initializeDB(String filename) async {
    print("Initializing Database");
    final dbPath = await sqflite.getDatabasesPath();
    final path = p.join(dbPath, filename);
    return await sqflite.openDatabase(path, version: 1, onCreate: _createDB);
  }
}

