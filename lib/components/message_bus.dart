import 'dart:async';

class MessageBus {
  static final MessageBus _instance = MessageBus._internal();
  final _updateController = StreamController<void>.broadcast();

  factory MessageBus() {
    return _instance;
  }

  MessageBus._internal();

  Stream<void> get updateStream => _updateController.stream;

  void notifyUpdate() {
    _updateController.add(null);
  }

  void dispose() {
    _updateController.close();
  }
}