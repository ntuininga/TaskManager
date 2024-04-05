import 'package:task_manager/core/data/app_database.dart';
import 'package:task_manager/models/task.dart';

void completeTask(AppDatabase db, Task task) {
  db.updateTask(task);
}