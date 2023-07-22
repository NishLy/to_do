import 'package:flutter/material.dart';

class GeneralPopoup extends PopupRoute {
  final Widget widget;
  GeneralPopoup(this.widget);

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
    return widget;
  }
}
