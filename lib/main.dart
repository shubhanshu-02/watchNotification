import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Notification Test'),
        ),
        body: Center(
          child: ElevatedButton(
            child: const Text('Request Notification Permission'),
            onPressed: () {
              requestNotificationPermission();
            },
          ),
        ),
      ),
    );
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    if (await Permission.notification.request().isGranted) {
      showNotification();
    } else {
      print("Notification permission denied");
    }
  }

  void showNotification() async {
    var androidDetails = AndroidNotificationDetails(
      'default_channel_id',
      'default_channel_name',
      channelDescription: 'Default notification channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0, 
      'Test Notification',
      'This is a notification triggered from the background or foreground.',
      platformDetails,
    );
  }
}
