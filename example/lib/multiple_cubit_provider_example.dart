import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reactive_cubit/reactive_cubit.dart';


class CubitA extends RxCubit<int> {
  CubitA() : super(0);
  void increment() => emit(state + 1);
}

class CubitB extends RxCubit<String> {
  CubitB() : super('Initial Message');
  void changeMessage() => emit('Updated Message');
}

class MultiCubitExample extends StatelessWidget {
  const MultiCubitExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CubitA>(
          create: (_) => CubitA(),
        ),
        Provider<CubitB>(
          create: (_) => CubitB(),
        ),
      ],
      child: const WidgetDependenciesABC(),
    );
  }
}

class WidgetDependenciesABC extends StatelessWidget {
  const WidgetDependenciesABC({super.key});

  @override
  Widget build(BuildContext context) {
    final cubitA = Provider.of<CubitA>(context);
    final cubitB = Provider.of<CubitB>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: double.infinity),
        StreamBuilder<int>(
          stream: cubitA.stream,
          builder: (context, snapshot) {
            return Text('Cubit A state: ${snapshot.data}');
          },
        ),
        StreamBuilder<String>(
          stream: cubitB.stream,
          builder: (context, snapshot) {
            return Text('Cubit B state: ${snapshot.data}');
          },
        ),
        ElevatedButton(
          onPressed: cubitA.increment,
          child: const Text('Increment Cubit A'),
        ),

      ],
    );
  }
}
