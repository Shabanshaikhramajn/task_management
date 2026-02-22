import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/domain/entities/task.dart';
import 'package:task_management/presentation/bloc/task_form_bloc/task_form_bloc.dart';
import 'package:task_management/presentation/bloc/task_form_bloc/task_form_state.dart';
import 'package:task_management/presentation/bloc/task_form_bloc/task_from_event.dart';
import 'package:uuid/uuid.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? existingTask;

  const TaskFormScreen({super.key, this.existingTask});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingTask?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingTask?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final task = widget.existingTask == null
        ? Task(
            id: const Uuid().v4(),
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            status: TaskStatus.pending,
            createdAt: now,
            updatedAt: now,
            syncStatus: SyncStatus.pendingSync,
          )
        : widget.existingTask!.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            updatedAt: now,
            syncStatus: SyncStatus.pendingSync,
          );

    context.read<TaskFormBloc>().add(
      widget.existingTask == null ? CreateTask(task) : UpdateTask(task),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTask == null ? 'Create Task' : 'Edit Task'),
      ),
      body: BlocListener<TaskFormBloc, TaskFormState>(
        listener: (context, state) {
          if (state is TaskFormSaved) {
            Navigator.pop(context);
          }
          if (state is TaskFormError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Description is required' : null,
                ),
                const SizedBox(height: 24),
                BlocBuilder<TaskFormBloc, TaskFormState>(
                  builder: (context, state) {
                    final isSaving = state is TaskFormSaving;
                    return ElevatedButton(
                      onPressed: isSaving ? null : _onSave,
                      child: isSaving
                          ? const CircularProgressIndicator()
                          : const Text('Save'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
