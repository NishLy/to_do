import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do/model/task.dart';

class TaskID {
  final int id;
  TaskID({required this.id});
  factory TaskID.fromMap(Map<String, dynamic> map) {
    return TaskID(id: map['last_id']);
  }
}

class DatabaseTaskHelper {
  static final DatabaseTaskHelper instance = DatabaseTaskHelper._instance();
  static Database? _db;
  DatabaseTaskHelper._instance();

  List<Task> lastQueryTasks = [];

  String taskTable = 'tasks_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colIsCompleted = 'isCompleted';
  String colIsPinned = 'isPinned';
  String colCreateAt = 'createdAt';
  String colUpdatedAt = 'updatedAt';
  String colNote = 'note';
  String colLabels = 'labels';

  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $taskTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT,$colDate, $colIsCompleted INTEGER,$colCreateAt TEXT,$colUpdatedAt TEXT,$colIsPinned INTEGER,$colNote TEXT,$colLabels TEXT)',
    );

    void createTodoTable() async {
      String todoTable = 'todos_table';
      String colId = 'id';
      String colTitle = 'title';
      String colIdTask = 'id_task';
      String colIsChecked = 'isChecked';

      await db.execute(
        'CREATE TABLE $todoTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colIdTask INTEGER REFERENCES tasks(id),  $colIsChecked INTEGER)',
      );
    }

    void createLabelTable() async {
      String labelTabel = 'labels_table';
      String colId = 'id';
      String colTitle = 'title';

      await db.execute(
        'CREATE TABLE $labelTabel($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT NOT NULL)',
      );
    }

    createTodoTable();
    createLabelTable();
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}/todo_list.db';
    final todoListDb =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todoListDb;
  }

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(taskTable);
    return result;
  }

  Future<List<Task>> getTaskList() async {
    final List<Map<String, dynamic>> taskMapList = await getTaskMapList();
    final List<Task> tasks = [];
    for (var taskMap in taskMapList) {
      tasks.add(await Task.taskFromID(taskMap));
    }
    tasks.sort(((a, b) => b.createdAt.compareTo(a.createdAt)));
    lastQueryTasks = tasks;
    return tasks;
  }

  Future<Task?> getTaskById(int? id) async {
    if (id == null) return null;
    Database db = await this.db;
    final map =
        await db.rawQuery("SELECT * FROM $taskTable WHERE id = $id LIMIT 1");
    final Task task = await Task.taskFromID(map.first);
    return task;
  }

  Future<List<Task>> getTaskByLabel(int labelID) async {
    List<Task> tasks = [];
    for (var task in lastQueryTasks) {
      int index = task.idLabels.indexOf(labelID);
      if (index != -1) tasks.add(task);
    }
    return tasks;
  }

  Future<int> getLastRowId() async {
    Database db = await this.db;
    final map = await db.rawQuery("SELECT last_insert_rowid() as last_id");
    final id = TaskID.fromMap(map.first).id;
    return id;
  }

  Future<int> insert(Task task) async {
    Database db = await this.db;
    final int result = await db.insert(taskTable, task.toMap());
    return result;
  }

  Future<int> insertBatch(List<Task> tasks) async {
    int result = 0;
    for (var task in tasks) {
      result = result + await insert(task);
    }
    return result;
  }

  Future<int> updateTask(Task task) async {
    Database db = await this.db;
    final int result = await db.update(
      taskTable,
      task.toMap(),
      where: '$colId = ?',
      whereArgs: [task.id],
    );
    return result;
  }

  Future<int> deleteTask(int id) async {
    Database db = await this.db;
    final int result = await db.delete(
      taskTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return result;
  }

  Future<int> deleteAllTask() async {
    Database db = await this.db;
    final int result = await db.delete(taskTable);
    return result;
  }
}
