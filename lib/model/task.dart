import 'package:uuid/uuid.dart';

enum Category { noCategory, task, school, work, personal, shopping, others }

// Mengubah enum Category menjadi bahasa indonesia untuk ditampilkan
String categoryToIndonesian(Category category) {
  switch (category) {
    case Category.noCategory:
      return 'Tanpa Kategori';
    case Category.work:
      return 'Pekerjaan';
    case Category.personal:
      return 'Pribadi';
    case Category.shopping:
      return 'Belanja';
    case Category.task:
      return 'Tugas';
    case Category.school:
      return 'Sekolah';
    case Category.others:
      return 'Lainnya';
  }
}

const uuid = Uuid();

class Task {
  Task({
    required this.title,
    required this.category,
    this.isDone = false,
    String? id,
  }) : id = id ?? uuid.v4();

  final String id;
  final String title;
  final Category category;
  bool isDone;

  Task copyWith({String? title, Category? category, bool? isDone}) {
    return Task(
      title: title ?? this.title,
      category: category ?? this.category,
      isDone: isDone ?? this.isDone,
    );
  }
}
