import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/getclass_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/usecases/getclass_usecase.dart';

class DiscussionViewModel extends ChangeNotifier {
  final GetclassUsecase _getClassesUsecase;

  DiscussionViewModel({required GetclassUsecase usecase}) : _getClassesUsecase = usecase;

  List<GetClassDto> _classes = [];
  bool _isLoading = false;
  String? _error;

  List<GetClassDto> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadClasses() async {
    log('loadClasses() called', name: 'DiscussionViewModel');
    
    if (_isLoading) {
      log('loadClasses() - Already loading, skipping', name: 'DiscussionViewModel');
      return;
    }
    
    _isLoading = true;
    _error = null;
    log('loadClasses() - Setting loading to true', name: 'DiscussionViewModel');
    notifyListeners();

    try {
      log('loadClasses() - Calling _getClassesUsecase.execute()', name: 'DiscussionViewModel');
      final startTime = DateTime.now();
      
      _classes = await _getClassesUsecase.execute();
      
      final endTime = DateTime.now();
      log('loadClasses() - Successfully loaded ${_classes.length} classes in ${endTime.difference(startTime).inMilliseconds}ms', 
          name: 'DiscussionViewModel');
    } catch (e, stackTrace) {
      log('loadClasses() - Error: $e', 
          name: 'DiscussionViewModel', 
          error: e, 
          stackTrace: stackTrace);
      _error = 'Gagal memuat data kelas: $e';
    } finally {
      _isLoading = false;
      log('loadClasses() - Setting loading to false', name: 'DiscussionViewModel');
      notifyListeners();
    }
  }

  Map<String, dynamic> getClassData(GetClassDto classDto, int index) {
    final isGreenTheme = index.isEven;
    return {
      'iconPath': 'assets/icons/star_icon.png',
      'className': classDto.name,
      'classTime': _formatTime(classDto.timetable),
      'classRoom': classDto.room,
      'cardBackgroundColor':
          isGreenTheme ? const Color(0xFFECF8EF) : const Color(0xFFE6F4FF),
      'cardOutlineColor':
          isGreenTheme ? const Color(0xFF43B75D) : const Color(0xFF0095FF),
    };
  }

  String _formatTime(DateTime dateTime) {
    final startHour = dateTime.hour.toString().padLeft(2, '0');
    final startMinute = dateTime.minute.toString().padLeft(2, '0');
    final endHour = (dateTime.hour + 2).toString().padLeft(2, '0');
    return '$startHour:$startMinute - $endHour:$startMinute';
  }
}
