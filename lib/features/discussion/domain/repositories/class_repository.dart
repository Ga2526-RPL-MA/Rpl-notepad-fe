
import 'package:rpl_notepad_fe/features/discussion/data/dtos/getclass_dto.dart';

abstract class ClassRepository {
  Future<List<GetClassDto>> getClasses();
}
