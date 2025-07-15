import 'package:flutter/material.dart';
import 'package:todo_list/model/task.dart';
import 'package:todo_list/widgets/task_item.dart';

// List tugas dengan ListView

class TaskList extends StatelessWidget {
  const TaskList({super.key, required this.taskList});

  final List<Task> taskList;

  @override
  Widget build(BuildContext context) {
    if (taskList.isEmpty) {
      return const Center(
        child: Text('Belum ada tugas. Silahkan tambahkan tugas.'),
      );
    }

    return ListView.builder(
      itemCount: taskList.length,
      itemBuilder: (context, index) {
        return TaskItem(
          task: taskList[index],
          key: ValueKey(taskList[index].id),
        );
      },
    );
  }
}
