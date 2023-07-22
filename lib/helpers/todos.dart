import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do/model/todo.dart';

class DatabaseTodoHelper {
  static final DatabaseTodoHelper instance = DatabaseTodoHelper._instance();
  static Database? _db;
  DatabaseTodoHelper._instance();

  String todoTable = 'todos_table';
  String colId = 'id';
  String colTitle = 'title';
  String colIdTask = 'id_task';
  String colIsChecked = 'isChecked';

  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $todoTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colIdTask INTEGER REFERENCES tasks(id),  $colIsChecked INTEGER)',
    );
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}/todo_list.db';
    final todoListDb =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todoListDb;
  }

  Future<Database> get db async {
    // ignore: prefer_conditional_assignment
    if (_db == null) return _db = await _initDb();
    return _db!;
  }

  Future<List<Map<String, dynamic>>> getTaskMapListByIdTask(int idTask) async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT * FROM $todoTable WHERE id_task = $idTask');
    return result;
  }

  Future<List<Todo>?> getTodosAssoc(int idTask) async {
    final List<Map<String, dynamic>> taskMapList =
        await getTaskMapListByIdTask(idTask);
    if (taskMapList.isEmpty) return null;
    final List<Todo> todos = [];
    for (var taskMap in taskMapList) {
      todos.add(Todo.fromMap(taskMap));
    }
    return todos;
  }

  Future<List<Todo>> getTodos() async {
    Database db = await this.db;
    List<Map<String, dynamic>> todosMap = await db.query(todoTable);
    final List<Todo> todos = [];
    for (var todoMap in todosMap) {
      todos.add(Todo.fromMap(todoMap));
    }
    return todos;
  }

  Future<int> insert(Todo task) async {
    Database db = await this.db;
    final int result = await db.insert(todoTable, task.toMap());
    return result;
  }

  Future<int> insertBatch(List<Todo> todos) async {
    int result = 0;
    for (var todo in todos) {
      result = result + await insert(todo);
    }
    return result;
  }

  Future<int> updateTodo(Todo task) async {
    Database db = await this.db;
    final int result = await db.update(
      todoTable,
      task.toMap(),
      where: '$colId = ?',
      whereArgs: [task.id],
    );
    return result;
  }

  Future<int> deleteTask(int id) async {
    Database db = await this.db;
    final int result = await db.delete(
      todoTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return result;
  }

  Future<int> deleteAllTodo() async {
    Database db = await this.db;
    final int result = await db.delete(todoTable);
    return result;
  }
}
