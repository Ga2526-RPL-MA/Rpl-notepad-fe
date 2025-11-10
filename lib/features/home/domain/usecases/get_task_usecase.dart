import 'package:rpl_notepad_fe/features/home/domain/repositories/task_repository.dart';

class GetTaskUsecase {
  final TaskRepository repository;

  GetTaskUsecase(this.repository);

  Future<List<Map<String, dynamic>>> execute() async {
    return await repository.getTasks();
  }
}
