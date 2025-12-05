import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rpl_notepad_fe/features/note/domain/entities/note.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/create_note_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/create_note_files_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/delete_note_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/get_notes_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/update_note_usecase.dart';

class NoteViewModel extends ChangeNotifier {
  final GetNotesUsecase _getNotesUsecase;
  final CreateNoteUsecase _createNoteUsecase;
  final CreateNoteFilesUsecase _createNoteFilesUsecase;
  final UpdateNoteUsecase _updateNoteUsecase;
  final DeleteNoteUsecase _deleteNoteUsecase;

  NoteViewModel({
    required GetNotesUsecase getNotesUsecase,
    required CreateNoteUsecase createNoteUsecase,
    required UpdateNoteUsecase updateNoteUsecase,
    required DeleteNoteUsecase deleteNoteUsecase,
    required CreateNoteFilesUsecase createNoteFilesUsecase,
  }) : _getNotesUsecase = getNotesUsecase,
       _createNoteUsecase = createNoteUsecase,
       _updateNoteUsecase = updateNoteUsecase,
       _deleteNoteUsecase = deleteNoteUsecase,
       _createNoteFilesUsecase = createNoteFilesUsecase;

  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  int? _currentWeekId;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showAddForm = false;

  // Getters
  List<Note> get notes => _filteredNotes;
  List<Note> get allNotes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get showAddForm => _showAddForm;
  bool get hasNotes => _filteredNotes.isNotEmpty;

  // Set current week ID and filter notes (null means no filter / all)
  void setWeekId(int? weekId) {
    _currentWeekId = weekId;
    _filterNotes();
  }

  // Filter notes by current week ID
  void _filterNotes() {
    if (_currentWeekId == null) {
      _filteredNotes = _notes;
    } else {
      _filteredNotes = _notes
          .where((note) => note.weekId == _currentWeekId)
          .toList();
    }
    notifyListeners();
  }

  // Search notes
  Future<void> searchNotes(String query) async {
    if (query.isEmpty) {
      _filterNotes();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _filteredNotes = await _getNotesUsecase.search(query);

      if (_filteredNotes.isEmpty) {
        _filteredNotes = _notes
            .where(
              (note) =>
                  (note.content?.toLowerCase().contains(query.toLowerCase()) ??
                  false),
            )
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      log(
        'searchNotes() - Error: $e',
        name: 'NoteViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      _errorMessage = 'Failed to search notes. Please try again.';
      _isLoading = false;
      _filterNotes(); // Revert to original notes on error
      notifyListeners();
    }
  }

  // Fetch notes from repository
  Future<void> fetchNotes() async {
    log('fetchNotes() called', name: 'NoteViewModel');

    if (_isLoading) {
      log('fetchNotes() - Already loading, skipping', name: 'NoteViewModel');
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Try load cached notes first
      if (_currentWeekId != null) {
        final cached = await _readCachedNotes(_currentWeekId!);
        if (cached.isNotEmpty) {
          _notes = cached;
          _filterNotes();
        }
      }

      log(
        'fetchNotes() - Calling _getNotesUsecase.execute()',
        name: 'NoteViewModel',
      );
      final startTime = DateTime.now();

      _notes = await _getNotesUsecase.execute();

      final endTime = DateTime.now();
      log(
        'fetchNotes() - Successfully loaded ${_notes.length} notes in ${endTime.difference(startTime).inMilliseconds}ms',
        name: 'NoteViewModel',
      );

      _filterNotes();

      // Cache notes
      if (_currentWeekId != null) {
        await _cacheNotes(
          _currentWeekId!,
          _notes.where((n) => n.weekId == _currentWeekId).toList(),
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      log(
        'fetchNotes() - Error: $e',
        name: 'NoteViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      _errorMessage = 'Failed to load notes. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle add form visibility
  void toggleAddForm() {
    _showAddForm = !_showAddForm;
    notifyListeners();
  }

  // Create new note
  Future<bool> createNote({
    required int weekId,
    String? content,
    List<PlatformFile> selectedFiles = const [],
  }) async {
    // Allow: text only OR file only; block only when both are empty
    if ((content?.trim().isEmpty ?? true) && selectedFiles.isEmpty)
      return false;

    try {
      _isLoading = true;
      notifyListeners();

      final created = await _createNoteUsecase.execute(
        weekId: weekId,
        content: content?.trim(),
      );

      if (selectedFiles.isNotEmpty) {
        try {
          await _createNoteFilesUsecase.execute(
            noteId: created.id,
            files: selectedFiles,
          );
        } catch (e) {
          log(
            'createNote() - Upload files failed: $e',
            name: 'NoteViewModel',
            error: e,
          );
        }
      }

      // Refresh the notes list after successful creation
      await fetchNotes();

      _showAddForm = false;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      log('createNote() - Error: $e', name: 'NoteViewModel', error: e);
      _errorMessage = 'Failed to create note. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update note
  Future<bool> updateNote({required int noteId, String? content}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _updateNoteUsecase.execute(noteId: noteId, content: content);

      // Refresh the notes list after successful update
      await fetchNotes();

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      log('updateNote() - Error: $e', name: 'NoteViewModel', error: e);
      _errorMessage = 'Failed to update note. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete note
  Future<bool> deleteNote(int noteId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _deleteNoteUsecase.execute(noteId);

      // Refresh the notes list after successful deletion
      await fetchNotes();

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      log('deleteNote() - Error: $e', name: 'NoteViewModel', error: e);
      _errorMessage = 'Failed to delete note. Please try again.';
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
  static String _notesCacheKey(int weekId) => 'week_notes_cache_v1_$weekId';

  Future<void> _cacheNotes(int weekId, List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final data = notes
        .map(
          (n) => {
            'id': n.id,
            'userName': n.userName,
            'content': n.content,
            'weekId': n.weekId,
            'noteFiles': n.noteFiles
                .map(
                  (f) => {
                    'id': f.id,
                    'filePath': f.filePath,
                    'noteId': f.noteId,
                  },
                )
                .toList(),
          },
        )
        .toList();
    await prefs.setString(_notesCacheKey(weekId), jsonEncode(data));
  }

  Future<List<Note>> _readCachedNotes(int weekId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notesCacheKey(weekId));
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((m) {
      final mm = Map<String, dynamic>.from(m);
      return Note(
        id: (mm['id'] as num).toInt(),
        userName: mm['userName'] as String?,
        content: mm['content'] as String?,
        weekId: (mm['weekId'] as num).toInt(),
        noteFiles: [], // Files not cached for simplicity
      );
    }).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
