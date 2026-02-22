import 'package:task_management/domain/entities/task.dart';

abstract class TaskFormEvent {}

/// Create new task
class CreateTask extends TaskFormEvent {
  final Task task;
  CreateTask(this.task);
}

/// Edit existing task
class UpdateTask extends TaskFormEvent {
  final Task task;
  UpdateTask(this.task);
}