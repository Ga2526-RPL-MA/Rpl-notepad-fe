import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  String _currentPage = 'beranda';
  final List<Map<String, dynamic>> _tugas = [
    {
      'title': 'Tugas 1',
      'status': 'in_progress',
      'deadline': DateTime.now().add(const Duration(days: 2)),
      'description': 'Ini adalah contoh tugas yang sedang berjalan',
    },
    {
      'title': 'Tugas 2',
      'status': 'pending',
      'deadline': DateTime.now().add(const Duration(days: 5)),
      'description': 'Ini adalah contoh tugas yang belum dimulai',
    },
    {
      'title': 'Tugas 3',
      'status': 'completed',
      'deadline': DateTime.now().subtract(const Duration(days: 2)),
      'description': 'Ini adalah contoh tugas yang sudah selesai',
    },
  ];

  // Getter
  String get currentPage => _currentPage;
  List<Map<String, dynamic>> get tugas => _tugas;

  // Methods
  void changePage(String page) {
    _currentPage = page;
    notifyListeners();
  }

  void addTask(
    String title,
    String status,
    DateTime deadline,
    String description,
  ) {
    _tugas.add({
      'title': title,
      'status': status,
      'deadline': deadline,
      'description': description,
    });
    notifyListeners();
  }

  void updateTask(
    int index,
    String title,
    String status,
    DateTime deadline,
    String description,
  ) {
    if (index < _tugas.length) {
      _tugas[index] = {
        'title': title,
        'status': status,
        'deadline': deadline,
        'description': description,
      };
      notifyListeners();
    }
  }

  void deleteTask(int index) {
    if (index < _tugas.length) {
      _tugas.removeAt(index);
      notifyListeners();
    }
  }

  void resetPage() {
    _currentPage = 'beranda';
    notifyListeners();
  }
}
