import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:rpl_notepad_fe/features/home/data/dtos/create_task_dto.dart';
import 'package:rpl_notepad_fe/features/home/data/dtos/get_task_dto.dart';
import 'package:rpl_notepad_fe/features/home/data/repositories/task_repository_impl.dart';
import 'package:rpl_notepad_fe/features/home/domain/repositories/task_repository.dart';
import 'package:rpl_notepad_fe/features/home/domain/entities/task.dart';
import 'package:rpl_notepad_fe/features/home/domain/usecases/delete_task_usecase.dart';
import 'package:rpl_notepad_fe/features/home/domain/usecases/update_task_usecase.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/core/services/notification_service.dart';

class HomeViewModel extends ChangeNotifier {
  String _currentPage = 'beranda';
  String _filter = 'all'; // 'all', 'ongoing', 'completed'
  bool _isLoading = false;
  String? _error;
  final TaskRepository _taskRepository;
  int? _selectedTaskIndex;

  late final UpdateTaskUseCase _updateTaskUseCase;
  late final DeleteTaskUseCase _deleteTaskUseCase;

  HomeViewModel({
    TaskRepository? taskRepository,
    UpdateTaskUseCase? updateTaskUseCase,
    DeleteTaskUseCase? deleteTaskUseCase,
  }) : _taskRepository = taskRepository ?? TaskRepositoryImpl() {
    _updateTaskUseCase =
        updateTaskUseCase ?? UpdateTaskUseCase(_taskRepository);
    _deleteTaskUseCase =
        deleteTaskUseCase ?? DeleteTaskUseCase(_taskRepository);
  }

  List<Task> _tasks = [];

  // Getters
  String get currentPage => _currentPage;
  String get currentFilter => _filter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get selectedTaskIndex => _selectedTaskIndex;

  List<Task> get tasks {
    if (_filter == 'all') return List.from(_tasks);
    return _tasks.where((task) => task.status == _filter).toList();
  }

  // Fetch tasks
  Future<void> fetchTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Local Storage
    try {
      final cached = await _readCachedTasks();
      if (cached.isNotEmpty) {
        _tasks = cached.map((taskData) {
          final dto = GetTaskDto.fromJson(taskData);
          return Task(
            id: dto.id,
            title: dto.title,
            description: dto.description,
            dueDate: dto.dueDate != null ? DateTime.parse(dto.dueDate!) : null,
            status: dto.status,
            userId: dto.userId,
            classId: dto.classId,
            class_: dto.class_,
            user: dto.user,
          );
        }).toList();
        _tasks.sort((a, b) => a.id.compareTo(b.id));
        notifyListeners();
      }
    } catch (_) {}

    try {
      final tasksData = await _taskRepository.getTasks();

      _tasks = tasksData.map((taskData) {
        final dto = GetTaskDto.fromJson(taskData);
        return Task(
          id: dto.id,
          title: dto.title,
          description: dto.description,
          dueDate: dto.dueDate != null ? DateTime.parse(dto.dueDate!) : null,
          status: dto.status,
          userId: dto.userId,
          classId: dto.classId,
          class_: dto.class_,
          user: dto.user,
        );
      }).toList();
      _tasks.sort((a, b) => a.id.compareTo(b.id));

      try {
        await _cacheTasks(tasksData);
      } catch (_) {}

      _error = null;
    } catch (e) {
      _error = 'Gagal memuat tugas. Silakan coba lagi.';
      debugPrint('Error fetching tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Setter for filter
  void setFilter(String filter) {
    if (['all', 'ongoing', 'completed'].contains(filter)) {
      _filter = filter;
      notifyListeners();
    }
  }

  // Setter for selected task
  void selectTask(int? index) {
    _selectedTaskIndex = index;
    notifyListeners();
  }

  // Methods
  void changePage(String page) {
    _currentPage = page;
    notifyListeners();
  }

  Future<void> addTask(
    String title,
    String status,
    DateTime deadline,
    String description, {
    int? classId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = AuthService.userId;
      if (userId == null) {
        _error = 'Pengguna tidak terautentikasi.';
        _isLoading = false;
        notifyListeners();
        return;
      }
      if (classId == null) {
        _error = 'Kelas wajib dipilih.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Create task DTO
      final taskDto = CreateTaskDto(
        title: title,
        description: description.isNotEmpty ? description : null,
        dueDate: deadline,
        status: status,
        classId: classId,
        userId: userId,
      );

      // Repository to create task
      await _taskRepository.createTask(taskDto);

      // Refresh tasks
      await fetchTasks();

      try {
        final created = _tasks.firstWhere(
          (t) =>
              t.title == title &&
              (t.description ?? '') ==
                  (description.isNotEmpty ? description : '') &&
              t.status == status &&
              t.classId == classId &&
              (t.dueDate?.toIso8601String() ==
                  deadline.toLocal().toIso8601String()),
          orElse: () => _tasks.firstWhere(
            (t) =>
                t.title == title &&
                t.classId == classId &&
                (t.dueDate?.difference(deadline.toLocal()).inMinutes.abs() ??
                        9999) <=
                    1,
          ),
        );
        if (created.dueDate != null) {
          await NotificationService.instance.scheduleHMinusOne(
            id: created.id,
            deadline: created.dueDate!,
            title: 'Pengingat Tugas: ${created.title}',
            body:
                'Besok ${DateFormat('dd MMM yyyy HH:mm').format(created.dueDate!)} WIB tenggat ${created.title}.',
            payload: 'task:${created.id}',
          );
        }
      } catch (_) {}
    } catch (e) {
      _error = 'Gagal menambahkan tugas. Silakan coba lagi.';
      debugPrint('Error adding task: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(
    int index,
    String title,
    String status,
    DateTime deadline,
    String description, {
    int? classId,
  }) async {
    if (index < 0 || index >= _tasks.length) return;

    final taskId = _tasks[index].id;
    final DateTime? previousDeadline = _tasks[index].dueDate;
    final bool isDeadlineChanged = previousDeadline == null
        ? true
        : previousDeadline.difference(deadline).inMinutes.abs() != 0;
    _isLoading = true;
    notifyListeners();

    try {
      final userId = AuthService.userId;
      if (userId == null) {
        _error = 'Pengguna tidak terautentikasi.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Create task DTO
      final taskDto = CreateTaskDto(
        title: title,
        description: description.isNotEmpty ? description : null,
        dueDate: deadline,
        status: status,
        classId: classId ?? _tasks[index].classId,
        userId: userId,
      );
      if (status == 'completed' ||
          (isDeadlineChanged && previousDeadline != null)) {
        await NotificationService.instance.cancel(taskId);
      }

      // Use case update task
      await _updateTaskUseCase(taskId, taskDto);

      await fetchTasks();
      _error = null;

      try {
        final updated = _tasks.firstWhere((t) => t.id == taskId);
        if (status != 'completed' &&
            isDeadlineChanged &&
            updated.dueDate != null) {
          await NotificationService.instance.scheduleHMinusOne(
            id: updated.id,
            deadline: updated.dueDate!,
            title: 'Pengingat tugas: ${updated.title}',
            body:
                'Besok ${DateFormat('dd MMM yyyy HH:mm').format(updated.dueDate!)} WIB tenggat ${updated.title}.',
            payload: 'task:${updated.id}',
          );
        }
      } catch (_) {}
    } catch (e) {
      _error = 'Gagal memperbarui tugas. Silakan coba lagi.';
      debugPrint('Error updating task: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(int index) async {
    if (index < 0 || index >= _tasks.length) return;

    final taskId = _tasks[index].id;
    _isLoading = true;
    notifyListeners();

    try {
      await NotificationService.instance.cancel(taskId);
      // Use case delete task
      await _deleteTaskUseCase(taskId);

      // Remove task
      if (index < _tasks.length && _tasks[index].id == taskId) {
        _tasks.removeAt(index);
      }
      _error = null;
    } catch (e) {
      if (e is! DioException || e.response?.statusCode != 404) {
        _error = 'Gagal menghapus tugas. Silakan coba lagi.';
        debugPrint('Error deleting task: $e');
        rethrow;
      }
      if (index < _tasks.length && _tasks[index].id == taskId) {
        _tasks.removeAt(index);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetPage() {
    _currentPage = 'beranda';
    notifyListeners();
  }

  // ===== Local cache helpers =====
  static const _tasksCacheKey = 'home_tasks_cache_v1';

  Future<void> _cacheTasks(List<Map<String, dynamic>> tasksData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tasksCacheKey, jsonEncode(tasksData));
  }

  Future<List<Map<String, dynamic>>> _readCachedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksCacheKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
