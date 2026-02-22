import 'package:task_management/domain/entities/task.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final bool hasReachedEnd;

  TaskLoaded({
    required this.tasks,
    required this.hasReachedEnd,
  });
}

class TaskEmpty extends TaskState {}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}