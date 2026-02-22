import 'package:task_management/domain/entities/task.dart';

abstract class TaskLocalDataSource {
  Future<void> upsertTask(Task task);
  Future<List<Task>> fetchTasks(int limit, int offset);
  Future<List<Task>> fetchPendingSyncTasks();
}