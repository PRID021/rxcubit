import 'package:flutter/material.dart';

import '../reactive_cubit.dart';

class RxCubitScope extends StatefulWidget {
  final StateObserver observer;
  final Widget child;

  const RxCubitScope({
    Key? key,
    required this.observer,
    required this.child,
  }) : super(key: key);

  @override
  RxCubitScopeState createState() => RxCubitScopeState();
}

class RxCubitScopeState extends State<RxCubitScope> {
  @override
  void initState() {
    super.initState();
    // Set the global observer to the one provided in CubitScope
    RxCubit.observer = widget.observer;
  }

  @override
  void dispose() {
    // Clean up when the widget is disposed
    RxCubit.observer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
