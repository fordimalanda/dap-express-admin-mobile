class ApiConstants {
  // Pour émulateur Android utiliser 10.0.2.2, pour iOS Simulator ou appareil physique utiliser l'IP locale de la machine
  static const String baseUrl = 'http://10.0.2.2:3001/api/v1';

  static const String login = '/auth/login';
  static const String profile = '/auth/me';
  static const String dashboard = '/analytics/dashboard';
  static const String orders = '/orders';
  static const String products = '/products';
}
