import 'package:flutter/material.dart';
import 'package:to_do/helpers/labels.dart';

class LabelGridChips extends StatelessWidget {
  final List<int> labelIds;
  const LabelGridChips({super.key, required this.labelIds});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DatabaseLabelHelper.instance.getLabelCache(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            List<Widget> labels = [];

            for (var label in snapshot.data!) {
              if (labelIds.contains(label.id)) {
                labels.add(Card(
                  color: const Color.fromARGB(96, 7, 0, 0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      label.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ));
              }
            }
            return Wrap(spacing: 2, runSpacing: 2, children: labels);
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        }));
  }
}
