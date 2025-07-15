import 'package:todo_list/model/task.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

// Metode mendapatkan database, jika belum ada maka database akan dibuat
Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();

  final db = await sql.openDatabase(
    path.join(dbPath, 'tasks.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE tasks_table(id TEXT PRIMARY KEY, title TEXT, category TEXT, isDone BOOLEAN)',
      );
    },
    version: 1,
  );
  return db;
}

class TasksNotifier extends StateNotifier<List<Task>> {
  TasksNotifier() : super([]);

  // Memuat data task yang berada di database
  Future<void> loadTasks() async {
    final db = await _getDatabase();
    final data = await db.query('tasks_table');

    final tasks =
        data
            .map(
              (row) => Task(
                id: row['id'] as String,
                title: row['title'] as String,
                category: Category.values.firstWhere(
                  (value) => value.name == row['category'],
                ),
                isDone: row['isDone'] == 1,
              ),
            )
            .toList();

    state = tasks;
  }

  // metode untuk tambah data
  Future<void> addTask(Task task) async {
    final db = await _getDatabase();

    await db.insert('tasks_table', {
      'id': task.id,
      'title': task.title,
      'category': task.category.name,
      'isDone': task.isDone ? 1 : 0,
    });

    state = [...state, task];
  }

  // metode untuk ubah tugas selesai atau sebaliknya
  Future<void> toggleIsDone(Task task) async {
    // Membuat task baru dengan nilai completed berubah
    final updatedTask = task.copyWith(isDone: !task.isDone);

    final db = await _getDatabase();

    await db.update(
      'tasks_table',
      {'isDone': updatedTask.isDone ? 1 : 0},
      where: 'id = ?',
      whereArgs: [task.id],
    );

    state = [
      for (final data in state)
        if (data.id == task.id) updatedTask else data,
    ];
  }

  // metode untuk edit tugas
  Future<void> updateTask(Task updatedTask) async {
    final db = await _getDatabase();

    await db.update(
      'tasks_table',
      {
        'title': updatedTask.title,
        'category': updatedTask.category.name,
        'isDone': updatedTask.isDone ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [updatedTask.id],
    );

    state = [
      for (final data in state)
        if (data.id == updatedTask.id) updatedTask else data,
    ];
  }

  // metode untuk delete tugas
  Future<void> deleteTask(Task task) async {
    final db = await _getDatabase();

    await db.delete('tasks_table', where: 'id = ?', whereArgs: [task.id]);

    state = [
      for (final data in state)
        if (data != task) data,
    ];
  }

  Future<void> replaceAll(List<Task> taskList) async {
    // Hapus seluruh data di databse lokal
    final db = await _getDatabase();

    await db.delete('tasks_table');

    // Masukkan list baru ke database lokal
    for (final task in taskList) {
      await db.insert('tasks_table', {
        'id': task.id,
        'title': task.title,
        'category': task.category.name,
        'isDone': task.isDone ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Ganti list task di provider saat ini
    state = taskList;
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>(
  (ref) => TasksNotifier(),
);

final tasksSyncron = Provider((ref) {});
