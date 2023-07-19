import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do/auth/google.dart';
import 'package:to_do/helpers/account.dart';

class AccountPopup extends PopupRoute {
  @override
  Color? get barrierColor => const Color.fromARGB(173, 0, 0, 0);

  // This allows the popup to be dismissed by tapping the scrim or by pressing
  // the escape key on the keyboard.
  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismissible Dialog';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FutureBuilder(
        future: Authentication.initializeFirebase(context: context),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error initializing Firebase');
          } else if (snapshot.connectionState == ConnectionState.done) {
            return const AccountDetail();
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}

class AccountDetail extends StatefulWidget {
  const AccountDetail({super.key});

  @override
  State<AccountDetail> createState() => _AccountDetailState();
}

class _AccountDetailState extends State<AccountDetail> {
  Future<User?> _user = AccountHelper.instance.getUserData();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Wrap(children: [
              const Text(
                "Account",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              FutureBuilder(
                  future: _user,
                  builder: ((context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return snapshot.data != null
                          ? Wrap(children: [
                              ListTile(
                                leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        snapshot.data!.photoURL ?? '')),
                                title: Text(snapshot.data!.displayName ?? ""),
                                subtitle: Text(snapshot.data!.email ?? ''),
                              ),
                              ListTile(
                                onTap: (() {
                                  _user =
                                      Authentication.signOut(context: context);
                                  AccountHelper.instance.setUserData(null);
                                  Navigator.of(context).pop();
                                }),
                                leading: const Icon(Icons.logout),
                                title: const Text("Logout"),
                              )
                            ])
                          : ListTile(
                              onTap: (() {
                                _user = Authentication.signInWithGoogle(
                                    context: context);
                                Navigator.of(context).pop();
                              }),
                              leading: const Icon(Icons.person_add_outlined),
                              title: const Text("Add Account Google"),
                            );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  })),
            ]),
          ),
        ),
      ),
    );
  }
}
