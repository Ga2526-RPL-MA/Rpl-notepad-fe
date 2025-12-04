import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:rpl_notepad_fe/core/network/api_endpoint.dart';
import 'package:rpl_notepad_fe/core/network/api_service.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/features/admin/data/dtos/create_class_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_class_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/repositories/class_repository.dart';

class ClassRepositoryImpl implements ClassRepository {
  final ApiService _api;

  ClassRepositoryImpl({ApiService? api}) : _api = api ?? ApiService();

  @override
  Future<List<GetClassDto>> getClasses() async {
    try {
      final response = await _api.get(APIEndpoint.getClasses.path);

      final List<dynamic> data = response;

      return data.map((e) => GetClassDto.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CreateClassDto>> createClass(
    CreateClassDto createClassDto,
  ) async {
    try {
      final response = await _api.post(
        APIEndpoint.createClasses.path,
        data: createClassDto.toJson(),
      );

      if (response == null) {
        throw Exception('Empty response from server');
      }

      if (response is Map<String, dynamic>) {
        if (response.containsKey('error')) {
          throw Exception(response['error'] ?? 'Failed to create class');
        }
        return [CreateClassDto.fromJson(response)];
      } else if (response is List) {
        return response
            .map<CreateClassDto>((e) => CreateClassDto.fromJson(e))
            .toList();
      } else if (response is String &&
          response.toLowerCase().contains('success')) {
        return [createClassDto];
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      if (e.toString().contains('500')) {
        throw Exception(
          'Server error: Unable to create class. Please try again later.',
        );
      } else if (e.toString().contains('network')) {
        throw Exception(
          'Network error: Please check your internet connection.',
        );
      } else if (e.toString().contains('timed out')) {
        throw Exception('Request timed out. Please try again.');
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateClass(
    int classId,
    CreateClassDto updateDto,
  ) async {
    try {
      final response = await _api.put(
        '${APIEndpoint.updateClasses.path}/$classId',
        data: updateDto.toJson(),
      );

      if (response == null) {
        throw Exception('Empty response from server');
      }

      if (response is Map<String, dynamic>) {
        return response;
      } else if (response is String &&
          response.toLowerCase().contains('success')) {
        return {'success': true};
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Add this to class_repository_impl.dart
  @override
  Future<List<GetClassDto>> searchClasses(String query) async {
    try {
      final response = await _api.get<List<dynamic>>(
        '${APIEndpoint.searchClass.path}?q=$query',
        options: Options(
          headers: {'Authorization': 'Bearer ${AuthService.token}'},
        ),
      );

      return response
          .map<GetClassDto>((json) => GetClassDto.fromJson(json))
          .toList();
    } catch (e) {
      log('Error in ClassRepositoryImpl.searchClasses: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteClass(int classId) async {
    try {
      await _api.delete('${APIEndpoint.deleteClasses.path}/$classId');
    } catch (e) {
      rethrow;
    }
  }
}
