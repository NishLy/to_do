import 'package:to_do/helpers/tasks.dart';
import 'package:to_do/model/label.dart';
import 'package:to_do/model/task.dart';
import 'package:to_do/model/todo.dart';

class UserData {
  final String uid;
  final String email;
  final List<Task> tasks;
  final List<Label> labels;
  final List<Todo> todos;
  DateTime? lastChange;
  UserData({
    required this.uid,
    required this.email,
    required this.tasks,
    required this.labels,
    required this.todos,
  });

  UserData.fromCloud(
      {required this.uid,
      required this.email,
      required this.tasks,
      required this.labels,
      required this.todos,
      required this.lastChange});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map['email'] = email;
    map['uid'] = uid;
    map['tasks'] = tasks.map((e) => e.toMap());
    map['labels'] = labels.map((e) => e.toMap());
    map['todos'] = todos.map((e) => e.toMap());
    map['lastChange'] = DateTime.now().toIso8601String();
    return map;
  }

  static Future<UserData> fromMap(Map<String, dynamic> map) async {
    List<dynamic> tasksMap = map['tasks'];
    List<dynamic> todosMap = map['todos'];
    List<dynamic> labelsMap = map['labels'];
    List<Task> tasks = [];

    for (var map in tasksMap) {
      tasks.add(await Task.taskFromID(map));
    }

    return UserData.fromCloud(
        email: map['email'],
        uid: map['uid'],
        tasks: tasks,
        labels: List.from(labelsMap.map((e) => Label.fromMap(e))),
        todos: List.from(todosMap.map((e) => Todo.fromMap(e))),
        lastChange: DateTime.parse(map['lastChange']));
  }
}
