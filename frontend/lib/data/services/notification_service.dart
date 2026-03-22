import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      developer.log('✅ Користувач дозволив сповіщення!', name: 'NotificationService');
    } else {
      developer.log('❌ Користувач заборонив сповіщення', name: 'NotificationService');
      return;
    }

    final fcmToken = await _firebaseMessaging.getToken();

    developer.log('=======================================', name: 'NotificationService');
    developer.log('MY FCM TOKEN: $fcmToken', name: 'NotificationService');
    developer.log('=======================================', name: 'NotificationService');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log('Отримано повідомлення, коли додаток відкритий: ${message.notification?.title}', name: 'NotificationService');
    });
  }
}