import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_class_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/usecases/get_class_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/entities/note.dart';
import 'package:rpl_notepad_fe/features/note/domain/entities/week.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/get_notes_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/get_weeks_usecase.dart';

class NoteAdminViewModel extends ChangeNotifier {
  final GetNotesUsecase _getNotesUsecase;
  final GetWeeksUsecase _getWeeksUsecase;
  final GetclassUsecase _getClassesUseCase;

  bool _isLoading = true; // Start with loading true
  bool _isInitialized = false;
  String? _errorMessage;
  List<Note> _allNotes = [];
  List<Note> _filteredNotes = [];
  List<Week> _weeks = [];
  List<GetClassDto> _classes = [];
  GetClassDto? _selectedClass;
  String _searchQuery = '';

  static const String _notesCacheKey = 'cached_admin_notes';
  static const String _classesCacheKey = 'cached_admin_classes';
  static const String _weeksCacheKey = 'cached_admin_weeks';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Note> get notes => _filteredNotes;
  List<GetClassDto> get classes => _classes;
  GetClassDto? get selectedClass => _selectedClass;
  bool get isSearching => _searchQuery.isNotEmpty;

  NoteAdminViewModel({
    required GetNotesUsecase getNotesUsecase,
    required GetWeeksUsecase getWeeksUsecase,
    required GetclassUsecase getClassesUseCase,
  }) : _getNotesUsecase = getNotesUsecase,
       _getWeeksUsecase = getWeeksUsecase,
       _getClassesUseCase = getClassesUseCase;

  Future<void> fetchNotes() async {
    // Show loading on first load
    if (!_isInitialized) {
      _isLoading = true;
      notifyListeners();
    }

    _errorMessage = null;

    try {
      // Load from cache first for quick display
      await _loadFromCache();

      // Fetch all data in parallel from API
      final notesFuture = _getNotesUsecase.execute();
      final weeksFuture = _getWeeksUsecase.execute();
      final classesFuture = _getClassesUseCase.execute();

      final results = await Future.wait([
        notesFuture,
        weeksFuture,
        classesFuture,
      ]);

      _weeks = results[1] as List<Week>;
      _classes = results[2] as List<GetClassDto>;

      // Enrich notes with week numbers
      final fetchedNotes = results[0] as List<Note>;
      _allNotes = fetchedNotes.map((note) {
        // Find the week that matches this note's weekId
        final matchingWeek = _weeks.firstWhere(
          (week) => week.id == note.weekId,
          orElse: () => Week(id: note.weekId, week: note.weekId, classId: 0),
        );

        // Return new Note with weekNumber populated
        return Note(
          id: note.id,
          userName: note.userName,
          content: note.content,
          weekId: note.weekId,
          weekNumber: matchingWeek.week,
          noteFiles: note.noteFiles,
        );
      }).toList();

      // Sort classes by ID
      _classes.sort((a, b) => a.id.compareTo(b.id));

      // Apply filter
      _applyFilter();

      if (kDebugMode) {
        print(
          'Fetched ${_allNotes.length} notes, ${_weeks.length} weeks, ${_classes.length} classes',
        );
      }

      _isLoading = false;
      _isInitialized = true;
      notifyListeners();

      // Save to cache
      await _saveToCache();
    } catch (e) {
      _errorMessage = 'Gagal memuat catatan: $e';
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  void setSelectedClass(GetClassDto? classDto) {
    _selectedClass = classDto;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    List<Note> tempFiltered;

    // First filter by class
    if (_selectedClass == null) {
      tempFiltered = List.from(_allNotes);
    } else {
      // Get week IDs for selected class
      final weekIdsForClass = _weeks
          .where((week) => week.classId == _selectedClass!.id)
          .map((week) => week.id)
          .toSet();

      // Filter notes by week IDs
      tempFiltered = _allNotes
          .where((note) => weekIdsForClass.contains(note.weekId))
          .toList();
    }

    // Then filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      tempFiltered = tempFiltered.where((note) {
        final userName = (note.userName ?? '').toLowerCase();
        final content = (note.content ?? '').toLowerCase();
        return userName.contains(query) || content.contains(query);
      }).toList();
    }

    _filteredNotes = tempFiltered;
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load notes
      final notesCached = prefs.getString(_notesCacheKey);
      if (notesCached != null && notesCached.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(notesCached);
        _allNotes = jsonList
            .map(
              (json) => Note(
                id: json['id'] as int,
                userName: json['userName'] as String?,
                content: json['content'] as String?,
                weekId: json['weekId'] as int,
                weekNumber: json['weekNumber'] != null
                    ? json['weekNumber'] as int
                    : null,
                noteFiles: [],
              ),
            )
            .toList();
        _filteredNotes = List.from(_allNotes);
      }

      // Load classes
      final classesCached = prefs.getString(_classesCacheKey);
      if (classesCached != null && classesCached.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(classesCached);
        _classes = jsonList
            .map(
              (json) => GetClassDto(
                id: json['id'] as int,
                name: json['name'] as String,
                lecturer: json['lecturer'] as String? ?? '',
                timetable: json['timetable'] as String? ?? '',
                room: json['room'] as String? ?? '',
                students: [],
                tasks: [],
              ),
            )
            .toList();
      }

      // Load weeks
      final weeksCached = prefs.getString(_weeksCacheKey);
      if (weeksCached != null && weeksCached.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(weeksCached);
        _weeks = jsonList
            .map(
              (json) => Week(
                id: json['id'] as int,
                week: json['week'] as int,
                classId: json['classId'] as int,
              ),
            )
            .toList();
      }

      _applyFilter();

      // Notify listeners so UI updates with cached data
      if (_allNotes.isNotEmpty || _classes.isNotEmpty) {
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading from cache: $e');
      }
    }
  }

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save notes
      final notesJson = _allNotes
          .map(
            (note) => {
              'id': note.id,
              'userName': note.userName,
              'content': note.content,
              'weekId': note.weekId,
              'weekNumber': note.weekNumber,
            },
          )
          .toList();
      await prefs.setString(_notesCacheKey, jsonEncode(notesJson));

      // Save classes
      final classesJson = _classes
          .map(
            (c) => {
              'id': c.id,
              'name': c.name,
              'lecturer': c.lecturer,
              'timetable': c.timetable,
              'room': c.room,
            },
          )
          .toList();
      await prefs.setString(_classesCacheKey, jsonEncode(classesJson));

      // Save weeks
      final weeksJson = _weeks
          .map((w) => {'id': w.id, 'week': w.week, 'classId': w.classId})
          .toList();
      await prefs.setString(_weeksCacheKey, jsonEncode(weeksJson));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving to cache: $e');
      }
    }
  }
}
