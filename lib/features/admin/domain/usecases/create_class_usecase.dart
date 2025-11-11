import 'package:rpl_notepad_fe/features/admin/data/dtos/create_class_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/repositories/class_repository.dart';

class CreateClassUseCase {
  final ClassRepository repository;

  CreateClassUseCase(this.repository);

  Future<void> execute(CreateClassDto createClassDto) async {
    await repository.createClass(createClassDto);
  }
  
}