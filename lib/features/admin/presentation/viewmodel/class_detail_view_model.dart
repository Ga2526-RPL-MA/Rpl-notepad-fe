import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rpl_notepad_fe/features/admin/domain/usecases/get_all_users_usecase.dart';
import 'package:rpl_notepad_fe/features/admin/domain/usecases/get_users_by_class_usecase.dart';
import 'package:rpl_notepad_fe/features/admin/domain/usecases/add_user_to_class_usecase.dart';
import 'package:rpl_notepad_fe/features/admin/domain/usecases/delete_user_from_class_usecase.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/user_dto.dart';

class ClassDetailViewModel extends ChangeNotifier {
  final GetAllUsersUseCase _getAllUsersUseCase;
  final GetUsersByClassUseCase _getUsersByClassUseCase;
  final AddUserToClassUseCase _addUserToClassUseCase;
  final DeleteUserFromClassUseCase _deleteUserFromClassUseCase;

  ClassDetailViewModel({
    required GetAllUsersUseCase getAllUsersUseCase,
    required GetUsersByClassUseCase getUsersByClassUseCase,
    required AddUserToClassUseCase addUserToClassUseCase,
    required DeleteUserFromClassUseCase deleteUserFromClassUseCase,
  }) : _getAllUsersUseCase = getAllUsersUseCase,
       _getUsersByClassUseCase = getUsersByClassUseCase,
       _addUserToClassUseCase = addUserToClassUseCase,
       _deleteUserFromClassUseCase = deleteUserFromClassUseCase;

  List<UserDto> _users = [];
  List<UserDto> _classStudents = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;
  String _searchQuery = '';

  List<UserDto> get users => _users;
  List<UserDto> get classStudents => _classStudents;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;

  // Filtered students based on search query
  List<UserDto> get filteredStudents {
    if (_searchQuery.isEmpty) {
      return _classStudents;
    }

    final query = _searchQuery.toLowerCase();
    return _classStudents.where((student) {
      final nrp = student.nrp.toLowerCase();
      final name = student.name.toLowerCase();
      return nrp.contains(query) || name.contains(query);
    }).toList();
  }

  bool get isSearching => _searchQuery.isNotEmpty;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  static const String _usersCacheKey = 'cached_all_users';
  static const String _classStudentsCachePrefix = 'cached_class_students_';

  Future<void> _saveUsersToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _users.map((u) => u.toJson()).toList();
      await prefs.setString(_usersCacheKey, jsonEncode(jsonList));
    } catch (e) {
      print('Cache save error: $e');
    }
  }

  Future<void> _loadUsersFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_usersCacheKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _users = jsonList.map((j) => UserDto.fromJson(j)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Cache load error: $e');
    }
  }

  Future<void> _saveClassStudentsToCache(int classId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _classStudents.map((u) => u.toJson()).toList();
      await prefs.setString(
        '${_classStudentsCachePrefix}$classId',
        jsonEncode(jsonList),
      );
    } catch (e) {
      print('Cache class save error: $e');
    }
  }

  Future<void> _loadClassStudentsFromCache(int classId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(
        '${_classStudentsCachePrefix}$classId',
      );
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _classStudents = jsonList.map((j) => UserDto.fromJson(j)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Cache class load error: $e');
    }
  }

  Future<void> fetchUsers() async {
    await _loadUsersFromCache();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _getAllUsersUseCase();
      // Sort by NRP ascending
      _users.sort((a, b) => a.nrp.compareTo(b.nrp));
      _saveUsersToCache();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int? _currentClassId;

  Future<void> fetchClassStudents(int classId) async {
    _currentClassId = classId;

    await _loadClassStudentsFromCache(classId);

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _classStudents = await _getUsersByClassUseCase(classId);
      // Sort by NRP ascending
      _classStudents.sort((a, b) => a.nrp.compareTo(b.nrp));
      _saveClassStudentsToCache(classId);
    } catch (e) {
      print('DEBUG: fetchClassStudents error: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addUserToClass(int userId) async {
    if (_currentClassId == null) return;

    final userToAdd = _users.firstWhere(
      (u) => u.id == userId,
      orElse: () => UserDto(id: userId, name: 'Unknown', nrp: '', email: ''),
    );

    if (!_classStudents.any((u) => u.id == userId)) {
      _classStudents.add(userToAdd);
      notifyListeners();
    }

    try {
      _isProcessing = true;
      notifyListeners();

      await _addUserToClassUseCase(userId, _currentClassId!);
      await fetchClassStudents(_currentClassId!);
    } catch (e) {
      _error = e.toString();
      _classStudents.removeWhere((u) => u.id == userId);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> removeUserFromClass(int userId) async {
    if (_currentClassId == null) return;

    final masterUser = _users.firstWhere(
      (u) => u.id == userId,
      orElse: () => UserDto(id: userId, name: '', nrp: '', email: ''),
    );

    final index = _classStudents.indexWhere((u) {
      if (u.id == userId) return true;
      if (u.id == 0 && u.nrp.isNotEmpty && u.nrp == masterUser.nrp) return true;
      return false;
    });

    UserDto? removedUser;
    if (index != -1) {
      removedUser = _classStudents[index];
      _classStudents.removeAt(index);
      notifyListeners();
    }

    try {
      _isProcessing = true;
      notifyListeners();

      await _deleteUserFromClassUseCase(userId, _currentClassId!);
      if (_currentClassId != null) {
        await fetchClassStudents(_currentClassId!);
      }
    } catch (e) {
      _error = e.toString();
      if (removedUser != null) {
        _classStudents.insert(index, removedUser);
        notifyListeners();
      }
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
