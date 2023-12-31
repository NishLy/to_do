import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:to_do/components/drawer.dart';
import 'package:to_do/components/label_chips.dart';
import 'package:to_do/components/task_list.dart';
import 'package:to_do/helpers/account.dart';
import 'package:to_do/helpers/tasks.dart';
import 'package:to_do/model/task.dart';
import 'package:to_do/screens/account.dart';
import 'package:to_do/screens/add_and_edit.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List<Task>>? _tasks;
  int? filteredLabelId;

  @override
  void initState() {
    super.initState();
    _tasks = DatabaseTaskHelper.instance.getTaskList();
  }

  Future<void> _updateTaskList() async {
    setState(() {
      _tasks = DatabaseTaskHelper.instance.getTaskList();
    });
  }

  void _onChangeFilterLabel(int? labelId) {
    setState(() {
      filteredLabelId = labelId;
      if (labelId == null) {
        _tasks = DatabaseTaskHelper.instance.getTaskList();
        return;
      }
      _tasks = DatabaseTaskHelper.instance.getTaskByLabel(labelId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todos"),
        actions: [
          FutureBuilder(
              future: AccountHelper.instance.getUserData(),
              builder: ((context, snapshot) => CircleAvatar(
                    backgroundImage: snapshot.hasData
                        ? NetworkImage(snapshot.data!.photoURL ?? '')
                        : null,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(AccountPopup()),
                      child: snapshot.hasData
                          ? null
                          : const Icon(Icons.person_outline_rounded),
                    ),
                  ))),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _updateTaskList,
        child: FutureBuilder(
          future: _tasks,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return ListView(
                  children: const [
                    ListTile(
                      title: Text("No Tasks"),
                    )
                  ],
                );
              }

              List<Widget> pinnedTasksWidget = [];
              List<Widget> unpinnedTaskWidget = [];

              for (var task in snapshot.data!) {
                if (task.isPinned) {
                  pinnedTasksWidget.add(CardTask(
                    key: ValueKey(task.id),
                    onLeave: _updateTaskList,
                    task: task,
                  ));
                } else {
                  unpinnedTaskWidget.add(CardTask(
                    key: ValueKey(task.id),
                    onLeave: _updateTaskList,
                    task: task,
                  ));
                }
              }

              return ListView(padding: const EdgeInsets.all(10), children: [
                if (pinnedTasksWidget.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: const Text(
                      "Pinned",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                if (pinnedTasksWidget.isNotEmpty)
                  StaggeredGrid.count(
                      key: ValueKey(pinnedTasksWidget.length),
                      crossAxisCount: 2,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      children: pinnedTasksWidget),
                if (unpinnedTaskWidget.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: const Text(
                      "Others",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                if (unpinnedTaskWidget.isNotEmpty)
                  StaggeredGrid.count(
                      key: ValueKey(unpinnedTaskWidget.length),
                      crossAxisCount: 2,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      children: unpinnedTaskWidget)
              ]);
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddAndEditTask()));

            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              content: const Text("Successfully Adding Data"),
            ));
            _updateTaskList();
          },
          child: const Icon(Icons.add)),
      drawer: MainDrawer(
          onChangeLabelFilter: _onChangeFilterLabel,
          seletedId: filteredLabelId),
    );
  }
}

class CardTask extends StatelessWidget {
  final Task task;
  final Function() onLeave;
  const CardTask({super.key, required this.task, required this.onLeave});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: ((context) => AddAndEditTask(
                      taskId: task.id!,
                    ))));
        onLeave();
        // ignore: use_build_context_synchronously
      }),
      child: Card(
          elevation: 0,
          shape: const RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.black38,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.title != null)
                    Text(
                      task.title!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  if (task.note != null)
                    const SizedBox(
                      height: 10,
                    ),
                  if (task.note != null)
                    Text(
                      task.note!,
                      maxLines: 20,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (task.tasks != null)
                    const SizedBox(
                      height: 10,
                    ),
                  if (task.tasks != null)
                    SizedBox(
                      child: TodoLists(
                        key: ValueKey(task.id),
                        isEditable: false,
                        idTask: task.id!,
                        list: task.tasks,
                      ),
                    ),
                  if (task.idLabels.isNotEmpty)
                    const SizedBox(
                      height: 10,
                    ),
                  if (task.idLabels.isNotEmpty)
                    LabelGridChips(labelIds: task.idLabels)
                ],
              ))),
    );
  }
}
