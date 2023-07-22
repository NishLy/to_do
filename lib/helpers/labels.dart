import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do/model/label.dart';

class DatabaseLabelHelper {
  static final DatabaseLabelHelper instance = DatabaseLabelHelper._instance();
  static Database? _db;
  DatabaseLabelHelper._instance();
  List<Label>? lastLabelQueryCache;

  String labelTabel = 'labels_table';
  String colId = 'id';
  String colTitle = 'title';

  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $labelTabel($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT NOT NULL)',
    );
  }

  Future<List<Label>> getLabelCache() async {
    if (lastLabelQueryCache == null) {
      await getAllLabels();
    }
    return lastLabelQueryCache!;
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}/todo_list.db';
    final todoListDb =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todoListDb;
  }

  Future<Database> get db async {
    if (_db == null) return _db = await _initDb();
    return _db!;
  }

  Future<List<Map<String, dynamic>>> getLabelMap() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(labelTabel);
    return result;
  }

  Future<List<Label>> getAllLabels() async {
    final List<Map<String, dynamic>> taskMapList = await getLabelMap();
    final List<Label> labels = [];
    for (var taskMap in taskMapList) {
      labels.add(Label.fromMap(taskMap));
    }
    lastLabelQueryCache = labels;
    return labels;
  }

  Future<int> insert(Label task) async {
    Database db = await this.db;
    final int result = await db.insert(labelTabel, task.toMap());
    return result;
  }

  Future<int> insertBatch(List<Label> labels) async {
    int result = 0;
    for (var label in labels) {
      result = result + await insert(label);
    }
    return result;
  }

  Future<int> updateLabel(Label task) async {
    Database db = await this.db;
    final int result = await db.update(
      labelTabel,
      task.toMap(),
      where: '$colId = ?',
      whereArgs: [task.id],
    );
    return result;
  }

  Future<int> deleteLabel(int id) async {
    Database db = await this.db;
    final int result = await db.delete(
      labelTabel,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return result;
  }

  Future<int> deleteAllLabel() async {
    Database db = await this.db;
    final int result = await db.delete(labelTabel);
    return result;
  }
}
