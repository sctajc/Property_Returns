//import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:flutter/material.dart';

// Current issue with using firebase_messaging: ^6.0.9
// a version control issue that hopefully will be resolved at some date
// https://github.com/OneSignal/OneSignal-Android-SDK/issues/1001
// Tutorials to do messaging from Firebase messaging
// https://github.com/OneSignal/OneSignal-Android-SDK/issues/1001
// https://medium.com/@SebastianEngel/easy-push-notifications-with-flutter-and-firebase-cloud-messaging-d96084f5954f

//
//class PushNotificationsManager {
//  PushNotificationsManager._();
//
//  factory PushNotificationsManager() => _instance;
//
//  static final PushNotificationsManager _instance =
//      PushNotificationsManager._();
//
//  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
//  bool _initialized = false;
//
//  Future<void> init() async {
//    if (!_initialized) {
//      // For iOS request permission first.
//      _firebaseMessaging.requestNotificationPermissions();
//      _firebaseMessaging.configure();
//
//      // For testing purposes print the Firebase Messaging token
//      String token = await _firebaseMessaging.getToken();
//      print("FirebaseMessaging token: $token");
//
//      _initialized = true;
//    }
//  }
//}
