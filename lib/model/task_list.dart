class Todo {
  int? id;
  int idTask;
  String title;
  bool isChecked;

  Todo(
      {required this.title,
      required this.idTask,
      required this.isChecked,
      this.id});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['id_task'] = idTask;
    map['isChecked'] = isChecked ? 1 : 0;
    return map;
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
        id: map['id'],
        title: map['title'],
        idTask: map['id_task'],
        isChecked: map['isChecked'] == 1 ? true : false);
  }
}
