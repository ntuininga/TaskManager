import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:task_manager/core/data_types.dart';
import 'package:task_manager/core/theme/color_schemes.dart';
import 'package:task_manager/data/datasources/local/dao/recurrence_dao.dart';
import 'package:task_manager/data/datasources/local/dao/recurring_instance_dao.dart';
import 'package:task_manager/data/datasources/local/dao/task_dao.dart';
import 'package:task_manager/data/datasources/local/dao/user_datasource.dart';
import 'package:task_manager/data/entities/recurring_task_details_entity.dart';
import 'package:task_manager/data/entities/task_category_entity.dart';
import 'package:task_manager/data/entities/task_entity.dart';

const String filename = "tasks_database.db";

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

  Future<RecurrenceDao> get recurrenceDao async {
    final db = await database;
    return RecurrenceDao(db);
  }

  Future<RecurringInstanceDao> get recurringInstanceDao async {
    final db = await database;
    return RecurringInstanceDao(db);
  }

  Future<UserDatasource> get userDatasource async {
    final db = await database;
    return UserDatasource(db);
  }

  Future<sqflite.Database> _initializeDB(String filename) async {
    final dbPath = await sqflite.getDatabasesPath();
    final path = p.join(dbPath, filename);

    // Open the database
    final db = await sqflite.openDatabase(
      path,
      version: 30,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
    await ensureDatabaseSchema(db);
    return db;
  }

  Future _createDB(sqflite.Database db, int version) async {
    await createTaskTable(db);
    await createRecurringInstancesTable(db);
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

    if (oldVersion < 29) {
      createRecurrenceRulesTable(db);
      createRecurringInstancesTable(db);
      migrateTaskTable(db);
      ensureDatabaseSchema(db);
    }

    if (oldVersion < 30) {
      ensureDatabaseSchema(db);
    }
  }

  Future<void> createTaskTable(sqflite.Database db) async {
    await db.execute('''
  CREATE TABLE $taskTableName (
    $idField $idType,
    $titleField $textType,
    $descriptionField $textTypeNullable,
    $isDoneField $intType,
    $taskCategoryIdField $intType DEFAULT 0,
    $dateField $dateType,
    $urgencyLevelField $intType,
    $timeField $timeType,
    $isRecurringField $intType,
    $recurrenceIdField $intType,
    $completedDateField $dateType,
    $updatedOnField $dateType,
    $createdOnField $dateType,
    FOREIGN KEY ($taskCategoryIdField) REFERENCES $taskCategoryTableName ($categoryIdField),
    FOREIGN KEY ($recurrenceIdField) REFERENCES recurrenceRules (recurrenceId) ON DELETE SET NULL
  )
''');
  }

  Future<void> createRecurrenceRulesTable(sqflite.Database db) async {
    await db.execute('''
      CREATE TABLE recurrenceRules (
        recurrenceId $idType,
        frequency $textType CHECK (frequency IN ('daily', 'weekly', 'monthly', 'yearly')),
        count $intType,
        endDate $dateType,
        isImmutable $intType
      )
''');
  }

  Future<void> createRecurringInstancesTable(sqflite.Database db) async {
    await db.execute('''
    CREATE TABLE recurringInstances (
      instanceId $idType,
      taskId $intType,
      occurrenceDate $dateType,
      occurrenceTime $timeType,
      isDone $intType,
      completedAt $dateType,
      FOREIGN KEY (taskId) REFERENCES tasks(id) ON DELETE CASCADE
      UNIQUE (taskId, occurrenceDate)
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

  Future<void> ensureDatabaseSchema(sqflite.Database db) async {
    print("Ensuring database Schema...");
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

    if (!tableNames.contains('recurringInstances')) {
      print("Creating recurring instances table...");
      await createRecurringInstancesTable(db);
    }

    if (!tableNames.contains('recurrenceRules')) {
      print("Creating recurrence rules table...");
      await createRecurrenceRulesTable(db);
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

    // Ensure required columns
    await ensureColumns(db, taskTableName, {
      idField: idType,
      titleField: textType,
      descriptionField: textTypeNullable,
      isDoneField: intType,
      taskCategoryIdField: "$intType DEFAULT 0",
      dateField: dateType,
      urgencyLevelField: intType,
      timeField: timeType,
      isRecurringField: intType,
      recurrenceIdField: intType,
      completedDateField: dateType,
      updatedOnField: dateType,
      createdOnField: dateType,
    });

    await ensureColumns(db, 'recurrenceRules', {
      'recurrenceId': idType,
      'frequency': textType,
      'count': intType,
      'endDate': dateType,
      'isImmutable': intType
    });

    await ensureColumns(db, 'recurringInstances', {
      'instanceId': idType,
      'taskId': intType,
      'occurrenceDate': dateType,
      'occurrenceTime': timeType,
      'isDone': intType,
      'completedAt': dateType,
    });

    // Ensure unique index on occurrenceDate
    await db.execute('''
    CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_occurrence_date
    ON recurringInstances (taskId, occurrenceDate)
  ''');

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

  Future<bool> _columnExists(
      sqflite.Database db, String tableName, String columnName) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    return result.any((column) => column['name'] == columnName);
  }

  Future<void> migrateTaskTable(sqflite.Database db) async {
    // Check existing columns in the task table
    final columns = await db.rawQuery('PRAGMA table_info($taskTableName)');
    final columnNames = columns.map((col) => col['name'] as String).toSet();

    // Add new columns if they don't exist
    if (!columnNames.contains(isRecurringField)) {
      await db.execute('''
        ALTER TABLE $taskTableName
        ADD COLUMN $isRecurringField $intType DEFAULT 0
      ''');
    }

    if (!columnNames.contains(recurrenceIdField)) {
      await db.execute('''
        ALTER TABLE $taskTableName
        ADD COLUMN $recurrenceIdField $intType
      ''');
    }

    if (!columnNames.contains(updatedOnField)) {
      await db.execute('''
        ALTER TABLE $taskTableName
        ADD COLUMN $updatedOnField $dateType
      ''');
    }

    // Create a temporary table with the new schema including foreign key for recurrenceIdField
    await db.execute('''
    CREATE TABLE ${taskTableName}_temp (
      $idField $idType,
      $titleField $textType,
      $descriptionField $textTypeNullable,
      $isDoneField $intType,
      $taskCategoryIdField $intType DEFAULT 0,
      $dateField $dateType,
      $urgencyLevelField $intType,
      $timeField $timeType,
      $isRecurringField $intType DEFAULT 0,
      $recurrenceIdField $intType,
      $completedDateField $dateType,
      $updatedOnField $dateType,
      $createdOnField $dateType,
      FOREIGN KEY ($taskCategoryIdField) REFERENCES $taskCategoryTableName ($categoryIdField),
      FOREIGN KEY ($recurrenceIdField) REFERENCES recurrenceRules (recurrenceId) ON DELETE SET NULL
    )
  ''');

    // Copy data from the old table to the temporary table
    await db.execute('''
    INSERT INTO ${taskTableName}_temp (
      $idField, $titleField, $descriptionField, $isDoneField, $taskCategoryIdField, $dateField,
      $urgencyLevelField, $timeField, $isRecurringField, $recurrenceIdField, $completedDateField,
      $updatedOnField, $createdOnField
    )
    SELECT
      $idField, $titleField, $descriptionField, $isDoneField, $taskCategoryIdField, $dateField,
      $urgencyLevelField, $timeField, $isRecurringField, $recurrenceIdField, $completedDateField,
      $updatedOnField, $createdOnField
    FROM $taskTableName
  ''');

    // Drop the old task table
    await db.execute('DROP TABLE $taskTableName');

    // Rename the temporary table to the original table name
    await db
        .execute('ALTER TABLE ${taskTableName}_temp RENAME TO $taskTableName');

    // Re-enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');

    print(
        "Migration completed: Added foreign key for recurrenceIdField and updated schema.");
  }
}
