import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_class_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/repositories/class_repository.dart';

class GetclassUsecase {
  final ClassRepository repository;

  GetclassUsecase(this.repository);

  Future<List<GetClassDto>> execute() async {
    return await repository.getClasses();
  }

  Future<List<GetClassDto>> searchClasses(String query) async {
    return await repository.searchClasses(query);
  }

  Future<List<GetClassDto>> getUserClassesByLoggedIn() async {
    return await repository.getUserClassesByLoggedIn();
  }
}
