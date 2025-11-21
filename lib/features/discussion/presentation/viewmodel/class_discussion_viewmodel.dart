import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rpl_notepad_fe/core/di/injection.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/entities/issue.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/usecases/create_issue_usecase.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/usecases/get_issue_usecase.dart';

class ClassDiscussionViewModel extends ChangeNotifier {
  final GetIssueUsecase _getIssueUsecase = getIt<GetIssueUsecase>();
  final CreateIssueUsecase _createIssueUsecase = getIt<CreateIssueUsecase>();

  List<Issue> _issues = [];
  List<Issue> _filteredIssues = [];
  int? _currentClassId;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showAddForm = false;
  final Map<int, int> _cachedReplyCounts = {};

  // Getters
  List<Issue> get issues => _filteredIssues;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get showAddForm => _showAddForm;
  bool get hasIssues => _filteredIssues.isNotEmpty;
  int? getReplyCount(int issueId) => _cachedReplyCounts[issueId];

  // Set current class ID and filter issues
  void setClassId(int classId) {
    _currentClassId = classId;
    _filterIssues();
  }

  // Filter issues by current class ID
  void _filterIssues() {
    if (_currentClassId == null) return;

    _filteredIssues = _issues
        .where((issue) => issue.classId == _currentClassId)
        .toList();
    notifyListeners();
  }

  // Fetch issues from repository
  Future<void> fetchIssues() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (_currentClassId != null) {
        final cached = await _readCachedIssues(_currentClassId!);
        if (cached.isNotEmpty) {
          _issues = cached;
          _issues.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
          _filterIssues();
        }
      }

      _issues = await _getIssueUsecase.execute();
      _issues.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
      _filterIssues();

      // Local Storage (also persist replyCount)
      if (_currentClassId != null) {
        await _cacheIssues(
          _currentClassId!,
          _issues.where((i) => i.classId == _currentClassId).toList(),
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load discussions. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle add form visibility
  void toggleAddForm() {
    _showAddForm = !_showAddForm;
    notifyListeners();
  }

  // Create new issue
  Future<bool> createIssue(int classId, String content) async {
    if (content.trim().isEmpty) return false;

    try {
      _isLoading = true;
      notifyListeners();

      await _createIssueUsecase(classId: classId, content: content.trim());

      // Refresh the issues list after successful creation
      await fetchIssues();

      _showAddForm = false;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Reset error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ===== Local cache helpers =====
  static String _issuesCacheKey(int classId) =>
      'class_issues_cache_v1_$classId';

  Future<void> _cacheIssues(int classId, List<Issue> issues) async {
    final prefs = await SharedPreferences.getInstance();
    final data = issues
        .map(
          (i) => {
            'id': i.id,
            'userName': i.userName,
            'content': i.content,
            'reportedAt': i.reportedAt.toIso8601String(),
            'classId': i.classId,
            'isAnswer': i.isAnswer,
            // Persist reply count so it survives app restart
            'replyCount': i.answers.fold<int>(
              0,
              (total, a) => total + 1 + a.subAnswers.length,
            ),
          },
        )
        .toList();
    await prefs.setString(_issuesCacheKey(classId), jsonEncode(data));
  }

  Future<List<Issue>> _readCachedIssues(int classId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_issuesCacheKey(classId));
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((m) {
      final mm = Map<String, dynamic>.from(m);
      final id = (mm['id'] as num).toInt();
      final rc = (mm['replyCount'] as num?)?.toInt();
      if (rc != null) {
        _cachedReplyCounts[id] = rc;
      }
      return Issue(
        id: id,
        userName: mm['userName'] as String,
        content: mm['content'] as String,
        reportedAt: DateTime.parse(mm['reportedAt'] as String),
        classId: (mm['classId'] as num).toInt(),
        answers: const [],
        isAnswer: (mm['isAnswer'] as bool?) ?? false,
      );
    }).toList();
  }
}
