import 'package:flutter/material.dart';

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
          const Divider(
            thickness: 2,
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text("Backup to Firestore"),
            onTap: () {},
          )
        ],
      ),
    );
  }
}
