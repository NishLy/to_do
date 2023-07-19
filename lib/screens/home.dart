import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:to_do/components/drawer.dart';
import 'package:to_do/components/label_chips.dart';
import 'package:to_do/components/task_list.dart';
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

  void _onChangeFilterLabel(int labelId) {
    setState(() {
      _tasks = DatabaseTaskHelper.instance.getTaskByLabel(labelId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todos"),
        actions: [
          CircleAvatar(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(AccountPopup()),
              child: const Text("G"),
            ),
          ),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: FutureBuilder(
        future: _tasks,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text("No Tasks"),
              );
            }

            List<Widget> pinnedTasksWidget = [];
            List<Widget> unpinnedTaskWidget = [];

            for (var task in snapshot.data!) {
              if (task.isPinned) {
                pinnedTasksWidget.add(CardTask(
                  key: ValueKey(task.id),
                  task: task,
                ));
              } else {
                unpinnedTaskWidget.add(CardTask(
                  key: ValueKey(task.id),
                  task: task,
                ));
              }
            }

            return RefreshIndicator(
                onRefresh: _updateTaskList,
                child: ListView(padding: const EdgeInsets.all(10), children: [
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
                ]));
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddAndEditTask()));
          },
          child: const Icon(Icons.add)),
      drawer: MainDrawer(onChangeLabelFilter: _onChangeFilterLabel),
    );
  }
}

class CardTask extends StatelessWidget {
  final Task task;
  const CardTask({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((context) => AddAndEditTask(
                    task: task,
                  )))),
      child: Card(
          elevation: 0,
          shape: const RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.black,
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
