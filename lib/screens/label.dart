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
      isNewLabelFocus = false;
      newLabelController.text = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Edit Labels"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )),
        body: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            FocusScope(
                onFocusChange: (value) => setState(() {
                      isNewLabelFocus = value;
                    }),
                child: ListTile(
                  shape: !isNewLabelFocus
                      ? null
                      : const Border(
                          top: BorderSide(),
                          bottom: BorderSide(),
                        ),
                  leading: isNewLabelFocus
                      ? IconButton(
                          onPressed: (() => setState(() {
                                isNewLabelFocus = false;
                              })),
                          icon: const Icon(Icons.close_rounded))
                      : const Icon(Icons.add),
                  title: TextField(
                    maxLength: 30,
                    decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        hintText: "Add new label"),
                    controller: newLabelController,
                  ),
                  trailing: isNewLabelFocus
                      ? IconButton(
                          onPressed: (() => _onCreteLabel(
                              Label(title: newLabelController.text))),
                          icon: const Icon(Icons.check))
                      : null,
                )),
            Expanded(
                child: FutureBuilder(
                    future: _labels,
                    builder: ((context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.separated(
                          itemBuilder: (context, index) => LabelTile.editMode(
                            key: ValueKey(snapshot.data![index].id),
                            label: snapshot.data![index],
                            onChange: _onChangeLabel,
                            isEditMode: true,
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
                    })))
          ],
        ));
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
      required this.isEditMode,
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
    isEditMode = widget.isEditMode;
    titleController.text = widget.label.title;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: !isInFocus
          ? null
          : const Border(
              top: BorderSide(),
              bottom: BorderSide(),
            ),
      leading: !isEditMode
          ? const Icon(Icons.label_outline_rounded)
          : isInFocus
              ? IconButton(
                  onPressed: (() => setState(() {
                        isInFocus = false;
                        widget.onDelete != null
                            ? widget.onDelete!(widget.label)
                            : null;
                      })),
                  icon: const Icon(Icons.delete_outline_rounded))
              : const Icon(Icons.label_outline_rounded),
      title: FocusScope(
          onFocusChange: (value) => setState(() {
                isInFocus = value;
              }),
          child: TextField(
            maxLength: 30,
            controller: titleController,
            readOnly: isEditMode ? false : true,
            decoration: const InputDecoration(
                border: InputBorder.none, counterText: ''),
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
              ? IconButton(
                  onPressed: (() => setState(() {
                        isInFocus = false;
                        widget.onDelete != null
                            ? widget.onChange!(Label(
                                title: titleController.text,
                                id: widget.label.id))
                            : null;
                      })),
                  icon: const Icon(Icons.check))
              : const Icon(Icons.edit),
    );
  }
}
