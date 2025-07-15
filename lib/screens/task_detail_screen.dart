import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list/model/task.dart';
import 'package:todo_list/providers/tasks_provider.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({super.key, required this.task});

  @override
  ConsumerState<TaskDetailScreen> createState() {
    return _TaskDetailScreenState();
  }

  final Task task;
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  var isEdit = false;
  late String _enteredTitle = '';
  late Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _enteredTitle = widget.task.title;
    _selectedCategory = widget.task.category;
  }

  void _editTask() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final String newTitle = _enteredTitle;
      final Category newCategory = _selectedCategory!;
      final Task updatedTask = Task(
        title: newTitle,
        category: newCategory,
        id: widget.task.id,
      );
      ref.read(tasksProvider.notifier).updateTask(updatedTask);
      setState(() {
        isEdit = !isEdit;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void onDeleteTask() {
      ref.read(tasksProvider.notifier).deleteTask(widget.task);
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          isEdit
              ? OutlinedButton.icon(
                onPressed: _editTask,
                icon: const Icon(Icons.check),
                label: const Text('Selesai'),
              )
              : OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    isEdit = !isEdit;
                  });
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
          SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: OutlinedButton.icon(
              onPressed: onDeleteTask,
              label: Text(
                'Hapus',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tugas Anda:'),
            const SizedBox(height: 6),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TextField untuk title
                  TextFormField(
                    initialValue: widget.task.title,
                    enabled: isEdit,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    style: Theme.of(context).textTheme.titleLarge,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Tolong masukkan text!';
                      }
                      return null;
                    },
                    onSaved: (newValue) => _enteredTitle = newValue!,
                  ),
                  const SizedBox(height: 32),
                  const Text('Kategori:'),
                  const SizedBox(height: 6),
                  isEdit
                      ? DropdownButtonFormField<Category>(
                        value: widget.task.category,
                        items:
                            Category.values
                                .map(
                                  (cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(categoryToIndonesian(cat)),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _selectedCategory = value;
                          }
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      )
                      : Text(
                        categoryToIndonesian(widget.task.category),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
