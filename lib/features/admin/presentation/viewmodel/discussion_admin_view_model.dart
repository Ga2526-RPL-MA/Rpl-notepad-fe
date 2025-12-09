import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/admin/domain/usecases/get_all_users_usecase.dart';
import 'package:rpl_notepad_fe/features/admin/domain/usecases/get_issues_usecase.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/user_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_issue_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/entities/issue.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscussionAdminViewModel extends ChangeNotifier {
  final GetIssuesUseCase _getIssuesUseCase;
  final GetAllUsersUseCase _getAllUsersUseCase;

  static const String _issuesCacheKey = 'cached_issues';

  List<Issue> _issues = [];
  bool _isLoading = false;
  String? _error;

  DiscussionAdminViewModel({
    required GetIssuesUseCase getIssuesUseCase,
    required GetAllUsersUseCase getAllUsersUseCase,
  })  : _getIssuesUseCase = getIssuesUseCase,
        _getAllUsersUseCase = getAllUsersUseCase;

  List<Issue> get issues => _issues;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadIssuesFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_issuesCacheKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _issues = jsonList.map((j) => GetIssueDto.fromJson(j).toEntity()).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Cache load error: $e');
    }
  }

  Future<void> _saveIssuesToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _issues.map((issue) => GetIssueDto.fromEntity(issue).toJson()).toList();
      await prefs.setString(_issuesCacheKey, jsonEncode(jsonList));
    } catch (e) {
      print('Cache save error: $e');
    }
  }

  Future<void> fetchIssues() async {
    await _loadIssuesFromCache();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final issues = await _getIssuesUseCase();
      final users = await _getAllUsersUseCase();

      _issues = issues.map((issue) {
        final user = users.firstWhere(
          (u) => u.name == issue.userName,
          orElse: () => UserDto(
            id: 0,
            name: '',
            email: '',
            nrp: 'N/A', // Default or empty
            role: '',
          ),
        );
        return issue.copyWith(nrp: user.nrp);
      }).toList();
      
      await _saveIssuesToCache();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
