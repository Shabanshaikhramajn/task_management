enum TaskStatus { pending, inProgress ,completed }
enum SyncStatus { synced, pendingSync, failed }
enum FilterOption { all, pending, inProgress, completed }
class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncStatus syncStatus;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });

  Task copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}