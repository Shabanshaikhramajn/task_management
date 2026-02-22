import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_management/core/router/app_strings.dart';
import 'package:task_management/core/utils/reusable_functions.dart';
import 'package:task_management/domain/entities/task.dart';
import 'package:task_management/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:task_management/presentation/bloc/task_bloc/task_event.dart';
import 'package:task_management/presentation/bloc/task_bloc/task_state.dart';
import 'package:task_management/presentation/screens/task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  bool _isLoadingMore = false;
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100 &&
        !_isLoadingMore) {

      _isLoadingMore = true;

      context.read<TaskBloc>().add(LoadNextPage());

      // small delay to prevent spam
      Future.delayed(const Duration(milliseconds: 300), () {
        _isLoadingMore = false;
      });
    }
  }
  void _onSearch(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<TaskBloc>().add(SearchTasks(query));
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          PopupMenuButton<FilterOption>(
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
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: FilterOption.all,
                child: Text('All'),
              ),
              const PopupMenuItem(
                value: FilterOption.pending,
                child: Text('Pending'),
              ),
              const PopupMenuItem(
                value: FilterOption.inProgress,
                child: Text('In Progress'),
              ),
              const PopupMenuItem(
                value: FilterOption.completed,
                child: Text('Completed'),
              ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  border: OutlineInputBorder(),
                ),
                onChanged: _onSearch,
              ),
            ),
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is TaskEmpty) {
                    return const Center(child: Text('No tasks found'));
                  }

                  if (state is TaskLoaded) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<TaskBloc>().add(LoadTasks());
                      },
                      child: ListView.separated(
                        separatorBuilder: (context,index){
                          return Divider();
                        },
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.tasks.length + (state.hasReachedEnd ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (index >= state.tasks.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final task = state.tasks[index];
                          return ListTile(
                            title: Text(task.title, style: TextStyle(fontWeight: FontWeight.bold),),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task.description),
                                const SizedBox(height: 4),
                                Text(
                                  "Status: ${ReusableFunctions.returnStatusString(task.status)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Created: ${ReusableFunctions.formatDateTime(task.createdAt)}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                if (task.updatedAt.difference(task.createdAt).inSeconds != 0)
                                Text(
                                  "Updated: ${ReusableFunctions.formatDateTime(task.updatedAt)}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ), trailing: Text(task.syncStatus.name),
                            onTap: () {
                              GoRouter.of(context).push(AppStrings.formScreen, extra: task);
                            },
                          );
                        },
                      ),
                    );
                  }

                  if (state is TaskError) {
                    return Center(child: Text(state.message));
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).push(AppStrings.formScreen);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
