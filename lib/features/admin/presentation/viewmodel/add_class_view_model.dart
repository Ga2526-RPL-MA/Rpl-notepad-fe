import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/admin/data/dtos/create_class_dto.dart';
import 'package:rpl_notepad_fe/features/admin/domain/usecases/create_class_usecase.dart';
import 'package:rpl_notepad_fe/features/admin/domain/usecases/update_class_usecase.dart';
import 'package:rpl_notepad_fe/features/admin/domain/usecases/delete_class_usecase.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_class_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/data/repositories/class_repository_impl.dart';

class AddClassViewModel extends ChangeNotifier {
  final nameController = TextEditingController();
  final lecturerController = TextEditingController();
  final roomController = TextEditingController();
  final scheduleController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  String? _initialName;
  String? _initialLecturer;
  String? _initialRoom;
  String? _initialSchedule;

  bool get isLoading => _isLoading;
  String? get error => _error;

  late final CreateClassUseCase _createClassUseCase;
  late final UpdateClassUseCase _updateClassUseCase;
  late final DeleteClassUseCase _deleteClassUseCase;

  AddClassViewModel({
    CreateClassUseCase? createClassUseCase,
    UpdateClassUseCase? updateClassUseCase,
    DeleteClassUseCase? deleteClassUseCase,
  }) {
    final repo = ClassRepositoryImpl();
    _createClassUseCase = createClassUseCase ?? CreateClassUseCase(repo);
    _updateClassUseCase = updateClassUseCase ?? UpdateClassUseCase(repo);
    _deleteClassUseCase = deleteClassUseCase ?? DeleteClassUseCase(repo);
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _error = message;
    notifyListeners();
  }

  void initFrom(GetClassDto? initialClass) {
    if (initialClass == null) return;
    nameController.text = initialClass.name;
    lecturerController.text = initialClass.lecturer;
    roomController.text = initialClass.room;
    scheduleController.text = initialClass.timetable;

    _initialName = initialClass.name;
    _initialLecturer = initialClass.lecturer;
    _initialRoom = initialClass.room;
    _initialSchedule = initialClass.timetable;
  }

  bool get hasChanges {
    if (_initialName == null && _initialLecturer == null && _initialRoom == null && _initialSchedule == null) {
      // create mode, treat as potentially has changes; decision handled by form validation
      return true;
    }
    final name = nameController.text.trim();
    final lecturer = lecturerController.text.trim();
    final room = roomController.text.trim();
    final schedule = scheduleController.text.trim();
    return name != (_initialName ?? '') ||
        lecturer != (_initialLecturer ?? '') ||
        room != (_initialRoom ?? '') ||
        schedule != (_initialSchedule ?? '');
  }

  bool _validateFields() {
    if (nameController.text.trim().isEmpty) {
      setError('Nama kelas tidak boleh kosong');
      return false;
    }
    if (lecturerController.text.trim().isEmpty) {
      setError('Nama pengajar tidak boleh kosong');
      return false;
    }
    if (roomController.text.trim().isEmpty) {
      setError('Ruangan kelas tidak boleh kosong');
      return false;
    }
    if (scheduleController.text.trim().isEmpty) {
      setError('Jadwal kelas tidak boleh kosong');
      return false;
    }
    setError(null);
    return true;
  }

  Future<bool> submit({int? existingClassId}) async {
    if (!_validateFields()) return false;

    setLoading(true);
    try {
      final payload = CreateClassDto(
        name: nameController.text.trim(),
        lecturer: lecturerController.text.trim(),
        room: roomController.text.trim(),
        timetable: scheduleController.text.trim(),
      );

      if (existingClassId != null) {
        await _updateClassUseCase(existingClassId, payload);
      } else {
        await _createClassUseCase.execute(payload);
      }

      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> delete(int classId) async {
    setLoading(true);
    try {
      await _deleteClassUseCase(classId);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  void reset() {
    nameController.clear();
    lecturerController.clear();
    roomController.clear();
    scheduleController.clear();
    setError(null);
    _initialName = null;
    _initialLecturer = null;
    _initialRoom = null;
    _initialSchedule = null;
  }

  @override
  void dispose() {
    nameController.dispose();
    lecturerController.dispose();
    roomController.dispose();
    scheduleController.dispose();
    super.dispose();
  }
}
