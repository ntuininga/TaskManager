import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:task_manager/core/theme/color_schemes.dart';
import 'package:task_manager/data/datasources/local/task_datsource.dart';
import 'package:task_manager/data/datasources/local/user_datasource.dart';
import 'package:task_manager/data/entities/recurring_task_details_entity.dart';
import 'package:task_manager/data/entities/task_category_entity.dart';
import 'package:task_manager/data/entities/task_entity.dart';

const String filename = "tasks_database.db";

const String idType = "INTEGER PRIMARY KEY AUTOINCREMENT";
const String foreignKeyType = "FOREIGN KEY";
const String textTypeNullable = "TEXT";
const String textType = "TEXT NOT NULL";
const String dateType = "DATETIME";
const String intType = "INTEGER";
const String boolType = "BOOLEAN";
const String timeType = "TIME"; // Assuming sqflite supports TIME type

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

    await createTaskTable(db);
    await createRecurringTaskTable(db);

    await db.execute('''
      CREATE TABLE $taskCategoryTableName (
        $categoryIdField $idType,
        $categoryTitleField $textType,
        $categoryColourField $intType
      )
    ''');

    await ensureDatabaseSchema(db);

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
    $reminderField $boolType,
    $reminderDateField $dateType,
    $reminderTimeField $timeType,
    $notifyBeforeMinutesField $intType,
    $timeField $timeType,
    $nextOccurrenceField $nextOccurrenceField,
    $recurrenceRuleSetField $textTypeNullable DEFAULT '',
    FOREIGN KEY ($taskCategoryField) REFERENCES $taskCategoryTableName ($categoryIdField)
  )
''');
  }

  Future<void> createRecurringTaskTable(sqflite.Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $recurringDetailsTableName (
        $idField $idType,  
        $taskIdField $intType,  -- Added taskId field
        $scheduledTasksField $textTypeNullable,
        $completedOnTasksField $textTypeNullable,
        $missedDatesFields $textTypeNullable,      
        FOREIGN KEY ($taskIdField) REFERENCES $taskTableName ($idField) ON DELETE CASCADE 
      )
    ''');
    print("Created Recurring Details Table");
  }

  Future<void> _insertDefaultCategories(sqflite.Database db) async {
    // Default category titles
    final defaultTitles = [
      'No Category', // Special category with ID 0
      'Personal',
      'Work',
      'Shopping',
    ];

    for (int i = 0; i < defaultTitles.length; i++) {
      // Use the same color index as the title, loop around if needed
      final color = defaultColors[i % defaultColors.length].value;

      final category = TaskCategoryEntity(
        id: i == 0 ? 0 : null, // Ensure 'No Category' has ID 0
        title: defaultTitles[i],
        colour: i == 0 ? Colors.grey.value : color,
      );
      await db.insert(taskCategoryTableName, category.toJson());
    }
  }

  Future<void> _insertDefaultCategoriesBefore(sqflite.Database db) async {
    final defaultCategories = [
      const TaskCategoryEntity(
          id: 0, title: 'No Category', colour: 0xFFBDBDBD), // Ensure ID 0
      const TaskCategoryEntity(title: 'Personal', colour: 0xFF42A5F5),
      const TaskCategoryEntity(title: 'Work', colour: 0xFF66BB6A),
      const TaskCategoryEntity(title: 'Shopping', colour: 0xFFFFCA28),
    ];

    for (var category in defaultCategories) {
      await db.insert(taskCategoryTableName, category.toJson());
    }
  }

  Future<sqflite.Database> _initializeDB(String filename) async {
    final dbPath = await sqflite.getDatabasesPath();
    final path = p.join(dbPath, filename);

    // Open the database
    final db = await sqflite.openDatabase(
      path,
      version: 28,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );

    // Debug: Check if table creation works
    final result = await db
        .rawQuery('SELECT name FROM sqlite_master WHERE type = "table"');
    print('Tables in the database: $result');

    // Check if the tasks table exists
    bool taskTableExists = result.any((table) => table['name'] == 'tasks');
    bool recurringDetailsTableExists =
        result.any((table) => table['name'] == recurringDetailsTableName);

    if (!taskTableExists) {
      print('Tasks table does not exist, creating it...');
      await createTaskTable(db); // Create the table if it doesn't exist
    }

    if (!recurringDetailsTableExists) {
      print('Recurring details table does not exist, creating it...');
      await createRecurringTaskTable(db);
    }

    return db;
  }

  Future<void> ensureDatabaseSchema(sqflite.Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');

    // Check existing tables
    final existingTables =
        await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");

    final tableNames =
        existingTables.map((table) => table['name'] as String).toSet();

    // Ensure required tables exist
    if (!tableNames.contains(taskTableName)) {
      print("Creating missing task table...");
      await createTaskTable(db);
    }

    if (!tableNames.contains(recurringDetailsTableName)) {
      print("Creating missing recurring task table...");
      await createRecurringTaskTable(db);
    }

    if (!tableNames.contains(taskCategoryTableName)) {
      print("Creating missing category table...");
      await db.execute('''
        CREATE TABLE $taskCategoryTableName (
          $categoryIdField $idType,
          $categoryTitleField $textType,
          $categoryColourField $intType
        )
      ''');
      await _insertDefaultCategories(db);
    }

    // Check existing columns for each table
    await ensureColumns(db, taskTableName, {
      idField: idType,
      titleField: textType,
      descriptionField: textTypeNullable,
      isDoneField: intType,
      taskCategoryField: "$intType DEFAULT 0",
      dateField: dateType,
      completedDateField: dateType,
      createdOnField: dateType,
      urgencyLevelField: intType,
      reminderField: boolType,
      reminderDateField: dateType,
      reminderTimeField: timeType,
      notifyBeforeMinutesField: intType,
      timeField: timeType,
      nextOccurrenceField: dateType,
      recurrenceRuleSetField: "$textTypeNullable DEFAULT ''",
    });

    await ensureColumns(db, recurringDetailsTableName, {
      idField: idType,
      taskIdField: intType,
      scheduledTasksField: textTypeNullable,
      completedOnTasksField: textTypeNullable,
      missedDatesFields: textTypeNullable,
    });

    await ensureColumns(db, taskCategoryTableName, {
      categoryIdField: idType,
      categoryTitleField: textType,
      categoryColourField: intType,
    });

    print("Database schema verified and updated.");
  }

  /// Ensures a table has all required columns, adding missing ones
  Future<void> ensureColumns(sqflite.Database db, String tableName,
      Map<String, String> columns) async {
    final existingColumns =
        await db.rawQuery("PRAGMA table_info($tableName)"); // Get table schema
    print("Schema for $tableName: $columns");
    final existingColumnNames =
        existingColumns.map((column) => column['name'] as String).toSet();

    for (var column in columns.entries) {
      if (!existingColumnNames.contains(column.key)) {
        print("Adding missing column: ${column.key} to $tableName");
        await db.execute(
            "ALTER TABLE $tableName ADD COLUMN ${column.key} ${column.value}");
      }
    }
  }

  Future<void> _upgradeDB(
      sqflite.Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 26) {
      ensureDatabaseSchema(db);
    }
    if (oldVersion < 28) {
      await db.transaction((txn) async {
        // 1. Create a new table with the updated schema (recurringDetails)
        await txn.execute('''
          CREATE TABLE IF NOT EXISTS recurringDetails (
            $idField $idType,  
            $taskIdField $intType,
            $scheduledTasksField $textTypeNullable,
            $completedOnTasksField $textTypeNullable,
            $missedDatesFields $textTypeNullable,      
            FOREIGN KEY ($taskIdField) REFERENCES $taskTableName ($idField) ON DELETE CASCADE 
          )
        ''');

        // 2. Copy data from the old table (recurringTaskDetails) to the new one (recurringDetails)
        await txn.execute('''
          INSERT INTO recurringDetails (taskId, scheduledTasks, completedOnTasks, missedDatesField)
          SELECT taskId, scheduledTasks, completedOnTasks, missedDatesField FROM recurringTaskDetails
        ''');

        // 3. Drop the old table
        await txn.execute('DROP TABLE recurringTaskDetails');

        // 4. Rename the new table to match the old table name
        await txn.execute(
            'ALTER TABLE recurringDetails RENAME TO recurringTaskDetails');
      });

      print("Database migration completed: scheduledDates is now nullable.");
      ensureDatabaseSchema(db);
    }
  }

  Future<bool> _columnExists(
      sqflite.Database db, String tableName, String columnName) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    return result.any((column) => column['name'] == columnName);
  }
}
