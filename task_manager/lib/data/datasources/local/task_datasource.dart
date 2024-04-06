
import 'package:task_manager/data/entities/task_entity.dart';

abstract class TaskDataSource {
  const TaskDataSource();

  //Returns a list of all tasks from local db
  Future<List<TaskModel>> getAllTasks();
}