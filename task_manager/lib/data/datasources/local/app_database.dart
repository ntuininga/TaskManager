import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:task_manager/core/theme/color_schemes.dart';
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
      $reminderField $boolType,
      $reminderDateField $dateType,
      $reminderTimeField $timeType,
      $notifyBeforeMinutesField $intType,
      $timeField $timeType,
      $recurrenceTypeField $intType,
      $recurrenceIntervalField $intType,
      $startDateField $textTypeNullable,
      $endDateField $textTypeNullable,
      $nextOccurrenceField $textTypeNullable,
      $recurrenceRuleField $textType
      FOREIGN KEY ($taskCategoryField) REFERENCES $taskCategoryTableName ($categoryIdField)
    )
  ''');
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
    return await sqflite.openDatabase(
      path,
      version: 14, // Incremented version
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(
      sqflite.Database db, int oldVersion, int newVersion) async {
    //Update category colours
    if (oldVersion < 10) {
      // Query all categories
      final List<Map<String, dynamic>> categories =
          await db.query(taskCategoryTableName);

      // Get all default colors as integers
      final Set<int> defaultColorValues =
          defaultColors.map((color) => color.value).toSet();

      // Keep track of used colors
      final Set<int> usedColors = categories
          .map((category) => category['colour'] as int?)
          .whereType<int>()
          .toSet();

      // Find available colors from defaultColors
      final List<int> availableColors =
          defaultColorValues.difference(usedColors).toList();

      // Reassign colors to categories not using defaultColors
      for (var category in categories) {
        final int? colorValue = category['colour'] as int?;
        final int categoryId = category['id'] as int;

        // Skip updating "No Category" (ID 0) and ensure it stays grey
        if (categoryId == 0) {
          continue;
        }

        // Debug: Ensure category exists before updating
        try {
          final existingCategory = await db.query(
            taskCategoryTableName,
            where: 'id = ?',
            whereArgs: [categoryId],
          );

          if (existingCategory.isEmpty) {
            print('Category with ID $categoryId not found in the database');
            continue; // Skip this category if not found
          }

          if (colorValue == null || !defaultColorValues.contains(colorValue)) {
            // Assign a new color if available
            if (availableColors.isNotEmpty) {
              final int newColor = availableColors.removeAt(0);
              await db.update(
                taskCategoryTableName,
                {'colour': newColor},
                where: 'id = ?',
                whereArgs: [categoryId],
              );
              print(
                  'Updated category with ID $categoryId to new color $newColor');
            }
          }
        } catch (e) {
          print('Error getting category by ID $categoryId: $e');
        }
      }
    }

    if (oldVersion < 11) {
      if (!await _columnExists(db, taskTableName, recurrenceTypeField)) {
        await db.execute('''
          ALTER TABLE $taskTableName ADD COLUMN $recurrenceTypeField $textTypeNullable
        ''');
      }
    }

    if (oldVersion < 12) {
      if (!await _columnExists(db, taskTableName, recurrenceIntervalField)) {
        await db.execute('''
          ALTER TABLE $taskTableName ADD COLUMN $recurrenceIntervalField $intType
        ''');
      }
      if (!await _columnExists(db, taskTableName, startDateField)) {
        await db.execute('''
          ALTER TABLE $taskTableName ADD COLUMN $startDateField $textTypeNullable
        ''');
      }
      if (!await _columnExists(db, taskTableName, endDateField)) {
        await db.execute('''
          ALTER TABLE $taskTableName ADD COLUMN $endDateField $textTypeNullable
        ''');
      }
      if (!await _columnExists(db, taskTableName, nextOccurrenceField)) {
        await db.execute('''
          ALTER TABLE $taskTableName ADD COLUMN $nextOccurrenceField $textTypeNullable
        ''');
      }
    }

    if (oldVersion < 13) {
      // Add new fields for version 13
      if (!await _columnExists(db, taskTableName, selectedDaysField)) {
        await db.execute('''
          ALTER TABLE $taskTableName ADD COLUMN $selectedDaysField $textTypeNullable
        ''');
      }

      if (!await _columnExists(db, taskTableName, recurrenceOptionField)) {
        await db.execute('''
          ALTER TABLE $taskTableName ADD COLUMN $recurrenceOptionField $textTypeNullable
        ''');
      }

      if (!await _columnExists(db, taskTableName, occurenceCountField)) {
        await db.execute('''
          ALTER TABLE $taskTableName ADD COLUMN $occurenceCountField $intType
        ''');
      }
    }

    if (oldVersion < 14) {
      if (!await _columnExists(db, taskTableName, recurrenceRuleField)) {
        await db.execute('''
          ALTER TABLE $taskTableName ADD COLUMN $recurrenceRuleField $textType
          ''');
      }
    }
  }

  Future<bool> _columnExists(
      sqflite.Database db, String tableName, String columnName) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    return result.any((column) => column['name'] == columnName);
  }
}
