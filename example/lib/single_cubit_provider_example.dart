import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reactive_cubit/reactive_cubit.dart';

import 'detail_screen.dart';

class CounterState {
  final bool isLoading;
  final int count;
  final bool isEven;

  CounterState(
      {required this.isLoading, required this.count, required this.isEven});

  CounterState copyWith({int? count, bool? isEven, bool? isLoading}) {
    return CounterState(
      count: count ?? this.count,
      isEven: isEven ?? this.isEven,
      isLoading: isLoading ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CounterState &&
          runtimeType == other.runtimeType &&
          count == other.count &&
          isEven == other.isEven &&
          isLoading == other.isLoading;

  @override
  int get hashCode => count.hashCode ^ isEven.hashCode;
}

class CounterCubit extends RxCubit<CounterState> {
  CounterCubit()
      : super(CounterState(count: 0, isEven: true, isLoading: false));

  void increment() async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(Durations.extralong4);
    final newCount = state.count + 1;
    emit(
      state.copyWith(count: newCount, isLoading: false),
    );
  }

  void updateLabel() {
    emit(
      state.copyWith(isEven: state.count % 2 == 0),
    );
  }
}

class SingleCubitExample extends StatelessWidget {
  const SingleCubitExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => CounterCubit(),
      child: const CounterWidget(),
    );
  }
}

class CounterWidget extends StatelessWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = Provider.of<CounterCubit>(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: double.infinity),
            // Only rebuilds when 'count' changes
            StreamBuilder<int>(
              stream: cubit.select((state) => state.count),
              builder: (context, snapshot) {
                if (kDebugMode) {
                  print("Rebuild count");
                }
                return Text(
                  'Count: ${snapshot.data ?? 0}',
                  style: const TextStyle(fontSize: 24),
                );
              },
            ),
            // Only rebuilds when 'isEven' changes
            StreamBuilder<bool>(
              stream: cubit.select((state) => state.isEven),
              builder: (context, snapshot) {
                if (kDebugMode) {
                  print("Rebuild title");
                }
                return Text(
                  snapshot.data == true ? 'Even' : 'Odd',
                  style: const TextStyle(fontSize: 24),
                );
              },
            ),
            ElevatedButton(
              onPressed: cubit.increment,
              child: const Text('Increment'),
            ),

            ElevatedButton(
              onPressed: cubit.updateLabel,
              child: const Text('Update label'),
            ),
            ElevatedButton(
              onPressed: cubit.reset,
              child: const Text('Reset state'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return Provider(
                        create: (BuildContext context) => CounterMessageCubit(),
                        child: const DetailScreen(),
                      );
                    },
                  ),
                );
              },
              child: const Text('Go to detail'),
            ),
          ],
        ),
        Container(
          color: Colors.transparent,
          child: StreamBuilder<bool>(
            stream: cubit.select((state) => state.isLoading),
            builder: (context, snapshot) {
              if (kDebugMode) {
                print("Rebuild Loading");
              }
              return Offstage(
                offstage: !(snapshot.data ?? false),
                child: const IgnorePointer(
                  ignoring: true,
                  child: SizedBox.expand(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
