import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do/components/popup.dart';
import 'package:to_do/helpers/account.dart';
import 'package:to_do/helpers/firestore.dart';
import 'package:to_do/helpers/labels.dart';
import 'package:to_do/helpers/tasks.dart';
import 'package:to_do/helpers/todos.dart';
import 'package:to_do/model/firestore.dart';
import 'package:to_do/model/label.dart';
import 'package:to_do/model/task.dart';
import 'package:to_do/model/todo.dart';
import 'package:to_do/screens/account.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          const ListTile(
            title: Text(
              "Task Manager",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Beta 1.0.0"),
          ),
          const Divider(
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text("Backup to Firestore"),
            onTap: () async {
              User? user = await AccountHelper.instance.getUserData();
              if (user == null) {
                // ignore: use_build_context_synchronously
                Navigator.of(context).push(AccountPopup());
                return;
              }

              List<Task> tasks =
                  await DatabaseTaskHelper.instance.getTaskList();
              List<Todo> todos = await DatabaseTodoHelper.instance.getTodos();
              List<Label> labels =
                  await DatabaseLabelHelper.instance.getAllLabels();

              UserData userData = UserData(
                  uid: user.uid,
                  email: user.email ?? '',
                  tasks: tasks,
                  labels: labels,
                  todos: todos);

              FireStoreHelper.instance
                  .saveUseDataOnFireStore(user.uid, user.email ?? '', userData);

              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                content: const Text("Successfully Backup Data"),
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text("Restore from FireStore"),
            onTap: () async {
              return showDialog(
                  context: context,
                  builder: ((context) => AlertDialog(
                        title: const Text("Wipe Data"),
                        content: const Text(
                            "Restoring data from cloud will wipe out your current data"),
                        actions: [
                          TextButton(
                              onPressed: (() => Navigator.pop(context)),
                              child: const Text("Cancel")),
                          TextButton(
                              onPressed: (() async {
                                User? user =
                                    await AccountHelper.instance.getUserData();
                                if (user == null) {
                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context).push(AccountPopup());
                                  return;
                                }

                                UserData? userData = await FireStoreHelper
                                    .instance
                                    .getUserDataOnFireStore(
                                        user.uid, user.email ?? '');

                                if (userData == null) return;
                                await DatabaseLabelHelper.instance
                                    .deleteAllLabel();
                                await DatabaseTaskHelper.instance
                                    .deleteAllTask();
                                await DatabaseTodoHelper.instance
                                    .deleteAllTodo();

                                await DatabaseTaskHelper.instance
                                    .insertBatch(userData.tasks);
                                await DatabaseTodoHelper.instance
                                    .insertBatch(userData.todos);
                                await DatabaseLabelHelper.instance
                                    .insertBatch(userData.labels);

                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  content: Text("Successfully Restoring Data"),
                                ));
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                              }),
                              child: const Text("OK"))
                        ],
                      )));
            },
          )
        ],
      ),
    );
  }
}
