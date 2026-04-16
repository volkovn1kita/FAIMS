import 'dart:async';

class SessionService {
  static final SessionService instance = SessionService._();
  SessionService._();

  final StreamController<void> _controller =
      StreamController<void>.broadcast();

  Stream<void> get onForceLogout => _controller.stream;

  void forceLogout() => _controller.add(null);

  void dispose() => _controller.close();
}
