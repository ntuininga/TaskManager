
import 'package:task_manager/domain/models/user.dart';

abstract class UserRepository {
  Future<User> getUserData();
}