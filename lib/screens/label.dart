import 'package:flutter/material.dart';
import 'package:to_do/helpers/label.dart';

import '../model/label.dart';

class LabelListEditMode extends StatefulWidget {
  const LabelListEditMode({super.key});

  @override
  State<LabelListEditMode> createState() => _LabelListState();
}

class _LabelListState extends State<LabelListEditMode> {
  late Future<List<Label>> _labels;

  bool isNewLabelFocus = false;

  TextEditingController newLabelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _labels = DatabaseLabelHelper.instance.getAllLabels();
  }

  void _onChangeLabel(Label label) {
    setState(() {
      DatabaseLabelHelper.instance.updateLabel(label);
      _labels = DatabaseLabelHelper.instance.getAllLabels();
    });
  }

  void _onDeleteLabel(Label label) {
    setState(() {
      DatabaseLabelHelper.instance.deleteLabel(label.id!);
      _labels = DatabaseLabelHelper.instance.getAllLabels();
    });
  }

  void _onCreteLabel(Label label) {
    setState(() {
      DatabaseLabelHelper.instance.insertLabel(label);
      _labels = DatabaseLabelHelper.instance.getAllLabels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FocusScope(
            onFocusChange: (value) => setState(() {
                  isNewLabelFocus = value;
                }),
            child: ListTile(
              leading: const Icon(Icons.add),
              title: TextField(
                controller: newLabelController,
              ),
              trailing: isNewLabelFocus
                  ? IconButton(
                      onPressed: (() =>
                          _onCreteLabel(Label(title: newLabelController.text))),
                      icon: const Icon(Icons.check))
                  : null,
            )),
        FutureBuilder(
            future: _labels,
            builder: ((context, snapshot) {
              if (snapshot.hasData) {
                return ListView.separated(
                  itemBuilder: (context, index) => LabelTile.editMode(
                    label: snapshot.data![index],
                    onChange: _onChangeLabel,
                    onDelete: _onDeleteLabel,
                  ),
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 5,
                  ),
                );
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            }))
      ],
    );
  }
}

// ignore: must_be_immutable
class LabelTile extends StatefulWidget {
  final Label label;
  bool isCheck = false;
  Function(Label)? onChange;
  Function(Label)? onCheckboxChange;
  Function(Label)? onDelete;
  bool isEditMode = false;

  LabelTile(
      {super.key,
      required this.label,
      required this.onCheckboxChange,
      required this.isCheck});

  LabelTile.editMode(
      {super.key,
      required,
      this.isEditMode = true,
      required this.onChange,
      required this.onDelete,
      required this.label});

  @override
  State<LabelTile> createState() => _LabelTileState();
}

class _LabelTileState extends State<LabelTile> {
  bool isCheck = false;
  bool isEditMode = false;
  bool isInFocus = false;

  TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isCheck = widget.isCheck;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: !isEditMode
          ? const Icon(Icons.label_outline_rounded)
          : isInFocus
              ? IconButton(
                  onPressed: (() {}),
                  icon: const Icon(Icons.delete_outline_rounded))
              : const Icon(Icons.label_outline_rounded),
      title: FocusScope(
          onFocusChange: (value) => setState(() {
                isInFocus = value;
              }),
          child: TextField(
            controller: titleController,
          )),
      trailing: !isEditMode
          ? Checkbox(
              value: isCheck,
              onChanged: ((value) {
                setState(() {
                  isCheck = value!;
                });
              }))
          : isInFocus
              ? IconButton(onPressed: (() {}), icon: const Icon(Icons.check))
              : const Icon(Icons.edit),
    );
  }
}
