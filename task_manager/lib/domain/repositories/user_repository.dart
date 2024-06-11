
import 'package:task_manager/data/entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity> getUserData();
}