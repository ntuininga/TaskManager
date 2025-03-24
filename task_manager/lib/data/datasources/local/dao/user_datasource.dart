import 'package:sqflite/sqflite.dart';
import 'package:task_manager/data/entities/user_entity.dart';

class UserDatasource {
  final Database db;

  UserDatasource(this.db);

  Future<UserEntity> getUserData() async {
    try {
      final result = await db.query(userTableName);

      if (result.isNotEmpty) {
        return UserEntity.fromJson(result.first);
      } else {
        print("Creating new user");
        final newUser = UserEntity(completedTasks: 0, pendingTasks: 0);
        final id = await db.insert(userTableName, newUser.toJson());
        return newUser.copyWith(id: id);
      }
    } catch (e) {
      print("Error getting user data: $e");
      rethrow;
    }
  }

  Future<void> updateUserData(UserEntity userData) async {
    try {
      await db.update(
        userTableName,
        userData.toJson(),
        where: "$userIdField = ?",
        whereArgs: [userData.id],
      );
    } catch (e) {
      print("Error updating user data: $e");
      rethrow;
    }
  }

  Future<void> completeTask() async {
    try {
      final result = await db.query(userTableName);

      if (result.isNotEmpty) {
        var userData = UserEntity.fromJson(result.first);
        var updatedUserData = userData.copyWith(
          completedTasks: userData.completedTasks! + 1,
          pendingTasks: userData.pendingTasks != 0 ? userData.pendingTasks! - 1 : 0,
        );
        await db.update(
          userTableName,
          updatedUserData.toJson(),
          where: "$userIdField = ?",
          whereArgs: [userData.id],
        );
      } else {
        print("No user data found to update");
      }
    } catch (e) {
      print("Error completing task: $e");
      rethrow;
    }
  }
}
