import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:task_manager/models/task.dart';

const String filename = "task_manager_database.db";

class AppDatabase {
  AppDatabase._init();

  static final AppDatabase instance = AppDatabase._init();

  static sqflite.Database? _database;

  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;

    _database = await _initializeDB(filename);
    return _database!;
  }

  Future _createDB(sqflite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE $taskTableName (
        $idField $idType,
        $titleField $textType,
        $descriptionField $textTypeNullable,
        $isDoneField $boolType
      )
    ''');
  }

  Future<sqflite.Database> _initializeDB(String filename) async {
    final dbPath = await sqflite.getDatabasesPath();
    final path = p.join(dbPath, filename);
    return await sqflite.openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<Task> createTask(Task task) async {
    final db = await instance.database;
    final id = await db.insert(taskTableName, task.toJson());
    return task.copyWith(id: id);
  }

  //TODO - Order by
  Future<List<Task?>> fetchAllTasks() async {
    final db = await instance.database;
    final result = await db.query(taskTableName);
    return result.map((json) => Task.fromJson(json)).toList();
  }

  Future<void> close() async {
    final db = await instance.database;
    return db.close();
  }
}