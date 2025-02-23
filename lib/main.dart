import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


void initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void showNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id', 
    'channel_name',
    channelDescription: 'Channel for displaying notifications',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    notificationDetails,
  );
}


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // appBar: AppBar(
        //   title: const Text('Ringtone player'),
        // ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    child: const Text('playAlarm'),
                    onPressed: () {
                      FlutterRingtonePlayer().playAlarm();
                      showNotification('Alarm', 'The alarm is playing');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    child: const Text('playAlarm asAlarm: false'),
                    onPressed: () {
                      FlutterRingtonePlayer().playAlarm(asAlarm: false);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    child: const Text('playNotification'),
                    onPressed: () {
                      FlutterRingtonePlayer().playNotification();
                      showNotification('Notification', 'The notification sound is playing');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    child: const Text('playRingtone'),
                    onPressed: () {
                      FlutterRingtonePlayer().playRingtone();
                      showNotification('Ringtone', 'The ringtone is playing');

                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    child: const Text('Play from asset (iphone.mp3)'),
                    onPressed: () {
                      FlutterRingtonePlayer()
                          .play(fromAsset: "assets/iphone.mp3");
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    child: const Text('Play from asset (android.wav)'),
                    onPressed: () {
                      FlutterRingtonePlayer()
                          .play(fromAsset: "assets/android.wav");
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    child: const Text('play'),
                    onPressed: () {
                      FlutterRingtonePlayer().play(
                        android: AndroidSounds.notification,
                        ios: IosSounds.glass,
                        looping: true,
                        volume: 1.0,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    child: const Text('stop'),
                    onPressed: () {
                      FlutterRingtonePlayer().stop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}