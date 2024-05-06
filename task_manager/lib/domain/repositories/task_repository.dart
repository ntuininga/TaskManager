

import 'package:task_manager/domain/models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getAllTasks();

  Future<void> deleteAllTasks();
}