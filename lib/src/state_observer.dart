import 'package:flutter/foundation.dart';

import '../reactive_cubit.dart';

abstract class StateObserver {
  /// Called when the state of a [Cubit] changes.
  void onStateChanged<C extends RxCubit>(
      C cubit, dynamic previousState, dynamic newState) {
    if (kDebugMode) {
      print(
          '[${cubit.runtimeType}] State changed from $previousState to $newState');
    }
  }

  /// Called when an error occurs in the [Cubit].
  void onError<C extends RxCubit>(
      C cubit, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('[${cubit.runtimeType}] Error: $error\nStackTrace: $stackTrace');
    }
  }

  /// Called when a [Cubit] is initialized.
  void onCubitInit<C extends RxCubit>(C cubit) {
    if (kDebugMode) {
      print('[${cubit.runtimeType}] Cubit initialized');
    }
  }

  /// Called when a [Cubit] is disposed of.
  void onCubitDispose<C extends RxCubit>(C cubit) {
    if (kDebugMode) {
      print('[${cubit.runtimeType}] Cubit disposed');
    }
  }
}
