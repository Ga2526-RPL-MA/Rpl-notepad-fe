import 'package:flutter/foundation.dart';
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

  // Getters
  List<Issue> get issues => _filteredIssues;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get showAddForm => _showAddForm;
  bool get hasIssues => _filteredIssues.isNotEmpty;

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

      _issues = await _getIssueUsecase.execute();
      _issues.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
      _filterIssues();

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
}
