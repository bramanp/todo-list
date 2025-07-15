import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list/model/task.dart';
import 'package:todo_list/providers/tasks_provider.dart';

class NewTask extends ConsumerStatefulWidget {
  const NewTask(this.titleFocusNode, {super.key});

  final FocusNode titleFocusNode;
  @override
  ConsumerState<NewTask> createState() => _NewTaskState();
}

class _NewTaskState extends ConsumerState<NewTask> {
  final _formKey = GlobalKey<FormState>();
  String _enteredTitle = '';
  Category _enteredCategory = Category.noCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.titleFocusNode.requestFocus();
    });
  }

  void _onSavedTask() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ref
          .read(tasksProvider.notifier)
          .addTask(Task(title: _enteredTitle, category: _enteredCategory));
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  label: Text('Masukkan tugas anda di sini'),
                ),
                focusNode: widget.titleFocusNode,
                maxLength: 30,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tolong tambahkan deskripsi';
                  }
                  if (value.length >= 30) {
                    return 'Teks terlalu panjang!';
                  }
                  return null;
                },
                onSaved: (newValue) => _enteredTitle = newValue!,
              ),
              SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Category>(
                      decoration: InputDecoration(label: Text('Kategori')),
                      value: Category.noCategory,
                      items:
                          Category.values.map((category) {
                            return DropdownMenuItem<Category>(
                              value: category,
                              child: Text(categoryToIndonesian(category)),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _enteredCategory = value;
                          });
                        }
                      },
                      onSaved: (value) {
                        if (value != null) {
                          _enteredCategory = value;
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Tutup'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _onSavedTask,
                    child: Text('Tambah'),
                  ),
                ],
              ),
              SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }
}
