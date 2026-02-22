import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/domain/entities/task.dart';
import 'package:task_management/domain/repositories/task_repositories.dart';
import 'package:task_management/presentation/bloc/sync_bloc/sync_event.dart';
import 'package:task_management/presentation/bloc/sync_bloc/sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> with WidgetsBindingObserver {
  final TaskRepository repository;
  bool _isSyncRunning = false;
  Timer? _timer;

  static const _syncInterval = Duration(seconds: 10);

  SyncBloc(this.repository) : super(SyncIdle()) {
    WidgetsBinding.instance.addObserver(this);
    debugPrint('🔥 SyncBloc CREATED');
    on<StartSync>(_onStartSync);

    _startTimer();
    add(StartSync()); // initial app launch
  }

   void _startTimer(){
    _timer?.cancel();
    _timer = Timer.periodic(_syncInterval, (_){
      add(StartSync());
    });
   }

  void _stopTimer(){
    _timer?.cancel();
    _timer = null;
  }

  // App lifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _stopTimer();
    } else if (state == AppLifecycleState.resumed) {
      _startTimer();
      add(StartSync());
    }
  }

  Future<void> _onStartSync( StartSync event, Emitter<SyncState> emit) async {
    if (_isSyncRunning) return;
 _isSyncRunning = true;
    emit(SyncInProgress());
 try {
      final tasks = await repository.getPendingSyncTasks();

      for (final task in tasks) {
        await _syncTask(task);
      }

      emit(SyncSuccess());
    } catch (e) {
      emit(SyncFailure(e.toString()));
    } finally {
      _isSyncRunning = false;
    }
  }
  
  
  Future<void> _syncTask(Task task )async{
    await Future.delayed(const Duration(seconds: 2));
    
    final failed = Random().nextInt(100)<30;
    if(failed){
      await repository.saveTask(
        task.copyWith(syncStatus: SyncStatus.failed)
      );
      return;
    }
    final serverUpdatedAt = task.updatedAt.subtract(const Duration(seconds: 5));
    if(task.updatedAt.isAfter(serverUpdatedAt)){
      await repository.saveTask(task.copyWith(syncStatus: SyncStatus.synced));

    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    return super.close();
  }


}