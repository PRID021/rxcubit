import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reactive_cubit/reactive_cubit.dart';


import 'multiple_cubit_provider_example.dart';
import 'single_cubit_provider_example.dart';

class MyObserver extends StateObserver {
  @override
  void onStateChanged<C extends RxCubit>(
      C cubit, dynamic previousState, dynamic newState) {
    if (kDebugMode) {
      print(
          '[${cubit.runtimeType}] State changed from $previousState to $newState');
    }
  }

  @override
  void onError<C extends RxCubit>(
      C cubit, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('[${cubit.runtimeType}] Error: $error');
    }
  }
}

void main() {
  runApp(
    RxCubitScope(
      observer: MyObserver(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Danh sách các màn hình mà BottomNavigationBar sẽ điều hướng tới
  final List<Widget> _pages = [
    const SingleCubitExample(),
    const MultiCubitExample(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Example'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'SSE',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'MTS',
          ),
        ],
      ),
    );
  }
}
