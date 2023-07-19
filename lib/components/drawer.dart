import 'package:flutter/material.dart';
import 'package:to_do/helpers/labels.dart';
import 'package:to_do/screens/label.dart';
import 'package:to_do/screens/setting.dart';

class MainDrawer extends StatefulWidget {
  final Function(int) onChangeLabelFilter;
  const MainDrawer({super.key, required this.onChangeLabelFilter});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  int? selectedLabel;

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 50,
          ),
          const Text(
            "Saifu",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text("Labels"),
          const SizedBox(
            height: 10,
          ),
          FutureBuilder(
              future: DatabaseLabelHelper.instance.getAllLabels(),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemBuilder: ((context, index) => Card(
                              child: ListTile(
                                key: ValueKey(index),
                                selected: selectedLabel == index,
                                onTap: () => setState(() {
                                  selectedLabel == index
                                      ? selectedLabel = null
                                      : selectedLabel = index;
                                  widget.onChangeLabelFilter(
                                      snapshot.data![index].id!);
                                }),
                                leading: const Icon(Icons.label_outline_sharp),
                                title: Text(snapshot.data![index].title),
                              ),
                            )),
                        separatorBuilder: ((context, index) => const SizedBox(
                              height: 5,
                            )),
                        itemCount: snapshot.data!.length),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              })),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text("Create New Label"),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: ((context) => const LabelListEditMode()))),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: ((context) => const Settings()))),
          )
        ],
      ),
    ));
  }
}
