import 'package:task_management/domain/entities/task.dart';

abstract class TaskEvent {}

/// Initial load or pull-to-refresh
class LoadTasks extends TaskEvent {}

/// Pagination
class LoadNextPage extends TaskEvent {}


class StartWatchingTasks extends TaskEvent {}

/// Search with debounce
class SearchTasks extends TaskEvent {
  final String query;
  SearchTasks(this.query);
}

/// Filter by status
class FilterTasks extends TaskEvent {
  final TaskStatus? status;
  FilterTasks(this.status);
}

class TasksUpdated extends TaskEvent {
  final List<Task> tasks;
  TasksUpdated(this.tasks);
}