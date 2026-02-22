import 'package:bloc/bloc.dart';
import 'package:task_management/domain/entities/task.dart';
import 'package:task_management/domain/usecases/save_user_usecase.dart';
import 'package:task_management/presentation/bloc/task_form_bloc/task_form_state.dart';
import 'package:task_management/presentation/bloc/task_form_bloc/task_from_event.dart';

class TaskFormBloc extends Bloc<TaskFormEvent, TaskFormState> {
  final SaveTaskUseCase saveTask;
  bool isSaving = false;

  TaskFormBloc(this.saveTask) : super(TaskFormIdle()) {
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
  }

  Future<void> _onCreateTask(
    CreateTask event,
    Emitter<TaskFormState> emit,
  ) async {
    if (isSaving) return;

    isSaving = true;
    emit(TaskFormSaving());

    try {
      // await Future.delayed(const Duration(seconds: 3));
      final task = event.task.copyWith(
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pendingSync,
      );

      await saveTask(task);

      emit(TaskFormSaved());
    } catch (e) {
      emit(TaskFormError(e.toString()));
    } finally {
      isSaving = false;
    }
  }

  Future<void> _onUpdateTask(
    UpdateTask event,
    Emitter<TaskFormState> emit,
  ) async {
    if (isSaving) return;

    isSaving = true;
    emit(TaskFormSaving());

    try {
      // await Future.delayed(const Duration(seconds: 3));
      final task = event.task.copyWith(
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pendingSync,
      );

      await saveTask(task);

      emit(TaskFormSaved());
    } catch (e) {
      emit(TaskFormError(e.toString()));
    } finally {
      isSaving = false;
    }
  }
}
