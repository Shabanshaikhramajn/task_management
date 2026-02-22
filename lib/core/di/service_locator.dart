  import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:task_management/data/datasource/local/task_local_datasource.dart';
import 'package:task_management/data/models/task_hive_model.dart';
import 'package:task_management/data/repository/task_repository_impl.dart';
import 'package:task_management/domain/repositories/task_repositories.dart';
import 'package:task_management/domain/usecases/get_tasks_usecase.dart';
import 'package:task_management/domain/usecases/save_user_usecase.dart';
import 'package:task_management/presentation/bloc/sync_bloc/sync_bloc.dart';
import '../../presentation/bloc/task_bloc/task_bloc.dart';
import '../../presentation/bloc/task_form_bloc/task_form_bloc.dart';
import '../../data/datasource/local/task_local_datasource_impl.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  //  Hive box
  sl.registerLazySingleton<Box<TaskHiveModel>>(
    () => Hive.box<TaskHiveModel>('tasks'),
  );

  //  Local Data Source
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDatasourceImpl(sl()),
  );

  //  Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(sl()),
  );

  //  Use cases
  sl.registerLazySingleton<GetTasksUseCase>(
    () => GetTasksUseCase(sl()),
  );

  sl.registerLazySingleton<SaveTaskUseCase>(
    () => SaveTaskUseCase(sl()),
  );

  //  Blocs
  sl.registerFactory<TaskBloc>(
    () => TaskBloc(sl()),
  );

  sl.registerFactory<TaskFormBloc>(
    () => TaskFormBloc(sl()),
  );

  sl.registerLazySingleton<SyncBloc>(
        () => SyncBloc(sl<TaskRepository>()),
  );


}