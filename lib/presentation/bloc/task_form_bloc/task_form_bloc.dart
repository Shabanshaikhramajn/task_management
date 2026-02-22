import 'package:bloc/bloc.dart';
import 'package:task_management/core/logger/logger.dart';
import 'package:task_management/domain/entities/task.dart';
import 'package:task_management/domain/usecases/save_user_usecase.dart';
import 'package:task_management/presentation/bloc/task_form_bloc/task_form_state.dart';
import 'package:task_management/presentation/bloc/task_form_bloc/task_from_event.dart';

class TaskFormBloc extends Bloc<TaskFormEvent, TaskFormState> {
  final SaveTaskUseCase saveTask;
  bool isSaving = false;
  final _logger = AppLogger(); // reusable logger
  TaskFormBloc(this.saveTask) : super(TaskFormIdle()) {
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<ChangeTaskStatus>(_onChangeTaskStatus);
    on<ChangeTaskTitle>(_onChangeTaskTitle);
    on<ChangeTaskDescription>(_onChangeTaskDescription);
  }

  // ----------------------------------------------------------------------
  Future<void> _onCreateTask(
    CreateTask event,
    Emitter<TaskFormState> emit,
  ) async {
    if (isSaving) {
      _logger.w('CreateTask ignored: already saving');
      return;
    }
    isSaving = true;
    emit(TaskFormSaving());
    _logger.i('Creating task: ${event.task.title}');
    try {
      // await Future.delayed(const Duration(seconds: 2));
      final task = event.task.copyWith(
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pendingSync,
      );

      await saveTask(task);
      _logger.i('Task created successfully: ${task.id}');
      emit(TaskFormSaved());
    } catch (e) {
      _logger.e('Error creating task', e);
      emit(TaskFormError(e.toString()));
    } finally {
      isSaving = false;
    }
  }

  // ----------------------------------------------------------------------
  Future<void> _onUpdateTask(
    UpdateTask event,
    Emitter<TaskFormState> emit,
  ) async {
    if (isSaving) {
      _logger.w('UpdateTask ignored: already saving');
      return;
    }
    isSaving = true;
    emit(TaskFormSaving());
    _logger.i('Updating task: ${event.task.id}');
    try {
      // await Future.delayed(const Duration(seconds: 2));
      final task = event.task.copyWith(
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pendingSync,
      );

      await saveTask(task);
      _logger.i('Task updated successfully: ${task.id}');
      emit(TaskFormSaved());
    } catch (e) {
      _logger.e('Error updating task', e);
      emit(TaskFormError(e.toString()));
    } finally {
      isSaving = false;
    }
  }

  // ----------------------------------------------------------------------
  void _onChangeTaskStatus(
    ChangeTaskStatus event,
    Emitter<TaskFormState> emit,
  ) {
    if (state is TaskFormIdle) {
      final current = state as TaskFormIdle;
      emit(current.copyWith(status: event.status));
      _logger.d('Task status changed to: ${event.status}');
    }
  }

  void _onChangeTaskTitle(ChangeTaskTitle event, Emitter<TaskFormState> emit) {
    if (state is TaskFormIdle) {
      final current = state as TaskFormIdle;
      emit(current.copyWith(title: event.title));
      _logger.d('Task title changed to: ${event.title}');
    }
  }

  // ----------------------------------------------------------------------
  void _onChangeTaskDescription(
    ChangeTaskDescription event,
    Emitter<TaskFormState> emit,
  ) {
    if (state is TaskFormIdle) {
      final current = state as TaskFormIdle;
      emit(current.copyWith(description: event.description));
      _logger.d('Task description changed to: ${event.description}');
    }
  }
}
