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

class ChangeTaskTitle extends TaskFormEvent {
  final String title;
  ChangeTaskTitle(this.title);
}

class ChangeTaskDescription extends TaskFormEvent {
  final String description;
  ChangeTaskDescription(this.description);
}

/// Update form field: status
class ChangeTaskStatus extends TaskFormEvent {
  final TaskStatus status;
  ChangeTaskStatus(this.status);
}

