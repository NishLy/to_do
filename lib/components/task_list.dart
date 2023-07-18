import 'package:to_do/model/todo.dart';
import 'package:flutter/material.dart';
import 'package:to_do/helpers/todos.dart';

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
  List<Todo> todos = [];
  bool showChecked = false;
  int? idTask;

  @override
  void initState() {
    super.initState();
    if (widget.idTask != null) idTask = widget.idTask!;
    if (widget.list != null) {
      todos = widget.list!;
    }
  }

  TextEditingController newTaskController = TextEditingController();

  void _onChangeStatusTodo(Todo todo) {
    DatabaseTodoHelper.instance.updateTodo(todo);
    int index = todos.indexWhere((element) => element.id == todo.id);

    setState(() {
      todos[index] = todo;
    });
  }

  void _onChangeTodoTitle(Todo todo) {
    setState(() {
      DatabaseTodoHelper.instance.updateTodo(todo);
    });
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

    List<Todo> newTodo = todos;

    if (result != 0) {
      newTodo = List.from(
          await DatabaseTodoHelper.instance.getTodosAssoc(idTask!) ?? []);
    }

    setState(() {
      todos = newTodo;
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
      child: Builder(builder: (context) {
        List checkedTodos =
            List.from(todos.where((element) => element.isChecked == true));
        List uncheckedTodos =
            List.from(todos.where((element) => element.isChecked == false));
        return Column(children: [
          SizedBox(
              child: ListView.separated(
                  itemCount: uncheckedTodos.length,
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => const SizedBox(
                        height: 5,
                      ),
                  itemBuilder: (context, index) {
                    return TodoField(
                        index: index,
                        isReadonly: widget.isEditable ? true : false,
                        todo: uncheckedTodos[index],
                        onChangeTodoTitle: _onChangeTodoTitle,
                        onChangeTodoStatus: _onChangeStatusTodo);
                  })),
          if (checkedTodos.isNotEmpty)
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
                    Text('${checkedTodos.length} Ticked Item'),
                  ],
                )),
          if (checkedTodos.isNotEmpty && showChecked)
            SizedBox(
                child: ListView.separated(
                    itemCount: checkedTodos.length,
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => const SizedBox(
                          height: 5,
                        ),
                    itemBuilder: (context, index) {
                      TextEditingController oldTaskController =
                          TextEditingController();
                      oldTaskController.text = checkedTodos[index].title;
                      return TodoField(
                          index: index,
                          isReadonly: widget.isEditable ? true : false,
                          todo: checkedTodos[index],
                          onChangeTodoTitle: _onChangeTodoTitle,
                          onChangeTodoStatus: _onChangeStatusTodo);
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
                    decoration: const InputDecoration.collapsed(
                        hintText: "Add New Task"),
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
        ]);
      }),
    );
  }
}

class TodoField extends StatefulWidget {
  final bool isReadonly;
  final Todo todo;
  final int index;

  final void Function(Todo) onChangeTodoStatus;
  final void Function(Todo) onChangeTodoTitle;

  const TodoField({
    super.key,
    required this.todo,
    required this.isReadonly,
    required this.onChangeTodoStatus,
    required this.onChangeTodoTitle,
    required this.index,
  });

  @override
  State<TodoField> createState() => _TodoFieldState();
}

class _TodoFieldState extends State<TodoField> {
  TextEditingController oldTaskController = TextEditingController();
  late Todo todo;
  bool showDeleteSuffix = false;

  @override
  void initState() {
    super.initState();
    todo = widget.todo;
    oldTaskController.text = todo.title;
  }

  bool? isChecked;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Checkbox(
            value: todo.isChecked,
            onChanged: (bool? value) {
              todo.isChecked = value!;
              widget.onChangeTodoStatus(todo);
            },
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
            child: TextField(
          decoration: const InputDecoration(border: InputBorder.none),
          maxLines: widget.isReadonly ? null : 5,
          minLines: 1,
          onSubmitted: ((value) {
            setState(() {
              todo.title = oldTaskController.text;
              widget.onChangeTodoTitle(todo);
            });
          }),
          readOnly: widget.isReadonly ? false : true,
          keyboardType: TextInputType.text,
          controller: oldTaskController,
          style: todo.isChecked
              ? null
              : const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  decoration: TextDecoration.lineThrough),
        ))
      ],
    );
  }
}
