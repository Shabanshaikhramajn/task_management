import 'package:bloc/bloc.dart';
import 'package:task_management/domain/usecases/get_tasks_usecase.dart';
import 'package:task_management/presentation/bloc/task_bloc/task_event.dart';
import 'package:task_management/presentation/bloc/task_bloc/task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasks;
  int page = 0;
  final int pageSize = 20;
  bool isFetching = false;

  TaskBloc(this.getTasks) : super(TaskInitial());

  @override
  Stream<TaskState> mapEventToState(TaskEvent event) async* {
    if (event is LoadNextPage) {
      if (isFetching) return; // prevent overlapping calls
      isFetching = true;

      try {
        yield TaskLoading();

        final tasks = await getTasks(page, pageSize);
        page++;

        if (tasks.isEmpty && page == 1) {
          yield TaskEmpty();
        } else {
          yield TaskLoaded(
            tasks: tasks,
            hasReachedEnd: tasks.length < pageSize,
          );
        }
      } catch (e) {
        yield TaskError(e.toString());
      } finally {
        isFetching = false;
      }
    }
  }
}