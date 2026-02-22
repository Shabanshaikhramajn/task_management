import 'package:flutter/material.dart';

class TaskSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const TaskSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search tasks...',
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
