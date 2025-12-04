import 'package:rpl_notepad_fe/features/admin/data/dtos/create_class_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_class_dto.dart';

abstract class ClassRepository {
  Future<List<GetClassDto>> getClasses();
  Future<List<CreateClassDto>> createClass(CreateClassDto createClassDto);
  Future<Map<String, dynamic>> updateClass(
    int classId,
    CreateClassDto updateDto,
  );
  Future<void> deleteClass(int classId);
  Future<List<GetClassDto>> searchClasses(String query);
}
