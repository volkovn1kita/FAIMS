import 'dart:async';

/// Singleton that broadcasts a "force logout" signal from anywhere in the app
/// (typically from API services when they receive a 401 response).
///
/// MyApp listens to [onForceLogout] and navigates the user to the login screen,
/// clearing all stored tokens before doing so.
class SessionService {
  static final SessionService instance = SessionService._();
  SessionService._();

  final StreamController<void> _controller =
      StreamController<void>.broadcast();

  Stream<void> get onForceLogout => _controller.stream;

  /// Call this from any API service when the server returns 401.
  /// Safe to call multiple times — the stream is broadcast so duplicate
  /// rapid-fire calls are harmless (the listener de-bounces via navigation).
  void forceLogout() => _controller.add(null);

  void dispose() => _controller.close();
}
