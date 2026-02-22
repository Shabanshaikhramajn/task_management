abstract class TaskFormState {}

class TaskFormIdle extends TaskFormState {}

class TaskFormSaving extends TaskFormState {}

class TaskFormSaved extends TaskFormState {}

class TaskFormError extends TaskFormState {
  final String message;
  TaskFormError(this.message);
}