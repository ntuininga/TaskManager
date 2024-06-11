
import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/data/entities/user_entity.dart';
import 'package:task_manager/domain/models/user.dart';
import 'package:task_manager/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final AppDatabase _appDatabase;

  UserRepositoryImpl(this._appDatabase);

  Future<UserEntity> getUserData() async {
    var datasource = await _appDatabase.userDatasource;
    return await datasource.getUserData();
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
