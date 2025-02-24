import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class RingingScreen extends StatelessWidget {
  RingingScreen({super.key});
  final FlutterRingtonePlayer audio = FlutterRingtonePlayer();



  void stopAlarmSound() {
    audio.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'ALARM RINGING!',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                stopAlarmSound();
                Navigator.pop(context); // Dismiss the screen and stop the alarm
              },
              child: const Text('Dismiss', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}