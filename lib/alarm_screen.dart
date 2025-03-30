import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:audio_check/ringing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:intl/intl.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final TimeOfDay alarmTime = const TimeOfDay(hour: 00, minute: 17); //manually set currently
  late DateTime alarmDateTime;
  late Duration timeLeft = const Duration();
  Timer? _timer;
  final int alarmId = 0;
  bool alarmActive = false;

  @override
  void initState() {
    super.initState();

    // Configure the alarm time
    _configureAlarmTime();

    // Start a timer for UI updates
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => updateTimeLeft());

    // Schedule the alarm immediately
    _scheduleAlarm();

    // Check if an alarm was triggered while app was closed
    _checkAlarmTriggered();
  }

  Future<void> _checkAlarmTriggered() async {
    final prefs = await SharedPreferences.getInstance();
    final triggered = prefs.getBool('alarmTriggered') ?? false;

    if (triggered) {
      // Clear the flag
      await prefs.setBool('alarmTriggered', false);

      // Navigate to ringing screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RingingScreen()),
        );
      }
    }
  }

  void _configureAlarmTime() {
    final now = DateTime.now();
    alarmDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarmTime.hour,
      alarmTime.minute,
    );

    // If alarm time has already passed today, set it for tomorrow
    if (alarmDateTime.isBefore(now)) {
      alarmDateTime = alarmDateTime.add(const Duration(days: 1));
    }

    timeLeft = alarmDateTime.difference(now);
  }

  void updateTimeLeft() {
    if (!mounted) return;

    final now = DateTime.now();
    final newTimeLeft = alarmDateTime.difference(now);

    setState(() {
      timeLeft = newTimeLeft;
    });

    // If time is up and we're still on this screen, go to the ringing screen
    if (timeLeft.isNegative && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RingingScreen()),
      ).then((_) {
        // Reschedule the alarm for the next day when returning
        _configureAlarmTime();
        _scheduleAlarm();
      });
    }
  }

  Future<void> _scheduleAlarm() async {
    // Cancel any existing alarm first
    await AndroidAlarmManager.cancel(alarmId);

    // Schedule the new alarm
    final success = await AndroidAlarmManager.oneShotAt(
      alarmDateTime,
      alarmId,
      alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      allowWhileIdle: true,
      alarmClock: true,
    );

    setState(() {
      alarmActive = success;
    });
  }

  @pragma('vm:entry-point')
  static void alarmCallback() async {
    // Play the alarm sound
    FlutterRingtonePlayer().playAlarm(looping: true);

    // Save alarm triggered state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alarmTriggered', true);

    // Send message to main isolate
    final SendPort? sendPort = IsolateNameServer.lookupPortByName('isolate');
    sendPort?.send('ALARM_TRIGGERED');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String timeLeftString = timeLeft.isNegative
        ? "Time's up!"
        : 'Time Left: ${timeLeft.inHours}h ${timeLeft.inMinutes % 60}m ${timeLeft.inSeconds % 60}s';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Alarm set for ${DateFormat('hh:mm a').format(alarmDateTime)}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 5),
              Text(
                timeLeftString,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  FlutterRingtonePlayer().stop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RingingScreen()),
                  );
                },
                child: const Text("Test Alarm"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
