import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/domain/models/task.dart';

void completeTask(AppDatabase db, Task task) {
  db.updateTask(task);
}