import 'package:audio_check/ringing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:intl/intl.dart';

final FlutterLocalNotificationsPlugin flnp = FlutterLocalNotificationsPlugin();

void initNotifications() async {
  const AndroidInitializationSettings init =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(
    android: init,
  );

  await flnp.initialize(initSettings);
}

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  TimeOfDay? alarmTime;
  late DateTime alarmDateTime;
  late Duration timeLeft;

  @override
  void initState() {
    super.initState();
    alarmTime = const TimeOfDay(hour: 20, minute: 36);
    alarmDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      alarmTime!.hour,
      alarmTime!.minute,
    );

    timeLeft = alarmDateTime.difference(DateTime.now());

    Future.delayed(const Duration(seconds: 1), updateTimeLeft);
  }

  void updateTimeLeft() {
    setState(() {
      timeLeft = alarmDateTime.difference(DateTime.now());
    });

    if (timeLeft.isNegative) {
      playAlarmSound();
      showNotification();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RingingScreen()),
      );
    } else {
      Future.delayed(const Duration(seconds: 1), updateTimeLeft);
    }
  }

  void playAlarmSound() {
    FlutterRingtonePlayer().playAlarm();
  }

  void stopAlarmSound() {
    FlutterRingtonePlayer().stop();
  }

  void showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'alarm_channel_id',
      'Alarm Channel',
      channelDescription: 'Channel for alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flnp.show(
      0,
      'Alarm',
      'Time\'s up! Your alarm is ringing.',
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    String timeLeftString = timeLeft.isNegative
        ? "Time's up! Alarm ringing!"
        : 'Time Left: ${timeLeft.inHours} hours ${timeLeft.inMinutes % 60} minutes ${timeLeft.inSeconds % 60} seconds';

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Alarm set for ${DateFormat('hh:mm a').format(alarmDateTime)}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 5),
                Text(
                  '$timeLeftString',
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),            
                ElevatedButton(
              onPressed: () {
                stopAlarmSound();
                Navigator.pop(context); 
              }, child: const Text("dismiss"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
