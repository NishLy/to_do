import 'package:to_do/model/task_list.dart';
import 'package:flutter/material.dart';
import 'package:to_do/helpers/todo.dart';

class TodoLists extends StatefulWidget {
  final bool isEditable;
  final int? idTask;
  final List<Todo>? list;
  final Function? onCreateTodo;
  const TodoLists(
      {super.key,
      required this.isEditable,
      this.list,
      this.idTask,
      this.onCreateTodo});

  @override
  State<TodoLists> createState() => _TodoListsState();
}

class _TodoListsState extends State<TodoLists> {
  List<Todo> uncheckedEntries = [];
  List<Todo> checkedEntries = [];
  bool showChecked = false;
  int? idTask;

  @override
  void initState() {
    super.initState();
    if (widget.idTask != null) idTask = widget.idTask!;
    if (widget.list != null) {
      uncheckedEntries = List<Todo>.from(
          widget.list!.where((element) => element.isChecked == false));
      checkedEntries = List<Todo>.from(
          widget.list!.where((element) => element.isChecked == true));
    }
  }

  TextEditingController newTaskController = TextEditingController();

  void _onChangeStatusTodo(int index, bool value) {
    setState(() {
      if (value) {
        // int index = uncheckedEntries.indexWhere((element) => element.id == id);
        uncheckedEntries[index].isChecked = value;
        DatabaseTodoHelper.instance.updateTodo(uncheckedEntries[index]);
        uncheckedEntries[index].isChecked = value;
        checkedEntries.add(uncheckedEntries[index]);
        uncheckedEntries.removeAt(index);
      } else {
        // int index = checkedEntries.indexWhere((element) => element.id == id);
        checkedEntries[index].isChecked = value;
        DatabaseTodoHelper.instance.updateTodo(checkedEntries[index]);
        checkedEntries[index].isChecked = value;
        uncheckedEntries.add(checkedEntries[index]);
        checkedEntries.removeAt(index);
      }
    });
  }

  void _onChangeTodoTitle(Todo todo) {
    DatabaseTodoHelper.instance.updateTodo(todo);
  }

  void _createTodo() async {
    if (idTask == null && widget.onCreateTodo != null) {
      int? createdTaskId = await widget.onCreateTodo!();
      idTask = createdTaskId!;
    }

    Todo todo = Todo(
      title: newTaskController.text,
      idTask: idTask!,
      isChecked: false,
    );

    int result = await DatabaseTodoHelper.instance.insertTask(todo);

    List<Todo> newTodo = uncheckedEntries;
    // if (result != 0) {
    //   newTodo.add(todo);
    // }

    if (result != 0) {
      newTodo = List.from(
          await DatabaseTodoHelper.instance.getTodosAssoc(idTask!) ?? []);
      newTodo =
          List.from(newTodo.where((element) => element.isChecked == false));
    }

    setState(() {
      uncheckedEntries = newTodo;
      newTaskController.text = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border.fromBorderSide(
              BorderSide(width: 1, color: Colors.black38)),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      padding: const EdgeInsets.all(10),
      child: Column(children: [
        SizedBox(
            child: ListView.separated(
                itemCount: uncheckedEntries.length,
                shrinkWrap: true,
                separatorBuilder: (context, index) => const SizedBox(
                      height: 5,
                    ),
                itemBuilder: (context, index) {
                  TextEditingController oldTaskController =
                      TextEditingController();
                  oldTaskController.text = uncheckedEntries[index].title;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20,
                        child: TodoCheckBox(
                          id: uncheckedEntries[index].id!,
                          check: uncheckedEntries[index].isChecked,
                          onChange: ((p0, p1) =>
                              _onChangeStatusTodo(index, p1)),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: TextField(
                        decoration:
                            const InputDecoration(border: InputBorder.none),
                        maxLines: widget.isEditable ? null : 5,
                        minLines: 1,
                        readOnly: widget.isEditable ? false : true,
                        keyboardType: TextInputType.text,
                        controller: oldTaskController,
                        onSubmitted: ((value) {
                          setState(() {
                            uncheckedEntries[index].title =
                                oldTaskController.text;
                            _onChangeTodoTitle(uncheckedEntries[index]);
                          });
                        }),
                        style: !uncheckedEntries[index].isChecked
                            ? null
                            : const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                decoration: TextDecoration.lineThrough),
                      ))
                    ],
                  );
                })),
        if (checkedEntries.isNotEmpty)
          GestureDetector(
              onTap: () => setState(() {
                    showChecked = !showChecked;
                  }),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(showChecked
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded),
                  const SizedBox(
                    width: 10,
                  ),
                  Text('${checkedEntries.length} Ticked Item'),
                ],
              )),
        if (checkedEntries.isNotEmpty && showChecked)
          SizedBox(
              child: ListView.separated(
                  itemCount: checkedEntries.length,
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => const SizedBox(
                        height: 5,
                      ),
                  itemBuilder: (context, index) {
                    TextEditingController oldTaskController =
                        TextEditingController();
                    oldTaskController.text = checkedEntries[index].title;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                          child: TodoCheckBox(
                            id: checkedEntries[index].id!,
                            check: checkedEntries[index].isChecked,
                            onChange: ((p0, p1) =>
                                _onChangeStatusTodo(index, p1)),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: TextField(
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                          maxLines: widget.isEditable ? null : 5,
                          minLines: 1,
                          onSubmitted: ((value) {
                            setState(() {
                              checkedEntries[index].title =
                                  oldTaskController.text;
                              _onChangeTodoTitle(checkedEntries[index]);
                            });
                          }),
                          readOnly: widget.isEditable ? false : true,
                          keyboardType: TextInputType.text,
                          controller: oldTaskController,
                          style: !checkedEntries[index].isChecked
                              ? null
                              : const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  decoration: TextDecoration.lineThrough),
                        ))
                      ],
                    );
                  })),
        if (widget.isEditable)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  child: Icon(Icons.add),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: TextField(
                  decoration:
                      const InputDecoration.collapsed(hintText: "Add New Task"),
                  maxLines: null,
                  readOnly: widget.isEditable ? false : true,
                  controller: newTaskController,
                  keyboardType: TextInputType.text,
                  onSubmitted: (value) => _createTodo(),
                  minLines: 1,
                )),
                if (newTaskController.text.isNotEmpty)
                  IconButton(
                      onPressed: () => _createTodo(),
                      icon: const Icon(Icons.check))
              ],
            ),
          )
      ]),
    );
  }
}

class TodoCheckBox extends StatefulWidget {
  final bool check;
  final int id;

  final void Function(int, bool) onChange;
  const TodoCheckBox(
      {super.key,
      required this.check,
      required this.onChange,
      required this.id});

  @override
  State<TodoCheckBox> createState() => _TodoCheckBoxState();
}

class _TodoCheckBoxState extends State<TodoCheckBox> {
  bool? isChecked;
  @override
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: widget.check,
      onChanged: (bool? value) {
        widget.onChange(widget.id, value!);
      },
    );
  }
}
