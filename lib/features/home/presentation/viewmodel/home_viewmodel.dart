  import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/home/data/dtos/create_task_dto.dart';
import 'package:rpl_notepad_fe/features/home/data/dtos/get_task_dto.dart';
import 'package:rpl_notepad_fe/features/home/data/repositories/task_repository_impl.dart';
import 'package:rpl_notepad_fe/features/home/domain/repositories/task_repository.dart';
import 'package:rpl_notepad_fe/features/home/domain/entities/task.dart';
import 'package:rpl_notepad_fe/features/home/domain/usecases/delete_task_usecase.dart';
import 'package:rpl_notepad_fe/features/home/domain/usecases/update_task_usecase.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';

class HomeViewModel extends ChangeNotifier {
  String _currentPage = 'beranda';
  String _filter = 'all'; // 'all', 'ongoing', 'completed'
  bool _isLoading = false;
  String? _error;
  final TaskRepository _taskRepository;

    late final UpdateTaskUseCase _updateTaskUseCase;
    late final DeleteTaskUseCase _deleteTaskUseCase;

    HomeViewModel({
      TaskRepository? taskRepository,
      UpdateTaskUseCase? updateTaskUseCase,
      DeleteTaskUseCase? deleteTaskUseCase,
    }) : _taskRepository = taskRepository ?? TaskRepositoryImpl() {
      // Initialize use cases with the repository
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

    List<Task> get tasks {
      if (_filter == 'all') return List.from(_tasks);
      return _tasks.where((task) => task.status == _filter).toList();
    }

    // Fetch tasks from API
    Future<void> fetchTasks() async {
      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        // Get tasks from repository
        final tasksData = await _taskRepository.getTasks();

        // Convert API response to Task entities
        _tasks = tasksData
            .map((taskData) {
              final dto = GetTaskDto.fromJson(taskData);
              return Task(
                id: dto.id,
                title: dto.title,
                description: dto.description,
                dueDate: dto.dueDate != null
                    ? DateTime.parse(dto.dueDate!).toLocal()
                    : null,
                status: dto.status,
                userId: dto.userId,
                classId: dto.classId,
                class_: dto.class_,
                user: dto.user,
              );
            })
            .toList();

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
        // Get the current user ID 
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

        // Use case update task
        await _updateTaskUseCase(taskId, taskDto);

        // Refresh tasks after successful update
        await fetchTasks();
        _error = null;
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
  }
