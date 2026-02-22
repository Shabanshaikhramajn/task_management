import 'package:bloc/bloc.dart';
import 'package:task_management/domain/entities/task.dart';
import 'package:task_management/domain/usecases/save_user_usecase.dart';
import 'package:task_management/presentation/bloc/task_form_bloc/task_form_state.dart';
import 'package:task_management/presentation/bloc/task_form_bloc/task_from_event.dart';

class TaskFormBloc extends Bloc<TaskFormEvent, TaskFormState> {
  final SaveTaskUseCase saveTask;
  bool isSaving = false;

  TaskFormBloc(this.saveTask) : super(TaskFormIdle());

  @override
  Stream<TaskFormState> mapEventToState(TaskFormEvent event) async* {
    if (isSaving) return;

    if (event is CreateTask || event is UpdateTask) {
      isSaving = true;
      yield TaskFormSaving();

      final Task originalTask =
          event is CreateTask ? event.task : (event as UpdateTask).task;

      final updatedTask = originalTask.copyWith(
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pendingSync,
      );

      await saveTask(updatedTask);

      isSaving = false;
      yield TaskFormSaved();
    }
  }
}