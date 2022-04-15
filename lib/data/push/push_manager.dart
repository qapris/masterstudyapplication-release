import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../main.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance = PushNotificationsManager._();

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestPermission();
      _firebaseMessaging.getNotificationSettings();

      String? token = await _firebaseMessaging.getToken();
      print("FirebaseMessaging token: $token");

      _initialized = true;
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
      //_showItemDialog(message);
      pushStreamController.add(message);
    });

    // TODO: Нужно исправить onbackgroundMessage
    /*FirebaseMessaging.onBackgroundMessage((message) async {
      print("onMessage: $message");
      //_showItemDialog(message);
      pushStreamController.add(message);
    });*/

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onLaunch: $message");
    });
  }
}
