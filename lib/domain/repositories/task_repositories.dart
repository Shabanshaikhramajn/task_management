import 'package:task_management/domain/entities/task.dart';

abstract class TaskRepository {
  Stream<List<Task>> watchTasks();
  Future<void> saveTask(Task task);
  Future<List<Task>> getTasks(int limit, int offset);
  Future<List<Task>> getPendingSyncTasks();
}
