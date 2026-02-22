import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_management/core/router/app_strings.dart';
import 'package:task_management/core/utils/reusable_functions.dart';
import 'package:task_management/domain/entities/task.dart';

class TaskListView extends StatelessWidget {
  final ScrollController scrollController;
  final List<Task> tasks;
  final bool hasReachedEnd;

  const TaskListView({
    super.key,
    required this.scrollController,
    required this.tasks,
    required this.hasReachedEnd,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: tasks.length + (hasReachedEnd ? 0 : 1),
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        if (index >= tasks.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final task = tasks[index];
        return ListTile(
          title: Text(
            task.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.description),
              const SizedBox(height: 4),
              Text(
                "Status: ${ReusableFunctions.returnStatusString(task.status)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
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
          ),
          trailing: Text(task.syncStatus.name),
          onTap: () {
            GoRouter.of(context).push(AppStrings.formScreen, extra: task);
          },
        );
      },
    );
  }
}
