import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list/dialogs/task_dialog.dart';
import 'package:todo_list/model/task.dart';
import 'package:todo_list/providers/tasks_provider.dart';

// Merupakan Widget dari task

class TaskItem extends ConsumerWidget {
  const TaskItem({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void deleteConfirmation() {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Batal'),
                    ),
                    SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {
                        ref.read(tasksProvider.notifier).deleteTask(task);
                        Navigator.of(context).pop();
                      },
                      child: Text('Hapus'),
                    ),
                  ],
                ),
              ],
              content: Text(
                'Hapus tugas ?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
      );
    }

    final textColor =
        task.isDone
            ? Theme.of(
              context,
            ).colorScheme.onSurface.withAlpha((255 * 0.6).round())
            : Theme.of(context).colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            decoration:
                task.isDone == true
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
            color: textColor,
          ),
        ),
        subtitle: Text(
          categoryToIndonesian(task.category),
          style: TextStyle(color: textColor),
        ),
        onTap:
            () =>
                showDialog(context: context, builder: (_) => TaskDialog(task)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit button
            IconButton(
              onPressed:
                  () => showDialog(
                    context: context,
                    builder: (_) => TaskDialog(task),
                  ),
              icon: Icon(Icons.edit),
            ),

            // Delelte button
            IconButton(
              onPressed: () {
                deleteConfirmation();
              },
              icon: Icon(Icons.delete),
            ),

            // Checkbox button
            Checkbox(
              value: task.isDone,
              onChanged: (_) {
                ref.read(tasksProvider.notifier).toggleIsDone(task);
              },
            ),
          ],
        ),
      ),
    );
  }
}
