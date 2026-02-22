import 'dart:async';

import 'package:bloc/bloc.dart';
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

    if (allTasks.isEmpty) {
      emit(TaskEmpty());
    } else {
      emit(TaskLoaded(
        tasks: _paginate(),
        hasReachedEnd: allTasks.length <= pageSize,
      ));
    }
  }

  // load tasks ----------------------------------------------------------------------------------------------------------------------------

  Future<void> _onLoadTasks(
    LoadTasks event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    page = 0;
  }

  //   ----------------------------------------------------------------------------------------------------------------------------
 Future<void> _onLoadNextPage( LoadNextPage event, Emitter<TaskState> emit) async {
   if (state is! TaskLoaded) return;
     page++;

   emit(TaskLoaded(
     tasks: _paginate(),
     hasReachedEnd: (page + 1) * pageSize >= allTasks.length,
   ));
  }

  //  ----------------------------------------------------------------------------------------------------------------------------
void _onSearchTasks(
    SearchTasks event,
    Emitter<TaskState> emit,
  ) {
    final filtered = allTasks
        .where((t) =>
            t.title.toLowerCase().contains(event.query.toLowerCase()))
        .toList();

    emit(TaskLoaded(
      tasks: filtered,
      hasReachedEnd: true,
    ));
  }
  //  ----------------------------------------------------------------------------------------------------------------------------
void _onFilterTasks(
      FilterTasks event,
      Emitter<TaskState> emit,
      ) {
    final filtered = event.status == null
        ? allTasks
        : allTasks.where((t) => t.status == event.status).toList();

    emit(TaskLoaded(
      tasks: filtered,
      hasReachedEnd: true,
    ));
  }

//  ----------------------------------------------------------------------------------------------------------------------------
  List<Task> _paginate() {
    final end = ((page + 1) * pageSize).clamp(0, allTasks.length);
    return allTasks.sublist(0, end);
  }

//  ----------------------------------------------------------------------------------------------------------------------------
  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

}