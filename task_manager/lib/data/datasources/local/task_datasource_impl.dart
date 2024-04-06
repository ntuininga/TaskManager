// import 'package:task_manager/data/datasources/local/app_database.dart';
// import 'package:task_manager/data/datasources/local/task_datasource.dart';
// import 'package:task_manager/data/entities/task_entity.dart';

// class TaskDataSourceImpl implements TaskDataSource {
//   TaskDataSourceImpl(this.database);

//   final AppDatabase database;

//   @override
//   Future<List<TaskModel>> getAllTasks() async {
//     try {
//       final tasks = await database.fetchAllTasks();
//       return tasks;

//       //TODO
//       //return tasks.map((task) => TaskEntity.fromModel(task)).toList();
//     } catch (e) {
//       rethrow;
//     }
//   }
// }