import 'package:flutter/material.dart';
import 'package:to_do/components/label_chips.dart';
import 'package:to_do/components/task_list.dart';
import 'package:intl/intl.dart';
import 'package:to_do/screens/label.dart';
import '../helpers/tasks.dart';
import '../model/task.dart';

class AddAndEditTask extends StatefulWidget {
  final Task? task;
  const AddAndEditTask({super.key, this.task});

  @override
  State<AddAndEditTask> createState() => _AddAndEditTaskState();
}

class _AddAndEditTaskState extends State<AddAndEditTask> {
  TextEditingController newTitleController = TextEditingController();
  TextEditingController newNoteController = TextEditingController();
  bool isNote = true;
  bool isTodos = false;
  int? idTask;
  Task? task;
  int indexNav = 0;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      idTask = widget.task!.id;
      task = widget.task;
      setState(() {
        newTitleController.text = task?.title != null ? task!.title! : "";
        newNoteController.text = task?.note != null ? task!.note! : "";
        isTodos = task!.tasks != null ? true : false;
        isNote = (widget.task!.note != null && widget.task!.note!.isNotEmpty)
            ? true
            : false;
      });
    }
  }

  Future<int?> _createTask() async {
    Task newTask = Task(
      title:
          newTitleController.text.isNotEmpty ? newTitleController.text : null,
      date: DateTime.now(),
      note: newNoteController.text.isNotEmpty ? newNoteController.text : null,
    );
    int result = await DatabaseTaskHelper.instance.insertTask(newTask);
    if (result != 0) {
      task = newTask;
      idTask = await DatabaseTaskHelper.instance.getLastRowId();
    }
    return idTask;
  }

  Future<void> _updateTask(Task task) async {
    task.updatedAt = DateTime.now();
    task.title =
        newTitleController.text.isNotEmpty ? newTitleController.text : null;

    task.note =
        newNoteController.text.isNotEmpty ? newNoteController.text : null;

    int result = await DatabaseTaskHelper.instance.updateTask(task);
    setState(() {
      if (result != 0) task = task;
    });
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
        body: ListView(padding: const EdgeInsets.all(15), children: [
          TextField(
            decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                hintText: "Title",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)))),
            controller: newTitleController,
            onSubmitted: (value) =>
                idTask != null ? _updateTask(task!) : _createTask(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          if (isNote)
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                    hintText: "note",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))

                    // InputBorder(borderSide: BorderSide(color: Colors.black38)),
                    ),
                onChanged: (value) => setState(() {}),
                keyboardType: TextInputType.multiline,
                controller: newNoteController,
                maxLines: null,
                minLines: 1,
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
          LabelGridChips(labelIds: task!.idLabels),
          const SizedBox(
            height: 20,
          ),
          if (isNote)
            MaterialButton(
              color: Colors.blueAccent,
              onPressed: (() {
                idTask != null ? _updateTask(task!) : _createTask();
                Navigator.of(context).pop();
              }),
              child: const Text('Save'),
            )
        ]),
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
