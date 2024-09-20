import 'package:coffee_shop/welcomepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBCPLC3WaWAtg3DGvG_7ilFR5NhEEKWvJk",
        projectId: "coffeeshop-f975d",
        messagingSenderId: "517352605941",
        appId: "1:517352605941:android:40ef5058932cd1c178ddbc",
      ));

  await  FirebaseMessaging.instance.requestPermission();
  await FirebaseMessaging.instance.getToken().then((value) => print("FCM Token is $value"));

  // final _firebaseMessaging = FirebaseMessaging.instance;
  // await _firebaseMessaging.requestPermission();
  //
  // String? fcmToken = await _firebaseMessaging.getToken();
  //
  // print(fcmToken.toString());

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
      MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Welcomepage(),
      )
  );}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message title: ${message.notification?.title}");
  print("Handling a background message body: ${message.notification?.body}");
}