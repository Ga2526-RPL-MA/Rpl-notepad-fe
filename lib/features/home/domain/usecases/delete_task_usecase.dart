import 'package:rpl_notepad_fe/features/home/domain/repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository _repository;

  DeleteTaskUseCase(this._repository);

  Future<void> call(int taskId) async {
    await _repository.deleteTask(taskId);
  }
}
