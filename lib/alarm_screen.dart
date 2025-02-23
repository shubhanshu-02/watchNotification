import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:intl/intl.dart';

  final FlutterLocalNotificationsPlugin flnp =
      FlutterLocalNotificationsPlugin();

  void initNotifications() async {
    const AndroidInitializationSettings init =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        const InitializationSettings initSettings = InitializationSettings(
          android : init,
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
    // Set an example alarm time (e.g., 2:30 PM)
    alarmTime = TimeOfDay(hour: 02, minute: 07); // 2:30 PM
    alarmDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      alarmTime!.hour,
      alarmTime!.minute,
    );

    // Calculate the initial time left
    timeLeft = alarmDateTime.difference(DateTime.now());

    // Update every second to show countdown
    Future.delayed(Duration(seconds: 1), updateTimeLeft);
  }

  void updateTimeLeft() {
    setState(() {
      timeLeft = alarmDateTime.difference(DateTime.now());
    });

    // If the alarm time is reached, trigger the alarm sound and notification
    if (timeLeft.isNegative) {
      playAlarmSound();
      showNotification();
    } else {
      // Continue updating the UI every second
      Future.delayed(Duration(seconds: 1), updateTimeLeft);
    }
  }

  void playAlarmSound() {
    FlutterRingtonePlayer().playNotification(); // Play the alarm sound
  }

  void showNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
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
      0, // Notification ID
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
                  style: TextStyle(color : Colors.white, fontSize:  18),
                ),
                SizedBox(height: 5),
                Text(
                   '$timeLeftString',
                  style: TextStyle(color : Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



