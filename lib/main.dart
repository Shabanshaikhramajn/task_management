import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_management/core/di/service_locator.dart';
import 'package:task_management/core/router/app_router.dart';
import 'package:task_management/data/models/task_hive_model.dart';
import 'package:task_management/presentation/bloc/sync_bloc/sync_bloc.dart';

import 'presentation/bloc/task_bloc/task_bloc.dart';
import 'presentation/bloc/task_form_bloc/task_form_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive init
  await Hive.initFlutter();
  Hive.registerAdapter(TaskHiveModelAdapter());
  await Hive.openBox<TaskHiveModel>('tasks');

  // Dependency injection
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>(
          create: (_) => sl<TaskBloc>(),
        ),
        BlocProvider<TaskFormBloc>(
          create: (_) => sl<TaskFormBloc>(),
        ),
        BlocProvider<SyncBloc>(
          lazy: false,
          create: (_) => sl<SyncBloc>(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Offline Task Manager',
        routerConfig: appRouter,
      ),
    );
  }
}