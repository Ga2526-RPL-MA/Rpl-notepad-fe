// dashboard_viewmodel.dart
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  String _currentPage = 'beranda';
  String _filter = 'all'; // 'all', 'ongoing', 'completed'
  final List<Map<String, dynamic>> _tugas = [
    {
      'title': 'Tugas 1', 
      'status': 'ongoing',
      'deadline': DateTime.now().add(const Duration(days: 2)),
      'description': 'Membuat laporan mingguan',
    },
    {
      'title': 'Tugas 3', 
      'status': 'completed',
      'deadline': DateTime.now().subtract(const Duration(days: 2)),
      'description': 'Ini adalah contoh tugas yang sudah selesai',
    },
  ];

  // Getters
  String get currentPage => _currentPage;
  String get currentFilter => _filter;
  
  List<Map<String, dynamic>> get tugas {
    if (_filter == 'all') return List.from(_tugas);
    return _tugas.where((task) => task['status'] == _filter).toList();
  }
  
  // Setter for filter
  void setFilter(String filter) {
    if (['all', 'ongoing', 'completed'].contains(filter)) {
      _filter = filter;
      notifyListeners();
    }
  }

  // Methods
  void changePage(String page) {
    _currentPage = page;
    notifyListeners();
  }

  void addTask(String title, String status, DateTime deadline, String description) {
    _tugas.add({
      'title': title, 
      'status': status,
      'deadline': deadline,
      'description': description,
    });
    notifyListeners();
  }

  void updateTask(int index, String title, String status, DateTime deadline, String description) {
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
