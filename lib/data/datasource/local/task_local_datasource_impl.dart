import 'package:hive/hive.dart';
import 'package:task_management/data/datasource/local/task_local_datasource.dart';
import 'package:task_management/data/models/task_hive_model.dart';
import 'package:task_management/data/models/task_mapper.dart';
import 'package:task_management/domain/entities/task.dart';

class TaskLocalDatasourceImpl implements TaskLocalDataSource {
  final Box<TaskHiveModel> box;

  TaskLocalDatasourceImpl(this.box);

  // ----------------------------------------------------------------------
  @override
  Future<void> upsertTask(Task task) async {
    await box.put(task.id, task.toHive());
  }

  // ----------------------------------------------------------------------
  @override
  Future<List<Task>> fetchAllTasks(int limit, int offset) async {
    final tasks = box.values.map((e) => e.toEntity()).toList();

    tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return tasks.skip(offset).take(limit).toList();
  }

  // ----------------------------------------------------------------------
  @override
  Future<List<Task>> fetchPendingSyncTasks() async {
    return box.values
        .where((e) => e.syncStatus == SyncStatus.pendingSync.index)
        .map((e) => e.toEntity())
        .toList();
  }
}
