import 'dart:async';
import 'dart:developer';

class SingulariseChats {
  bool _singularise = true;
  Timer? _timer;
  final Duration _duration;

  SingulariseChats({required int duration})
      : _duration = Duration(seconds: duration);

  bool get singularise => _singularise;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(_duration, (timer) {
      _singularise = !_singularise;
      log('Joining chats status: $_singularise');
      stop();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void restart() {
    stop();
    start();
  }
}
