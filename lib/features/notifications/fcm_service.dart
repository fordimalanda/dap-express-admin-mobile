import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Demande de permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Récupérer le FCM Token pour notifier les nouvelles commandes
      String? token = await _fcm.getToken();
      print('FCM Registration Token: $token');

      // Écoute des messages en premier plan
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Nouveau message reçu: ${message.notification?.title}');
      });
    }
  }
}
