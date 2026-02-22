import 'package:task_management/domain/entities/task.dart';
import 'package:task_management/domain/repositories/task_repositories.dart';

class GetTasksUseCase {
  final TaskRepository repo;
  GetTasksUseCase(this.repo);

  Future<List<Task>> call(int page, int size) =>
      repo.getTasks(size, page * size);
}