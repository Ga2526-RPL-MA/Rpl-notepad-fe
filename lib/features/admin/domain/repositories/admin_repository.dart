import 'package:rpl_notepad_fe/features/auth/data/dtos/user_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/entities/issue.dart';

abstract class AdminRepository {
  Future<List<UserDto>> getAllUsers();
  Future<List<UserDto>> getUsersByClass(int classId);
  Future<void> addUserToClass(int userId, int classId);
  Future<void> deleteUserFromClass(int userId, int classId);
  Future<List<Issue>> getIssues();
  Future<void> deleteIssue(int issueId);
  Future<void> deleteAnswer(int answerId);
  Future<void> deleteSubAnswer(int subAnswerId);
}
