import 'package:flutter/foundation.dart';

class ApiConstants {
  // Détection automatique de l'environnement (Web/Chrome, Android Emulator, iOS Simulator/Device)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api/v1';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api/v1';
    } else {
      return 'http://localhost:3000/api/v1';
    }
  }

  static const String login = '/auth/login';
  static const String profile = '/auth/me';
  static const String dashboard = '/analytics/dashboard';
  static const String orders = '/orders';
  static const String products = '/products';
}
