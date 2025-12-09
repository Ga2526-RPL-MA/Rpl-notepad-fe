import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rpl_notepad_fe/features/note/domain/entities/week.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/create_week_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/delete_week_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/get_week_by_id_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/get_weeks_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/update_week_usecase.dart';

class WeekViewModel extends ChangeNotifier {
  final GetWeeksUsecase _getWeeksUsecase;
  final GetWeekByIdUsecase _getWeekByIdUsecase;
  final CreateWeekUsecase _createWeekUsecase;
  final UpdateWeekUsecase _updateWeekUsecase;
  final DeleteWeekUsecase _deleteWeekUsecase;

  WeekViewModel({
    required GetWeeksUsecase getWeeksUsecase,
    required GetWeekByIdUsecase getWeekByIdUsecase,
    required CreateWeekUsecase createWeekUsecase,
    required UpdateWeekUsecase updateWeekUsecase,
    required DeleteWeekUsecase deleteWeekUsecase,
  }) : _getWeeksUsecase = getWeeksUsecase,
       _getWeekByIdUsecase = getWeekByIdUsecase,
       _createWeekUsecase = createWeekUsecase,
       _updateWeekUsecase = updateWeekUsecase,
       _deleteWeekUsecase = deleteWeekUsecase;

  List<Week> _weeks = [];
  List<Week> _filteredWeeks = [];
  int? _currentClassId;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showAddForm = false;

  // Getters
  List<Week> get weeks => _filteredWeeks;
  List<Week> get allWeeks => _weeks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get showAddForm => _showAddForm;
  bool get hasWeeks => _filteredWeeks.isNotEmpty;

  // Set current class ID and filter weeks
  void setClassId(int classId) {
    _currentClassId = classId;
    _filterWeeks();
  }

  // Filter weeks by current class ID
  void _filterWeeks() {
    print(
      'WeekViewModel: _filterWeeks() - Total parsed weeks: ${_weeks.length}, Filtering for classId: $_currentClassId',
    );

    if (_weeks.isNotEmpty) {
      print(
        'WeekViewModel: First 5 weeks classIds: ${_weeks.take(5).map((w) => w.classId).toList()}',
      );
    }

    if (_currentClassId == null) {
      _filteredWeeks = _weeks;
    } else {
      _filteredWeeks = _weeks
          .where((week) => week.classId == _currentClassId)
          .toList();
      // Sort by week number
      _filteredWeeks.sort((a, b) => a.week.compareTo(b.week));
    }

    print(
      'WeekViewModel: _filterWeeks() - Filtered result count: ${_filteredWeeks.length}',
    );

    notifyListeners();
  }

  // Fetch weeks from repository
  Future<void> fetchWeeks() async {
    log('fetchWeeks() called', name: 'WeekViewModel');

    if (_isLoading) {
      log('fetchWeeks() - Already loading, skipping', name: 'WeekViewModel');
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Try load cached weeks first
      if (_currentClassId != null) {
        final cached = await _readCachedWeeks(_currentClassId!);
        if (cached.isNotEmpty) {
          _weeks = cached;
          _filterWeeks();
        }
      }

      log(
        'fetchWeeks() - Calling _getWeeksUsecase.execute()',
        name: 'WeekViewModel',
      );
      final startTime = DateTime.now();

      _weeks = await _getWeeksUsecase.execute();

      final endTime = DateTime.now();
      log(
        'fetchWeeks() - Successfully loaded ${_weeks.length} weeks in ${endTime.difference(startTime).inMilliseconds}ms',
        name: 'WeekViewModel',
      );

      _filterWeeks();

      // Cache weeks
      if (_currentClassId != null) {
        await _cacheWeeks(
          _currentClassId!,
          _weeks.where((w) => w.classId == _currentClassId).toList(),
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      log(
        'fetchWeeks() - Error: $e',
        name: 'WeekViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      _errorMessage = 'Failed to load weeks. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch single week by ID
  Future<Week?> fetchWeekById(int weekId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final week = await _getWeekByIdUsecase.execute(weekId);

      _isLoading = false;
      notifyListeners();

      return week;
    } catch (e) {
      log('fetchWeekById() - Error: $e', name: 'WeekViewModel', error: e);
      _errorMessage = 'Failed to load week details. Please try again.';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Toggle add form visibility
  void toggleAddForm() {
    _showAddForm = !_showAddForm;
    notifyListeners();
  }

  // Create new week
  Future<bool> createWeek({required int week, required int classId}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _createWeekUsecase.execute(week: week, classId: classId);

      // Refresh the weeks list after successful creation
      await fetchWeeks();

      _showAddForm = false;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      log('createWeek() - Error: $e', name: 'WeekViewModel', error: e);
      _errorMessage = 'Failed to create week. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update week
  Future<bool> updateWeek({required int weekId, required int week}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _updateWeekUsecase.execute(weekId: weekId, week: week);

      // Refresh the weeks list after successful update
      await fetchWeeks();

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      log('updateWeek() - Error: $e', name: 'WeekViewModel', error: e);
      _errorMessage = 'Failed to update week. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete week
  Future<bool> deleteWeek(int weekId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _deleteWeekUsecase.execute(weekId);

      // Refresh the weeks list after successful deletion
      await fetchWeeks();

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      log('deleteWeek() - Error: $e', name: 'WeekViewModel', error: e);
      _errorMessage = 'Failed to delete week. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reset error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ===== Local cache helpers =====
  static String _weeksCacheKey(int classId) => 'class_weeks_cache_v1_$classId';

  Future<void> _cacheWeeks(int classId, List<Week> weeks) async {
    final prefs = await SharedPreferences.getInstance();
    final data = weeks
        .map((w) => {'id': w.id, 'week': w.week, 'classId': w.classId})
        .toList();
    await prefs.setString(_weeksCacheKey(classId), jsonEncode(data));
  }

  Future<List<Week>> _readCachedWeeks(int classId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_weeksCacheKey(classId));
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((m) {
      final mm = Map<String, dynamic>.from(m);
      return Week(
        id: (mm['id'] as num).toInt(),
        week: (mm['week'] as num).toInt(),
        classId: (mm['classId'] as num).toInt(),
        notes: const [], // Notes not cached for simplicity
      );
    }).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
