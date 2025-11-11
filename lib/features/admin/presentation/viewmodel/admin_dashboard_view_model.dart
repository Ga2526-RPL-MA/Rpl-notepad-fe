import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_class_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/viewmodel/discussion_viewmodel.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  final DiscussionViewModel _discussionVM;
  String _search = '';

  AdminDashboardViewModel({required DiscussionViewModel discussionVM})
      : _discussionVM = discussionVM;

  bool get isLoading => _discussionVM.isLoading;
  String? get error => _discussionVM.error;

  String get search => _search;
  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  // Classes with optional filtering
  List<GetClassDto> get classes {
    final list = _discussionVM.classes;
    if (_search.trim().isEmpty) return list;
    final q = _search.toLowerCase();
    return list.where((c) =>
      c.name.toLowerCase().contains(q) ||
      c.lecturer.toLowerCase().contains(q) ||
      c.room.toLowerCase().contains(q) ||
      c.timetable.toLowerCase().contains(q)
    ).toList();
  }

  Map<String, dynamic> getClassData(GetClassDto classDto, int index) {
    return _discussionVM.getClassData(classDto, index);
  }

  Future<void> init() async {
    if (_discussionVM.classes.isEmpty && !_discussionVM.isLoading) {
      await _discussionVM.loadClasses();
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _discussionVM.loadClasses();
    notifyListeners();
  }
}
