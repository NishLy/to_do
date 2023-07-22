import 'package:flutter/material.dart';
import 'package:to_do/components/label_chips.dart';
import 'package:to_do/components/task_list.dart';
import 'package:intl/intl.dart';
import 'package:to_do/screens/label.dart';
import '../helpers/tasks.dart';
import '../model/task.dart';

class AddAndEditTask extends StatefulWidget {
  final int? taskId;
  const AddAndEditTask({super.key, this.taskId});

  @override
  State<AddAndEditTask> createState() => _AddAndEditTaskState();
}

class _AddAndEditTaskState extends State<AddAndEditTask> {
  TextEditingController newTitleController = TextEditingController();
  TextEditingController newNoteController = TextEditingController();

  late Future<Task?> _task;
  bool isNote = false;
  bool isTodos = false;
  int? taskId;
  Task? task;

  int indexNav = 0;

  @override
  void initState() {
    super.initState();
    _task = DatabaseTaskHelper.instance.getTaskById(widget.taskId);
  }

  void updateData() {
    setState(() {
      if (widget.taskId != null) {
        _task = DatabaseTaskHelper.instance.getTaskById(widget.taskId);
      }
    });
  }

  Future<int?> _createTask() async {
    Task newTask = Task(
      title:
          newTitleController.text.isNotEmpty ? newTitleController.text : null,
      date: DateTime.now(),
      note: newNoteController.text.isNotEmpty ? newNoteController.text : null,
    );
    int result = await DatabaseTaskHelper.instance.insert(newTask);
    if (result != 0) {
      task = newTask;
      taskId = await DatabaseTaskHelper.instance.getLastRowId();
    }
    return taskId;
  }

  Future<void> _updateTask(Task task) async {
    task.updatedAt = DateTime.now();
    task.title =
        newTitleController.text.isNotEmpty ? newTitleController.text : null;
    task.note =
        newNoteController.text.isNotEmpty ? newNoteController.text : null;
    DatabaseTaskHelper.instance.updateTask(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          // title: const Text("Add Task"),
          actions: [
            IconButton(
                onPressed: (() {
                  if (task != null) {
                    setState(() {
                      task!.isPinned = !task!.isPinned;
                      DatabaseTaskHelper.instance.updateTask(task!);
                    });
                  }
                }),
                icon: Icon(task != null
                    ? task!.isPinned
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined
                    : Icons.push_pin_outlined))
          ],
        ),
        body: FutureBuilder(
            future: _task,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              task = snapshot.data;

              if (task != null) {
                taskId = task!.id;
                newTitleController.text =
                    task?.title != null ? task!.title! : "";
                newNoteController.text = task?.note != null ? task!.note! : "";

                if (!isNote && !isTodos) {
                  isTodos = task!.tasks != null ? true : false;
                  isNote = (task!.note != null && task!.note!.isNotEmpty)
                      ? true
                      : false;
                }
              }

              return ListView(padding: const EdgeInsets.all(15), children: [
                FocusScope(
                  onFocusChange: (value) async {
                    if (!value) {
                      task =
                          await DatabaseTaskHelper.instance.getTaskById(taskId);
                      setState(() {
                        taskId != null ? _updateTask(task!) : _createTask();
                      });
                    }
                  },
                  child: TextField(
                    decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        hintText: "Title",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    controller: newTitleController,
                    onSubmitted: (value) =>
                        taskId != null ? _updateTask(task!) : _createTask(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (isNote)
                  Expanded(
                    child: FocusScope(
                      onFocusChange: (value) {
                        if (!value) {
                          taskId != null ? _updateTask(task!) : _createTask();
                        }
                      },
                      child: TextField(
                        decoration: const InputDecoration(
                            hintText: "note",
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                        keyboardType: TextInputType.multiline,
                        controller: newNoteController,
                        maxLines: null,
                        minLines: 1,
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
                if (isTodos)
                  TodoLists(
                    isEditable: true,
                    idTask: task != null ? task!.id : null,
                    onCreateTodo: _createTask,
                    list: task != null
                        ? task!.tasks != null
                            ? task!.tasks!
                            : null
                        : null,
                  ),
                const SizedBox(
                  height: 10,
                ),
                if (task != null) LabelGridChips(labelIds: task!.idLabels),
                const SizedBox(
                  height: 20,
                ),
              ]);
            }),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(90, 71, 71, 71),
                blurRadius: 4,
                spreadRadius: 2,
                offset: Offset(0, -2), // Shadow position
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: (() {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            height: 100,
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              // borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(90, 71, 71, 71),
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                  offset: Offset(0, -2), // Shadow position
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                if (!isNote)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isNote = true;
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Row(
                                      children: const [
                                        Icon(Icons.note_add),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Note",
                                          style: TextStyle(fontSize: 18),
                                        )
                                      ],
                                    ),
                                  ),
                                const SizedBox(
                                  height: 20,
                                ),
                                if (!isTodos)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isTodos = true;
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Row(
                                      children: const [
                                        Icon(Icons.check_box_outlined),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Tick Boxes",
                                          style: TextStyle(fontSize: 18),
                                        )
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          );
                        });
                  }),
                  icon: const Icon(Icons.add_box_outlined)),
              Text(
                  'Edited at ${DateFormat('yyyy-MM-dd HH-mm').format(task?.updatedAt ?? DateTime.now())}'),
              IconButton(
                  onPressed: (() {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            height: 100,
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              // borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(90, 71, 71, 71),
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                  offset: Offset(0, -2), // Shadow position
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (task != null)
                                  GestureDetector(
                                    onTap: () {
                                      if (task != null) {
                                        DatabaseTaskHelper.instance
                                            .deleteTask(task!.id!);
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                      }
                                    },
                                    child: Row(
                                      children: const [
                                        Icon(Icons.delete_outline),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Delete",
                                          style: TextStyle(fontSize: 18),
                                        )
                                      ],
                                    ),
                                  ),
                                const SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LabelList(
                                          task: task!,
                                          onUpdate: updateData,
                                        ),
                                      )),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.label_outline_rounded),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Labels",
                                        style: TextStyle(fontSize: 18),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        });
                  }),
                  icon: const Icon(Icons.menu))
            ],
          ),
        ));
  }
}
