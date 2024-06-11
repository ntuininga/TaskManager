
import 'package:task_manager/data/entities/user_entity.dart';

class User {
  final int? id;
  final int? completedTasks;
  final int? pendingTasks;

  User({
    this.id,
    this.completedTasks,
    this.pendingTasks,
  });

  static User fromUserEntity(UserEntity entity) => User(

  );

  static UserEntity toUserEntity(User model) => UserEntity(
    id: model.id,
    completedTasks: model.completedTasks,
    pendingTasks: model.pendingTasks
  );
}