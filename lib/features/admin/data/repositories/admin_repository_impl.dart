import 'package:dio/dio.dart';
import 'package:rpl_notepad_fe/core/network/api_endpoint.dart';
import 'package:rpl_notepad_fe/core/network/api_service.dart';
import 'package:rpl_notepad_fe/features/admin/domain/repositories/admin_repository.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/user_dto.dart';

class AdminRepositoryImpl implements AdminRepository {
  final ApiService _api;

  AdminRepositoryImpl({ApiService? api}) : _api = api ?? ApiService();

  @override
  Future<List<UserDto>> getAllUsers() async {
    try {
      final response = await _api.get<List<dynamic>>(
        APIEndpoint.getAllUsers.path,
      );

      return response.map((json) => UserDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw e.message ?? 'Terjadi kesalahan saat mengambil data pengguna';
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> addUserToClass(int userId, int classId) async {
    try {
      print('DEBUG: sending POST to ${APIEndpoint.addUserClass.path} with userId=$userId, classId=$classId');
      final response = await _api.post(
        APIEndpoint.addUserClass.path,
        data: {
          'userId': userId,
          'classId': classId,
        },
      );
      print('DEBUG: addUserToClass response: $response');
    } catch (e) {
      print('DEBUG: addUserToClass error: $e');
      throw e.toString();
    }
  }

  @override
  Future<void> deleteUserFromClass(int userId, int classId) async {
    try {
      print('DEBUG: sending DELETE to ${APIEndpoint.deleteUserClass.path}/$userId/$classId');
      final response = await _api.delete(
        '${APIEndpoint.deleteUserClass.path}/$userId/$classId',
      );
      print('DEBUG: deleteUserFromClass response: $response');
    } catch (e) {
      print('DEBUG: deleteUserFromClass error: $e');
      throw e.toString();
    }
  }

  @override
  Future<List<UserDto>> getUsersByClass(int classId) async {
    try {
      print('Fetching users for classId: $classId at ${APIEndpoint.getUsersByClass.path}/$classId');
      final response = await _api.get<dynamic>(
        "${APIEndpoint.getUsersByClass.path}/$classId",
      );
      print('DEBUG: getUsersByClass response raw: $response');
      print('Response type: ${response.runtimeType}');
      if (response is List) {
         return response.map((json) {
          if (json is Map<String, dynamic> && json.containsKey('user')) {
             return UserDto.fromJson(json['user']);
          }
          return UserDto.fromJson(json);
        }).toList();
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('user')) {
           return [UserDto.fromJson(response['user'])];
        } else if (response.containsKey('data') && response['data'] is List) {
           return (response['data'] as List).map((json) {
            if (json is Map<String, dynamic> && json.containsKey('user')) {
               return UserDto.fromJson(json['user']);
            }
            return UserDto.fromJson(json);
           }).toList();
        }
        try {
          return [UserDto.fromJson(response)];
        } catch (_) {}
      }
      return [];
    } on DioException catch (e) {
      print('DioException in getUsersByClass: ${e.message}');
      print('DioException response: ${e.response?.data}');
      throw e.message ?? 'Terjadi kesalahan saat mengambil data pengguna kelas';
    } catch (e) {
      print('Exception in getUsersByClass: $e');
      if (e.toString().contains('Response kosong')) {
        print('DEBUG: Caught "Response kosong", returning empty list.');
        return [];
      }
      throw e.toString();
    }
  }
}
