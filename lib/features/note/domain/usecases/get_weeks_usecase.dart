import 'package:rpl_notepad_fe/features/note/domain/entities/week.dart';
import 'package:rpl_notepad_fe/features/note/domain/repositories/week_repository.dart';

class GetWeeksUsecase {
  final WeekRepository repository;

  GetWeeksUsecase(this.repository);

  Future<List<Week>> execute() async {
    final weeksDto = await repository.getWeeks();
    return weeksDto.map((dto) => dto.toEntity()).toList();
  }
}
