import 'package:task_management/domain/entities/task.dart';

abstract class TaskFormState {
  const TaskFormState();
}


class TaskFormIdle extends TaskFormState {
  final String title;
  final String description;
  final TaskStatus status;

  const TaskFormIdle({
    this.title = '',
    this.description = '',
    this.status = TaskStatus.pending,
  });

  TaskFormIdle copyWith({
    String? title,
    String? description,
    TaskStatus? status,
  }) {
    return TaskFormIdle(
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }
}

class TaskFormSaving extends TaskFormState {
  const TaskFormSaving();
}
class TaskFormSaved extends TaskFormState {
  const TaskFormSaved();
}
class TaskFormError extends TaskFormState {
  final String message;
  const TaskFormError(this.message);
}