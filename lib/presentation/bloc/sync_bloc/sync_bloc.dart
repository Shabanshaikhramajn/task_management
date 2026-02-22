import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/domain/entities/task.dart';
import 'package:task_management/domain/repositories/task_repositories.dart';
import 'package:task_management/presentation/bloc/sync_bloc/sync_event.dart';
import 'package:task_management/presentation/bloc/sync_bloc/sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState>
    with WidgetsBindingObserver {

  final TaskRepository repo;
  bool _isSyncRunning = false;
  Timer? _timer;

  SyncBloc(this.repo) : super(SyncIdle()) {
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => add(StartSync()),
    );
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    return super.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _timer?.cancel();
    if (state == AppLifecycleState.resumed) _startTimer();
  }

  @override
  Stream<SyncState> mapEventToState(SyncEvent event) async* {
    if (_isSyncRunning) return;

    _isSyncRunning = true;
    try {
      final tasks = await repo.getPendingSyncTasks();
      for (final task in tasks) {
        await _syncTask(task);
      }
    } finally {
      _isSyncRunning = false;
    }
  }

  Future<void> _syncTask(Task task) async {
    await Future.delayed(const Duration(seconds: 2));

    final failed = Random().nextInt(100) < 30;
    if (failed) {
      await repo.saveTask(
        task.copyWith(syncStatus: SyncStatus.failed),
      );
      return;
    }

    // 🔥 Conflict Resolution
    final serverUpdatedAt =
        task.updatedAt.subtract(const Duration(seconds: 5));

    if (task.updatedAt.isAfter(serverUpdatedAt)) {
      await repo.saveTask(
        task.copyWith(syncStatus: SyncStatus.synced),
      );
    }
  }
}