import 'dart:convert';

import 'package:to_do/model/todo.dart';
import 'package:to_do/helpers/todos.dart';

class Task {
  int? id;
  String? title;
  String? note;
  List<Todo>? tasks;
  DateTime date;
  bool isCompleted = false;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  bool isPinned = false;
  List<String> labels = [];

  Task({required this.title, required this.date, this.note, this.tasks});

  Task.withID(
      {required this.title,
      required this.date,
      required this.isCompleted,
      required this.isPinned,
      required this.updatedAt,
      required this.createdAt,
      required this.labels,
      this.id,
      this.note,
      this.tasks});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['note'] = note;
    map['date'] = date.toIso8601String();
    map['createdAt'] = date.toIso8601String();
    map['updatedAt'] = date.toIso8601String();
    map['isCompleted'] = isCompleted ? 1 : 0;
    map['isPinned'] = isPinned ? 1 : 0;
    map['labels'] = labels.toString();
    return map;
  }

  static Future<Task> taskFromID(Map<String, dynamic> map) async {
    return Task.withID(
        id: map['id'],
        title: map['title'],
        date: DateTime.parse(map['date']),
        createdAt: DateTime.parse(map['date']),
        updatedAt: DateTime.parse(map['date']),
        note: map['note'],
        isCompleted: map['isCompleted'] == 1 ? true : false,
        isPinned: map['isPinned'] == 1 ? true : false,
        labels: json.encode(map['labels']).split(","),
        tasks: await DatabaseTodoHelper.instance.getTodosAssoc(map['id']));
  }
}
