import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  // Створюємо екземпляр
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Функція ініціалізації
  Future<void> initNotifications() async {
    // 1. Запит дозволу (важливо для Android 13+)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Користувач дозволив сповіщення!');
    } else {
      print('❌ Користувач заборонив сповіщення');
      return;
    }

    // 2. Отримання токена (адреси телефону)
    final fcmToken = await _firebaseMessaging.getToken();

    // Виводимо токен в консоль (він нам зараз знадобиться!)
    print('=======================================');
    print('MY FCM TOKEN: $fcmToken');
    print('=======================================');

    // Тут пізніше ми додамо код, щоб слухати повідомлення, коли додаток відкритий
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Отримано повідомлення, коли додаток відкритий: ${message.notification?.title}');
    });
  }
}