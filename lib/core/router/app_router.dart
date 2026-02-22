import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/task_form_screen.dart';
import '../../presentation/screens/task_list_screen.dart';

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
        // final task = state.extra; // Task? for edit
        return TaskFormScreen();
      },
    ),
  ],
);