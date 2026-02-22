import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:task_management/domain/entities/task.dart';
import 'package:task_management/domain/repositories/task_repositories.dart';
import 'package:task_management/presentation/bloc/task_bloc/task_event.dart';
import 'package:task_management/presentation/bloc/task_bloc/task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;
  // final GetTasksUseCase getTasks;
  StreamSubscription<List<Task>>? _subscription;
  int page = 0;
  final int pageSize = 10;
  bool isFetching = false;
  TaskStatus? _activeStatusFilter;
  String _searchQuery = '';

  List<Task> allTasks = [];

  TaskBloc(this.repository) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<LoadNextPage>(_onLoadNextPage);
    on<SearchTasks>(_onSearchTasks);
    on<FilterTasks>(_onFilterTasks);
    on<TasksUpdated>(_onTasksUpdated);

    _subscription = repository.watchTasks().listen(
          (tasks) => add(TasksUpdated(tasks)),
    );
  }

  //  ----------------------------------------------------------------------------------------------------------------------------
  void _onTasksUpdated( TasksUpdated event, Emitter<TaskState> emit) {
    allTasks = event.tasks;
    page = 0;
    final tasks = _applyQueryAndPaginate();
    final filteredTotal = _applyQuery().length;

    if (tasks.isEmpty) {
      emit(TaskEmpty());
    } else {
      emit(TaskLoaded(
        tasks: tasks,
        hasReachedEnd: tasks.length >= filteredTotal,
      ));
    }
  }

  // load tasks ----------------------------------------------------------------------------------------------------------------------------

  Future<void> _onLoadTasks(LoadTasks event,Emitter<TaskState> emit) async {
    emit(TaskLoading());
    page = 0;
    // Fake delay for pull-to-refresh testing
    await Future.delayed(const Duration(seconds: 2));

    final tasks = _applyQueryAndPaginate();
    final filteredTotal = _applyQuery().length;

    if (tasks.isEmpty) {
      emit(TaskEmpty());
    } else {
      emit(TaskLoaded(
        tasks: tasks,
        hasReachedEnd: tasks.length >= filteredTotal,
      ));
    }
  }

  //   ----------------------------------------------------------------------------------------------------------------------------
 Future<void> _onLoadNextPage( LoadNextPage event, Emitter<TaskState> emit) async {
   final currentState = state;
   if (currentState is! TaskLoaded || currentState.hasReachedEnd) return;

   debugPrint('📄 Loading next page...');
   await Future.delayed(const Duration(seconds: 2));

   page++;

   final tasks = _applyQueryAndPaginate();
   final filteredTotal = _applyQuery().length;

   emit(TaskLoaded(
     tasks: tasks,
     hasReachedEnd: tasks.length >= filteredTotal,
   ));
  }

  //  ----------------------------------------------------------------------------------------------------------------------------
void _onSearchTasks( SearchTasks event, Emitter<TaskState> emit) {
  _searchQuery = event.query.trim().toLowerCase();
  page = 0;

  final tasks = _applyQueryAndPaginate();
  final filteredTotal = _applyQuery().length;

  if (tasks.isEmpty) {
    emit(TaskEmpty());
  } else {
    emit(TaskLoaded(
      tasks: tasks,
      hasReachedEnd: tasks.length >= filteredTotal,
    ));
  }
  }
  //  ----------------------------------------------------------------------------------------------------------------------------
void _onFilterTasks( FilterTasks event, Emitter<TaskState> emit) {
  _activeStatusFilter = event.status;
  page = 0;

  final tasks = _applyQueryAndPaginate();
  final filteredTotal = _applyQuery().length;

  if (tasks.isEmpty) {
    emit(TaskEmpty());
  } else {
    emit(TaskLoaded(
      tasks: tasks,
      hasReachedEnd: tasks.length >= filteredTotal,
    ));
  }
  }

//  ----------------------------------------------------------------------------------------------------------------------------
  List<Task> _paginate() {
    final end = ((page + 1) * pageSize).clamp(0, allTasks.length);
    return allTasks.sublist(0, end);
  }


  List<Task> _applyQueryAndPaginate() {
    final filtered = _applyQuery();
    final end = ((page + 1) * pageSize).clamp(0, filtered.length);
    return filtered.sublist(0, end);
  }


  List<Task> _applyQuery() {
    List<Task> filtered = allTasks;

    if (_activeStatusFilter != null) {
      filtered =
          filtered.where((t) => t.status == _activeStatusFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        return t.title.toLowerCase().contains(_searchQuery) ||
            t.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

//  ----------------------------------------------------------------------------------------------------------------------------
  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

}