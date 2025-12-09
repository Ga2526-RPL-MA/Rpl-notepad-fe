import 'package:rpl_notepad_fe/features/auth/data/dtos/user_dto.dart';

abstract class AdminRepository {
  Future<List<UserDto>> getAllUsers();
  Future<List<UserDto>> getUsersByClass(int classId);
  Future<void> addUserToClass(int userId, int classId);
  Future<void> deleteUserFromClass(int userId, int classId);
}
