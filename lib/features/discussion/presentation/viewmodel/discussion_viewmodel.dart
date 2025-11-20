import 'dart:developer';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_class_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/usecases/get_class_usecase.dart';

class DiscussionViewModel extends ChangeNotifier {
  final GetclassUsecase _getClassesUsecase;

  DiscussionViewModel({required GetclassUsecase usecase})
    : _getClassesUsecase = usecase;

  List<GetClassDto> _classes = [];
  bool _isLoading = false;
  String? _error;

  List<GetClassDto> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadClasses() async {
    log('loadClasses() called', name: 'DiscussionViewModel');

    if (_isLoading) {
      log(
        'loadClasses() - Already loading, skipping',
        name: 'DiscussionViewModel',
      );
      return;
    }

    _isLoading = true;
    _error = null;
    log('loadClasses() - Setting loading to true', name: 'DiscussionViewModel');

    // Try load cached classes first so UI is not empty
    try {
      final cached = await _readCachedClasses();
      if (cached.isNotEmpty) {
        _classes = cached;
        _classes.sort((a, b) {
          final ka = _timetableSortKey(a.timetable);
          final kb = _timetableSortKey(b.timetable);
          return ka.compareTo(kb);
        });
        notifyListeners();
      }
    } catch (_) {}

    notifyListeners();

    try {
      log(
        'loadClasses() - Calling _getClassesUsecase.execute()',
        name: 'DiscussionViewModel',
      );
      final startTime = DateTime.now();

      _classes = await _getClassesUsecase.execute();

      _classes.sort((a, b) {
        final ka = _timetableSortKey(a.timetable);
        final kb = _timetableSortKey(b.timetable);
        return ka.compareTo(kb);
      });

      final endTime = DateTime.now();
      log(
        'loadClasses() - Successfully loaded ${_classes.length} classes in ${endTime.difference(startTime).inMilliseconds}ms',
        name: 'DiscussionViewModel',
      );
      // Local Storage
      try {
        await _cacheClasses(_classes);
      } catch (_) {}
    } catch (e, stackTrace) {
      log(
        'loadClasses() - Error: $e',
        name: 'DiscussionViewModel',
        error: e,
        stackTrace: stackTrace,
      );

      if (_isNetworkIssue(e)) {
        _error = null;
      } else {
        _error = 'Gagal memuat data kelas: $e';
      }
    } finally {
      _isLoading = false;
      log(
        'loadClasses() - Setting loading to false',
        name: 'DiscussionViewModel',
      );
      notifyListeners();
    }
  }

  // Cache helpers
  static const _classesCacheKey = 'discussion_classes_cache_v1';

  Future<void> _cacheClasses(List<GetClassDto> classes) async {
    final prefs = await SharedPreferences.getInstance();
    final data = classes
        .map(
          (c) => {
            'id': c.id,
            'name': c.name,
            'lecturer': c.lecturer,
            'timetable': c.timetable,
            'room': c.room,
            'students': c.students,
            'tasks': c.tasks,
          },
        )
        .toList();
    await prefs.setString(_classesCacheKey, jsonEncode(data));
  }

  Future<List<GetClassDto>> _readCachedClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_classesCacheKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((m) => GetClassDto.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  bool _isNetworkIssue(Object e) {
    if (e is DioException) {
      return e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          (e.error?.toString().contains('SocketException') ?? false);
    }
    // Also honor the sentinel from ApiService
    return e.toString().contains('no_internet');
  }

  Map<String, dynamic> getClassData(GetClassDto classDto, int index) {
    final isGreenTheme = index.isEven;
    return {
      'iconPath': 'assets/icon/star_icon.png',
      'className': classDto.name,
      'classTime': classDto.timetable,
      'classRoom': classDto.room,
      'cardBackgroundColor': isGreenTheme
          ? const Color(0xFFECF8EF)
          : const Color(0xFFE6F4FF),
      'cardOutlineColor': isGreenTheme
          ? const Color(0xFF43B75D)
          : const Color(0xFF0095FF),
    };
  }

  int _timetableSortKey(String value) {
    final dayMap = {
      'Senin': 1,
      'Selasa': 2,
      'Rabu': 3,
      'Kamis': 4,
      'Jumat': 5,
      'Sabtu': 6,
      'Minggu': 7,
    };

    final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    final parts = normalized.split(' ');
    if (parts.isNotEmpty) {
      final day = dayMap[parts[0]] ?? 0;
      final match = RegExp(r'(\d{1,2})[\.:](\d{2})').firstMatch(value);
      if (match != null) {
        final h = int.tryParse(match.group(1) ?? '') ?? 0;
        final m = int.tryParse(match.group(2) ?? '') ?? 0;
        return day * 24 * 60 + h * 60 + m;
      }
    }
    return 1 << 30;
  }
}
