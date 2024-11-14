import 'package:rxdart/rxdart.dart';

class MessageHandler<M> {
  final BehaviorSubject<M> _messageController = BehaviorSubject<M>();

  /// Stream to listen for messages
  Stream<M> get messageStream => _messageController.stream;

  /// Method to send a message
  void sendMessage(M message) {
    if (!_messageController.isClosed) {
      _messageController.add(message);
    }
  }

  /// Close the message stream
  void close() {
    if (!_messageController.isClosed) {
      _messageController.close();
    }
  }
}
