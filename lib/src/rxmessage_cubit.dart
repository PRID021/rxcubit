import '../reactive_cubit.dart';
import 'message_handler.dart';

abstract class RxMessageCubit<State, M> extends RxCubit<State> {
  final MessageHandler<M> _messageHandler = MessageHandler<M>();

  RxMessageCubit(State initialState) : super(initialState);

  /// Expose the message stream
  Stream<M> get messageStream => _messageHandler.messageStream;

  /// Method to send a message
  void sendMessage(M message) => _messageHandler.sendMessage(message);

  @override
  void close() {
    super.close();
    _messageHandler.close();
  }
}
