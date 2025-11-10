import 'package:rpl_notepad_fe/features/home/data/dtos/create_task_dto.dart';
import 'package:rpl_notepad_fe/features/home/domain/repositories/task_repository.dart';

class CreateTaskUsecase {
  final TaskRepository repository;

  CreateTaskUsecase(this.repository);

  Future<CreateTaskDto> execute(CreateTaskDto createTaskDto) async {
    return await repository.createTask(createTaskDto);
  }
}
