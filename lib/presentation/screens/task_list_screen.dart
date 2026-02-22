import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          PopupMenuButton<TaskStatus?>(
            onSelected: (status) {
              context.read<TaskBloc>().add(FilterTasks(status));
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: null, child: Text('All')),
              PopupMenuItem(value: TaskStatus.pending, child: Text('Pending Sync')),
              PopupMenuItem(
                value: TaskStatus.failed,
                child: Text('Failed'),
              ),
              PopupMenuItem(
                value: TaskStatus.completed,
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
                      child: ListView.builder(
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
                            title: Text(task.title),
                            subtitle: Text(task.description),
                            trailing: Text(task.syncStatus.name),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TaskFormScreen(existingTask: task),
                                ),
                              );
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaskFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
