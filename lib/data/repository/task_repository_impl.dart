import 'dart:async';

import 'package:task_management/data/datasource/local/task_local_datasource.dart';
import 'package:task_management/domain/entities/task.dart';
import 'package:task_management/domain/repositories/task_repositories.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource local;
  final _controller = StreamController<List<Task>>.broadcast();
  static const int _pageSize = 20;
  final int _offset = 0;
  TaskRepositoryImpl(this.local) {
    _emitTasks();
  }

  void _emitTasks()async {
    final tasks = await local.fetchAllTasks(_pageSize, _offset);
    _controller.add(tasks);
  }

   @override
   Stream<List<Task>> watchTasks()=> _controller.stream;


  @override
  Future<void> saveTask(Task task) async {
    await local.upsertTask(task);
    _emitTasks(); //  push update
  }
  @override
  Future<List<Task>> getTasks(int limit, int offset) =>
      local.fetchAllTasks(limit, offset);

  @override
  Future<List<Task>> getPendingSyncTasks() =>
      local.fetchPendingSyncTasks();


   void dispose(){
     _controller.close();
   }
}