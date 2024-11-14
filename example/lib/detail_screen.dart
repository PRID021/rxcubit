import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reactive_cubit/reactive_cubit.dart';


class CounterMessageCubit extends RxMessageCubit<int, String> {
  CounterMessageCubit() : super(0);

  void increment() {
    emit(state + 1);
    sendMessage('Counter incremented to $state');
  }

  void decrement() {
    emit(state - 1);
    sendMessage('Counter decremented to $state');
  }
}

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late CounterMessageCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = Provider.of<CounterMessageCubit>(context, listen: false);
    // Listen to messageStream for notifications
    cubit.messageStream.listen(_onMessage);
  }

  void _onMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = Provider.of<CounterMessageCubit>(context, listen: false);
    if (kDebugMode) {
      print("47 ==> Build");
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Counter with Messages')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder(
              stream: cubit.stream,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                return Text('Counter: ${snapshot.data ?? 0}');
              },
            ),
            ElevatedButton(
              onPressed: cubit.increment,
              child: const Text('Increment'),
            ),
            ElevatedButton(
              onPressed: cubit.decrement,
              child: const Text('Decrement'),
            ),
            const SizedBox(width: double.infinity),
            ElevatedButton(
              onPressed: () {
                // Navigate to the HomeScreen using pushReplacement
                Navigator.of(context).pop();
              },
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
