import 'package:task_management/data/datasource/local/task_local_datasource.dart';
import 'package:task_management/domain/entities/task.dart';
import 'package:task_management/domain/repositories/task_repositories.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource local;

  TaskRepositoryImpl(this.local);

  @override
  Future<void> saveTask(Task task) => local.upsertTask(task);

  @override
  Future<List<Task>> getTasks(int limit, int offset) =>
      local.fetchTasks(limit, offset);

  @override
  Future<List<Task>> getPendingSyncTasks() =>
      local.fetchPendingSyncTasks();
}