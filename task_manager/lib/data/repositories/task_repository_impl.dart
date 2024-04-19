import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final AppDatabase _appDatabase;

  TaskRepositoryImpl(this._appDatabase);

  @override
  Future<List<Task>> getAllTasks() async {
    final taskEntities = await _appDatabase.taskDatasource.getAllTasks();
    
    final tasks = taskEntities.map((taskEntity) {
      return Task.fromTaskEntity(taskEntity);
    }).toList();

    return tasks;
  }
}