import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_management/core/router/app_strings.dart';
import 'package:task_management/domain/entities/task.dart';
import 'package:task_management/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:task_management/presentation/bloc/task_bloc/task_event.dart';
import 'package:task_management/presentation/bloc/task_bloc/task_state.dart';
import 'package:task_management/presentation/screens/task_list/widgets/task_list_view.dart';
import 'package:task_management/presentation/screens/task_list/widgets/task_search_bar.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  bool _isLoadingMore = false;

  // ----------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks());
    _scrollController.addListener(_onScroll);
  }

  // ----------------------------------------------------------------------
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoadingMore) {
      _isLoadingMore = true;
      context.read<TaskBloc>().add(LoadNextPage());
      Future.delayed(const Duration(milliseconds: 300), () {
        _isLoadingMore = false;
      });
    }
  }

  // ----------------------------------------------------------------------
  void _onSearch(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<TaskBloc>().add(SearchTasks(query));
    });
  }

  // ----------------------------------------------------------------------
  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks'), actions: [_TaskFilterMenu()]),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            TaskSearchBar(onChanged: _onSearch),
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading)
                    return const Center(child: CircularProgressIndicator());
                  if (state is TaskEmpty)
                    return const Center(child: Text('No tasks found'));
                  if (state is TaskError)
                    return Center(child: Text(state.message));
                  if (state is TaskLoaded) {
                    return RefreshIndicator(
                      onRefresh: () async =>
                          context.read<TaskBloc>().add(LoadTasks()),
                      child: TaskListView(
                        scrollController: _scrollController,
                        tasks: state.tasks,
                        hasReachedEnd: state.hasReachedEnd,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => GoRouter.of(context).push(AppStrings.formScreen),
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
