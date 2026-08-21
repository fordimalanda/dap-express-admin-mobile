import 'package:url_launcher/url_launcher.dart';

class PhoneLauncher {
  static Future<bool> makeCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri url = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(url)) {
      return await launchUrl(url);
    }
    return false;
  }

  static Future<bool> openWhatsApp(String phoneNumber, {String message = "Bonjour, je vous contacte concernant votre commande Dap-Express."}) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri url = Uri.parse('https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
