import 'package:rpl_notepad_fe/features/home/domain/repositories/task_repository.dart';
import 'package:rpl_notepad_fe/features/home/data/dtos/create_task_dto.dart';

class UpdateTaskUseCase {
  final TaskRepository _repository;

  UpdateTaskUseCase(this._repository);

  Future<Map<String, dynamic>> call(int taskId, CreateTaskDto task) async {
    return await _repository.updateTask(taskId, task);
  }
}
