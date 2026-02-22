import 'package:task_management/domain/entities/task.dart';
import 'package:task_management/domain/repositories/task_repositories.dart';

class SaveTaskUseCase {
  final TaskRepository repo;
  SaveTaskUseCase(this.repo);

  Future<void> call(Task task) => repo.saveTask(task);
}
