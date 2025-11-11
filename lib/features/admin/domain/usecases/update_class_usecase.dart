import 'package:rpl_notepad_fe/features/admin/data/dtos/create_class_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/repositories/class_repository.dart';

class UpdateClassUseCase {
  final ClassRepository _repository;

  UpdateClassUseCase(this._repository);

  Future<Map<String, dynamic>> call(int classId, CreateClassDto dto) async {
    return await _repository.updateClass(classId, dto);
  }
}
