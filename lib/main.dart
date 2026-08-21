import 'package:flutter/material.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Note: Initialiser Firebase une fois le fichier google-services.json / GoogleService-Info.plist configuré
  // await Firebase.initializeApp();
  // await FCMService().initialize();

  runApp(const DapExpressAdminApp());
}
