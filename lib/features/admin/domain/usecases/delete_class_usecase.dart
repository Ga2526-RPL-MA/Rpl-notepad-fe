import 'package:rpl_notepad_fe/features/discussion/domain/repositories/class_repository.dart';

class DeleteClassUseCase {
  final ClassRepository _repository;

  DeleteClassUseCase(this._repository);

  Future<void> call(int classId) async {
    await _repository.deleteClass(classId);
  }
}