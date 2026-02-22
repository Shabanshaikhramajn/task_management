import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_management/domain/entities/task.dart';

import '../../presentation/screens/task_form/task_form_screen.dart';
import '../../presentation/screens/task_list/task_list_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TaskListScreen(),
    ),
    GoRoute(
      path: '/task',
      builder: (context, state) {
        // Pass existing task if editing
        final task = state.extra as Task?;
        return TaskFormScreen(existingTask: task);
      },
    ),
  ],
);