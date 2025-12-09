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

  @override
  Future<List<GetClassDto>> getUserClassesByLoggedIn() async {
    try {
      print('🔍 Calling /userClasses/byloggedin endpoint...');
      final response = await _api.get(
        APIEndpoint.getUserClassesByLoggedIn.path,
      );

      print('🔍 Response type: ${response.runtimeType}');
      print('🔍 Response data: $response');

      if (response == null) {
        print('⚠️ Response is null, returning empty list');
        return [];
      }

      final List<dynamic> data = response as List<dynamic>;
      print('🔍 Parsing ${data.length} items from response');

      final result = <GetClassDto>[];
      for (var i = 0; i < data.length; i++) {
        try {
          print('🔍 Parsing item $i: ${data[i]}');

          // The response has structure: { "class": { ... } }
          // We need to extract the class object
          final item = data[i] as Map<String, dynamic>;
          final classData = item['class'] as Map<String, dynamic>;

          // Create GetClassDto with default values for missing fields
          final classDto = GetClassDto(
            id: classData['id'] ?? 0, // Default to 0 if not provided
            name: classData['name'] as String,
            lecturer: classData['lecturer'] as String,
            timetable: classData['timetable'] as String,
            room: classData['room'] as String,
            students: classData['students'] ?? [], // Default to empty array
            tasks: classData['tasks'] ?? [], // Default to empty array
          );

          result.add(classDto);
          print('✅ Successfully parsed: ${classDto.name}');
        } catch (e) {
          print('❌ Error parsing item $i: $e');
          print('   Data: ${data[i]}');
        }
      }

      return result;
    } catch (e, stackTrace) {
      log('Error in ClassRepositoryImpl.getUserClassesByLoggedIn: $e');
      log('Stack trace: $stackTrace');
      print('❌ Full error: $e');
      print('❌ Stack: $stackTrace');
      rethrow;
    }
  }
}
