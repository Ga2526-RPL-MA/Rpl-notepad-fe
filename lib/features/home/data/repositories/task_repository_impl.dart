import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:rpl_notepad_fe/core/network/api_endpoint.dart';
import 'package:rpl_notepad_fe/core/network/api_service.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/features/home/data/dtos/create_task_dto.dart';
import 'package:rpl_notepad_fe/features/home/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final ApiService _api;

  TaskRepositoryImpl({ApiService? api}) : _api = api ?? ApiService();

  @override
  Future<List<Map<String, dynamic>>> getTasks() async {
    try {
      final response = await _api.get<List<dynamic>>(
        APIEndpoint.getTask.path,
        options: Options(
          headers: {'Authorization': 'Bearer ${AuthService.token}'},
        ),
      );

      return response.map<Map<String, dynamic>>((task) {
        if (task is Map<String, dynamic>) {
          return task;
        } else if (task is Map) {
          return Map<String, dynamic>.from(task);
        } else {
          throw Exception('Unexpected task format');
        }
      }).toList();
    } catch (e) {
      log('Error in TaskRepositoryImpl.getTasks: $e');
      rethrow;
    }
  }

  @override
  Future<CreateTaskDto> createTask(CreateTaskDto createTask) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        APIEndpoint.createTask.path,
        data: createTask.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer ${AuthService.token}'},
        ),
      );

      return CreateTaskDto.fromJson(response);
    } catch (e) {
      log('Error in TaskRepositoryImpl.createTask: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateTask(
    int taskId,
    CreateTaskDto task,
  ) async {
    try {
      final response = await _api.put<Map<String, dynamic>>(
        '${APIEndpoint.updateTask.path}/$taskId',
        data: task.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer ${AuthService.token}'},
        ),
      );
      return response;
    } catch (e) {
      log('Error in TaskRepositoryImpl.updateTask: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchTasks(String query) async {
    try {
      final response = await _api.get<List<dynamic>>(
        APIEndpoint.searchTask.path,
        queryParams: {'q': query},
        options: Options(
          headers: {'Authorization': 'Bearer ${AuthService.token}'},
        ),
      );

      return response.map<Map<String, dynamic>>((task) {
        if (task is Map<String, dynamic>) {
          return task;
        } else if (task is Map) {
          return Map<String, dynamic>.from(task);
        } else {
          throw Exception('Unexpected task format');
        }
      }).toList();
    } catch (e) {
      log('Error in TaskRepositoryImpl.searchTasks: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(int taskId) async {
    try {
      await _api.delete(
        '${APIEndpoint.deleteTask.path}/$taskId',
        options: Options(
          headers: {'Authorization': 'Bearer ${AuthService.token}'},
          validateStatus: (status) => status! < 400,
        ),
      );

      return;
    } catch (e) {
      if (e.toString().contains('Response kosong dari server') &&
          e.toString().contains('DELETE /tasks/')) {
        return;
      }
      rethrow;
    }
  }
}
