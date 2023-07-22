import 'package:flutter/material.dart';
import 'package:to_do/helpers/labels.dart';
import 'package:to_do/screens/label.dart';
import 'package:to_do/screens/setting.dart';

class MainDrawer extends StatefulWidget {
  final int? seletedId;
  final Function(int?) onChangeLabelFilter;
  const MainDrawer(
      {super.key, required this.onChangeLabelFilter, this.seletedId});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  int? selectedIdLabel;

  @override
  void initState() {
    super.initState();
    if (widget.seletedId != null) selectedIdLabel = widget.seletedId;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(padding: const EdgeInsets.all(10), children: [
      const SizedBox(
        height: 50,
      ),
      const ListTile(
        title: const Text(
          "Saifu",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      const ListTile(title: const Text("Labels")),
      FutureBuilder(
          future: DatabaseLabelHelper.instance.getAllLabels(),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              List<Widget> labelsWidgets = [];
              for (var label in snapshot.data!) {
                labelsWidgets.add(ListTile(
                    key: ValueKey(label.id),
                    selected: selectedIdLabel == label.id,
                    onTap: () => setState(() {
                          if (selectedIdLabel != label.id) {
                            widget.onChangeLabelFilter(label.id!);
                            selectedIdLabel = label.id;
                            return;
                          }
                          widget.onChangeLabelFilter(null);
                          selectedIdLabel = null;
                        }),
                    leading: const Icon(Icons.label_outline_sharp),
                    title: Text(label.title)));
              }
              return Column(children: labelsWidgets);
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          })),
      const Divider(
        thickness: 1,
      ),
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
      ),
    ]));
  }
}
