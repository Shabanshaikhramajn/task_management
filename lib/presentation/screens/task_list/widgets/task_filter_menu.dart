import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/domain/entities/task.dart';
import 'package:task_management/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:task_management/presentation/bloc/task_bloc/task_event.dart';

class _TaskFilterMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<FilterOption>(
      onSelected: (filter) {
        TaskStatus? status;
        switch (filter) {
          case FilterOption.all:
            status = null;
            break;
          case FilterOption.pending:
            status = TaskStatus.pending;
            break;
          case FilterOption.inProgress:
            status = TaskStatus.inProgress;
            break;
          case FilterOption.completed:
            status = TaskStatus.completed;
            break;
        }
        context.read<TaskBloc>().add(FilterTasks(status));
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: FilterOption.all, child: Text('All')),
        PopupMenuItem(value: FilterOption.pending, child: Text('Pending')),
        PopupMenuItem(
          value: FilterOption.inProgress,
          child: Text('In Progress'),
        ),
        PopupMenuItem(value: FilterOption.completed, child: Text('Completed')),
      ],
    );
  }
}
