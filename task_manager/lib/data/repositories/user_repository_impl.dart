
import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/domain/models/user.dart';
import 'package:task_manager/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final AppDatabase _appDatabase;

  UserRepositoryImpl(this._appDatabase);

  Future<User> getUserData() async {
    var datasource = await _appDatabase.userDatasource;
    var userData = await datasource.getUserData();

    var userModel = User.fromUserEntity(userData);
    
    return userModel;
  }

  Future<void> updateUserData(User user) async {
    var datasource = await _appDatabase.userDatasource;

    final userEntity = User.toUserEntity(user);

    return await datasource.updateUserData(userEntity);
  }

  Future<void> completeTask() async {
    var datasource = await _appDatabase.userDatasource;
    return await datasource.completeTask();
  }
}
