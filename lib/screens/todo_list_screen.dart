import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list/model/task.dart';
import 'package:todo_list/providers/tasks_provider.dart';
import 'package:todo_list/widgets/new_task.dart';
import 'package:todo_list/widgets/task_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> {
  late Future<void> _todoListFuture;
  var isSync = false;
  var isLoad = false;

  @override
  void initState() {
    super.initState();
    _todoListFuture = ref.read(tasksProvider.notifier).loadTasks();
  }

  // Membuat modal bottom sheet untuk tambah tugas baru
  final titleFocusNode = FocusNode();

  void _openAddTaskOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return NewTask(titleFocusNode);
      },
    );
  }

  void showSnackbarSaveDataDone(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil menyimpan data !', textAlign: TextAlign.center),
      ),
    );
  }

  void showSnackbarLoadDataDone(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Berhasil mendapatkan data !',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> saveDataFirebase(List<Task> tasks, BuildContext context) async {
    final url = Uri.https(
      'todo-list-c6315-default-rtdb.firebaseio.com',
      'todo-list.json',
    );

    try {
      // Hapus seluruh data di Firebase
      final response = await http.delete(url);
      if (response.statusCode != 200) {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal terhubung dan menghapus seluruh data di Firebase',
            ),
          ),
        );
        return;
      }

      // Masukkan seluruh data lokal ke firebase
      for (final task in tasks) {
        await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'id': task.id,
            'title': task.title,
            'category': task.category.name,
            'isDone': task.isDone ? '1' : '0',
          }),
        );
      }
      if (!context.mounted) {
        return;
      }
      showSnackbarSaveDataDone(context);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terjadi kesalahan, silahkan periksa koneksi internet Anda!',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  // Mengambil data dari Firebase dan ditimpakan ke database lokal
  Future<void> loadDataFirebase() async {
    final url = Uri.https(
      'todo-list-c6315-default-rtdb.firebaseio.com',
      'todo-list.json',
    );

    try {
      // Ambil data dari cloud
      final response = await http.get(url);

      // Cek apakah response berhasil
      if (response.statusCode != 200) {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal terhubung dan mengambil data ke Firebase',
              textAlign: TextAlign.center,
            ),
          ),
        );
        return;
      }

      if (response.body == 'null') {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tidak ada data yang dapat diambil',
              textAlign: TextAlign.center,
            ),
          ),
        );
        return;
      }

      final Map<String, dynamic> resData = json.decode(response.body);

      // Cek apakah terdapat data di Firebase

      final List<Task> newTaskList = [];

      for (final data in resData.entries) {
        newTaskList.add(
          Task(
            title: data.value['title'],
            category: Category.values.firstWhere(
              (cat) => cat.name == data.value['category'],
            ),
            isDone: data.value['isDone'] == '1' ? true : false,
          ),
        );

        // Delete seluruh data di lokal untuk diganti yang dari cloud (Firebase)
        ref.read(tasksProvider.notifier).replaceAll(newTaskList);

        if (!context.mounted) {
          return;
        }
        showSnackbarLoadDataDone(context);
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terjadi kesalahan, silahkan periksa koneksi internet Anda!',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  // Dialog konfirmasi untuk overwrite data ke database lokal
  Future<void> showLoadDataDialog() {
    return showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            actions: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Batal'),
                  ),
                  SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () async {
                      setState(() {
                        isLoad = true;
                      });
                      await loadDataFirebase();
                      setState(() {
                        isLoad = false;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text('Ya'),
                  ),
                ],
              ),
            ],
            content: Text(
              'Apakah Anda yakin untuk mengganti seluruh tugas di lokal?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            actionsAlignment: MainAxisAlignment.end,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskList = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Tugas'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                // Button untuk mengganti seluruh data di database dengan yang di lokal
                OutlinedButton.icon(
                  onPressed:
                      isSync
                          ? null
                          : () async {
                            setState(() {
                              isSync = true;
                            });
                            await saveDataFirebase(taskList, context);
                            setState(() {
                              isSync = false;
                            });
                          },
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                  ),
                  label:
                      isSync
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : Text(
                            'Simpan Data',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                  icon: isSync ? null : Icon(Icons.cloud_upload),
                ),
                SizedBox(width: 6),

                // Button untuk mengganti data lokal dengan database di Firebase
                IconButton(
                  icon:
                      isLoad
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                          )
                          : Icon(Icons.ad_units_outlined),
                  onPressed:
                      isLoad
                          ? null
                          : () async {
                            await showLoadDataDialog();
                          },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder(
            future: _todoListFuture,
            builder:
                (context, snapshot) =>
                    snapshot.connectionState == ConnectionState.waiting
                        ? const Center(child: CircularProgressIndicator())
                        : Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: TaskList(taskList: taskList),
                        ),
          ),

          Positioned(
            right: 30,
            bottom: 80,
            child: FloatingActionButton(
              onPressed: _openAddTaskOverlay,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
