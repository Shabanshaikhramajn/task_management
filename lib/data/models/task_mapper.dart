import 'package:task_management/data/models/task_hive_model.dart';
import 'package:task_management/domain/entities/task.dart';

extension TaskMapper on TaskHiveModel {
  Task toEntity() => Task(
    id: id,
    title: title,
    description: description,
    status: TaskStatus.values[status],
    createdAt: createdAt,
    updatedAt: updatedAt,
    syncStatus: SyncStatus.values[syncStatus],
  );
}

extension TaskEntityMapper on Task {
  TaskHiveModel toHive() => TaskHiveModel()
    ..id = id
    ..title = title
    ..description = description
    ..status = status.index
    ..createdAt = createdAt
    ..updatedAt = updatedAt
    ..syncStatus = syncStatus.index;
}
