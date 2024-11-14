import 'package:rxdart/rxdart.dart';
import '../reactive_cubit.dart';

abstract class RxCubit<State> {
  final BehaviorSubject<State> _controller;
  final State _initialState; // Store the initial state
  static StateObserver? observer;

  int _activeListeners = 0;

  RxCubit(State initialState)
      : _initialState = initialState,
        _controller = BehaviorSubject<State>.seeded(initialState) {
    observer?.onCubitInit(this);
  }

  Stream<State> get stream =>
      _controller.stream.doOnListen(_onListen).doOnCancel(_onCancel);
  State get state => _controller.value;

  /// Emit a new state only if it is different from the current state
  void emit(State newState) {
    if (!_controller.isClosed && state != newState) {
      observer?.onStateChanged(this, state, newState);
      _controller.add(newState);
    }
  }

  /// Reset the cubit to its initial state
  void reset() {
    if (!_controller.isClosed && state != _initialState) {
      observer?.onStateChanged(this, state, _initialState);
      _controller.add(_initialState);
    }
  }

  /// Close the stream when the cubit is disposed
  void close() {
    if (!_controller.isClosed) {
      _controller.close();
      observer?.onCubitDispose(this);
    }
  }

  /// Notify observer of errors
  void handleError(Object error, StackTrace stackTrace) {
    observer?.onError(this, error, stackTrace);
  }

  /// Allows selecting a specific property from the state to listen to, handling both first-time and state changes.
  Stream<T> select<T>(T Function(State state) selector) {
    return stream.map(selector).distinct().skip(1);
  }

  /// Called when a widget subscribes to the cubit's stream
  void _onListen() {
    _activeListeners++;
  }

  /// Called when a widget unsubscribes from the cubit's stream
  void _onCancel() {
    _activeListeners--;
    if (_activeListeners <= 0) {
      close();
    }
  }
}
