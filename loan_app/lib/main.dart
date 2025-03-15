import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loan_app/screens/splash_screen.dart';
import 'package:loan_app/services/notification_service.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Background message received: ${message.messageId}");
  }
}

/*Future<void> requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    if (kDebugMode) {
      print('User granted permission');
    }
  } else {
    if (kDebugMode) {
      print('User declined permission');
    }
  }
}

void getToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  if (kDebugMode) {
    print("FCM Token: $token");
  }
}*/

/*
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
print("New Notification: ${message.notification?.title}");
});

FirebaseMessaging.onMessage.listen((RemoteMessage message) {
print("New Notification: ${message.notification?.title}");
});
*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //await NotificationService.initialize();

  FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler); // Initialize FCM & Notifications

  NotificationService.initialize(); // Initialize Local Notifications

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grey Loan',
      home: SplashScreen(), // Set SplashScreen as the initial screen
    );
  }
}
