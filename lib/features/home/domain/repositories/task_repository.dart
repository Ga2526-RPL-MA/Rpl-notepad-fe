import 'package:rpl_notepad_fe/features/home/data/dtos/create_task_dto.dart';

abstract class TaskRepository {
  Future<List<Map<String, dynamic>>> getTasks();
  Future<List<Map<String, dynamic>>> searchTasks(String query);
  Future<CreateTaskDto> createTask(CreateTaskDto createTask);
  Future<Map<String, dynamic>> updateTask(int taskId, CreateTaskDto task);
  Future<void> deleteTask(int taskId);
}
