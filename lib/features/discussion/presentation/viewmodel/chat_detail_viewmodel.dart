import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rpl_notepad_fe/core/di/injection.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_answer_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/entities/answer.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/entities/issue.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/entities/sub_answer.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/usecases/add_answer_usecase.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/usecases/add_sub_answer_usecase.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/usecases/get_answers_usecase.dart';

class ChatDetailViewModel extends ChangeNotifier {
  final int issueId;
  final String userName;
  final String message;
  final String className;

  final GetAnswersUsecase _getAnswersUsecase;
  final AddAnswerUsecase _addAnswerUsecase;
  final AddSubAnswerUsecase _addSubAnswerUsecase;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _replyingToName;
  int? _replyingToAnswerId;
  int? _expandedAnswerId;
  List<GetAnswerDto> _answers = [];
  bool _disposed = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get replyingToName => _replyingToName;
  int? get replyingToAnswerId => _replyingToAnswerId;
  int? get expandedAnswerId => _expandedAnswerId;
  List<GetAnswerDto> get answers => _answers;

  ChatDetailViewModel({
    required this.issueId,
    required this.userName,
    required this.message,
    required this.className,
    GetAnswersUsecase? getAnswersUsecase,
    AddAnswerUsecase? addAnswerUsecase,
    AddSubAnswerUsecase? addSubAnswerUsecase,
  }) : _getAnswersUsecase = getAnswersUsecase ?? getIt<GetAnswersUsecase>(),
       _addAnswerUsecase = addAnswerUsecase ?? getIt<AddAnswerUsecase>(),
       _addSubAnswerUsecase =
           addSubAnswerUsecase ?? getIt<AddSubAnswerUsecase>() {
    loadAnswers();
  }

  // Load answers for the current issue
  Future<void> loadAnswers() async {
    _setLoading(true);
    _setError(null);

    try {
      final cached = await _readCachedAnswers(issueId);
      if (cached.isNotEmpty) {
        _setAnswers(cached);
      }

      if (kDebugMode) {
        print('Fetching answers for issueId: $issueId');
      }

      final answers = await _getAnswersUsecase(issueId);

      if (kDebugMode) {
        print('Successfully loaded ${answers.length} answers');
        for (var a in answers) {
          print(
            'Answer ID: ${a.id} | Content: ${a.content} | Sub-answers: ${a.subAnswers.length}',
          );
        }
      }

      _setAnswers(answers);
      // Locak Storage
      try {
        await _cacheAnswers(issueId, answers);
      } catch (_) {}
    } catch (e) {
      print('Error loading answers: $e');
      _setError('Failed to load answers. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  // Handle reply button press
  void handleReplyPressed(String name, int answerId) {
    _replyingToName = name;
    _replyingToAnswerId = answerId;
    _expandedAnswerId = _expandedAnswerId == answerId ? null : answerId;
    notifyListeners();
  }

  // Cancel reply
  void cancelReply() {
    _replyingToName = null;
    _replyingToAnswerId = null;
    notifyListeners();
  }

  Future<void> sendComment(String content) async {
    if (content.trim().isEmpty) return;

    _setSubmitting(true);
    _setError(null);

    try {
      if (_replyingToAnswerId != null) {
        await _addSubAnswerUsecase(
          answerId: _replyingToAnswerId!,
          content: content,
        );
      } else {
        await _addAnswerUsecase(issueId: issueId, content: content);
      }

      await loadAnswers();

      _replyingToName = null;
      _replyingToAnswerId = null;
    } catch (e) {
      print('Error sending comment: $e');
      _setError('Failed to post comment. Please try again.');
    } finally {
      _setSubmitting(false);
    }
  }

  void toggleAnswerExpansion(int answerId) {
    _expandedAnswerId = _expandedAnswerId == answerId ? null : answerId;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_disposed) return;
    _isLoading = value;
    _safeNotify();
  }

  void _setSubmitting(bool value) {
    if (_disposed) return;
    _isSubmitting = value;
    _safeNotify();
  }

  void _setError(String? message) {
    if (_disposed) return;
    _errorMessage = message;
    _safeNotify();
  }

  void _setAnswers(List<GetAnswerDto> answers) {
    if (_disposed) return;
    // Ensure ascending chronological order (oldest first, newest last)
    answers.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _answers = answers;
    _safeNotify();
  }

  Issue getMainIssue() {
    return Issue(
      id: issueId,
      userName: userName,
      content: message,
      reportedAt: DateTime.now(),
      classId: 1,
      answers: _answers
          .map(
            (dto) => Answer(
              id: dto.id,
              content: dto.content,
              userName: dto.userName,
              answeredAt: dto.createdAt,
              issueId: dto.issueId,
              subAnswers: dto.subAnswers
                  .map(
                    (sub) => SubAnswer(
                      id: sub.id,
                      userName: sub.userName,
                      content: sub.content,
                      answeredAt: sub.answeredAt,
                      answerId: sub.answerId,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (_disposed) return;
    try {
      notifyListeners();
    } catch (_) {}
  }

  // ===== Local cache helpers =====
  static String _answersCacheKey(int issueId) =>
      'issue_answers_cache_v1_$issueId';

  Future<void> _cacheAnswers(int issueId, List<GetAnswerDto> answers) async {
    final prefs = await SharedPreferences.getInstance();
    final data = answers.map((a) => a.toJson()).toList();
    await prefs.setString(_answersCacheKey(issueId), jsonEncode(data));
  }

  Future<List<GetAnswerDto>> _readCachedAnswers(int issueId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_answersCacheKey(issueId));
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map(
          (m) => GetAnswerDto.fromJson(
            Map<String, dynamic>.from(m),
            currentIssueId: issueId,
          ),
        )
        .toList();
  }
}
