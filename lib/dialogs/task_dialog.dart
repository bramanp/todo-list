import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list/model/task.dart';
import 'package:todo_list/providers/tasks_provider.dart';

class TaskDialog extends ConsumerStatefulWidget {
  const TaskDialog(this.task, {super.key});

  final Task task;

  @override
  ConsumerState<TaskDialog> createState() {
    return _TaskDialogState();
  }
}

class _TaskDialogState extends ConsumerState<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  var isEdit = false;
  late String _enteredTitle;
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
      final Task updatedTask = Task(
        title: _enteredTitle,
        category: _selectedCategory!,
        id: widget.task.id,
        isDone: widget.task.isDone,
      );

      // Jika title dan category masih sama dengan sebelumnya maka tidak dilakukan update
      if ((updatedTask.title == widget.task.title) &&
          (updatedTask.category.name == widget.task.category.name)) {
        return;
      }

      ref.read(tasksProvider.notifier).updateTask(updatedTask);
      setState(() {
        isEdit = !isEdit;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Tutup'),
        ),
        OutlinedButton(
          onPressed: () {
            _editTask();
            Navigator.of(context).pop();
          },
          child: Text('Ubah'),
        ),
      ],

      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tugas Anda:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TextField untuk title
                  TextFormField(
                    initialValue: widget.task.title,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    style: Theme.of(context).textTheme.titleMedium,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Tolong masukkan text!';
                      }
                      return null;
                    },
                    onSaved: (newValue) => _enteredTitle = newValue!,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kategori:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),

                  DropdownButtonFormField<Category>(
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
                    decoration: InputDecoration(border: OutlineInputBorder()),
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
