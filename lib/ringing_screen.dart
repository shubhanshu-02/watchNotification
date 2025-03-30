  import 'dart:async';
  import 'package:flutter/material.dart';
  import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
  import 'package:pedometer/pedometer.dart';
  import 'package:permission_handler/permission_handler.dart';
  import 'package:shared_preferences/shared_preferences.dart';

  class RingingScreen extends StatefulWidget {
    const RingingScreen({super.key});

    @override
    State<RingingScreen> createState() => _RingingScreenState();
  }

  class _RingingScreenState extends State<RingingScreen> {
    final FlutterRingtonePlayer audio = FlutterRingtonePlayer();
    StreamSubscription<StepCount>? _stepCountSubscription;
    StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;
    String _status = 'Unknown';
    int _startSteps = 0;
    int _currentSteps = 0;
    final int _requiredSteps = 10; // Number of steps required to dismiss
    bool _isInitializing = true;

    @override
    void initState() {
      super.initState();
      // stop playing anything being played
    FlutterRingtonePlayer().stop();
    
    // Start playing alarm immediately
    audio.playAlarm(looping: true, asAlarm: true);
      
      // Clear the alarm triggered flag
      _clearAlarmTriggeredFlag();
      
      // Initialize pedometer - currently an idea to be explored
      // _initPedometer();
    }

    Future<void> _clearAlarmTriggeredFlag() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('alarmTriggered', false);
    }

    Future<void> _initPedometer() async {
      try {
        bool granted = await _checkActivityRecognitionPermission();
        if (!granted) {
          setState(() {
            _isInitializing = false;
            _status = 'Permission denied';
          });
          return;
        }

        // Start with pedestrian status
        _pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen(
          onPedestrianStatusChanged,
          onError: onPedestrianStatusError,
        );

        // Get step count
        _stepCountSubscription = Pedometer.stepCountStream.listen(
          onStepCount,
          onError: onStepCountError,
        );
      } catch (e) {
        setState(() {
          _isInitializing = false;
          _status = 'Error: $e';
        });
      }
    }

    void onStepCount(StepCount event) {
      if (!mounted) return;
      
      // If this is the first reading, set it as the starting point
      if (_isInitializing) {
        _startSteps = event.steps;
        _isInitializing = false;
      }
      
      // Calculate steps taken since alarm started
      final stepsTaken = event.steps - _startSteps;
      
      setState(() {
        _currentSteps = stepsTaken;
      });

      // Check if enough steps have been taken
      if (_currentSteps >= _requiredSteps) {
        _dismissAlarm();
      }
    }

    void onPedestrianStatusChanged(PedestrianStatus event) {
      if (!mounted) return;
      
      setState(() {
        _status = event.status;
      });
    }

    void onPedestrianStatusError(error) {
      if (!mounted) return;
      
      setState(() {
        _isInitializing = false;
        _status = 'Not available';
      });
    }

    void onStepCountError(error) {
      if (!mounted) return;
      
      setState(() {
        _isInitializing = false;
      });
    }

    Future<bool> _checkActivityRecognitionPermission() async {
      bool granted = await Permission.activityRecognition.isGranted;

      if (!granted) {
        granted = await Permission.activityRecognition.request() ==
            PermissionStatus.granted;
      }

      return granted;
    }

    void _dismissAlarm() {
      audio.stop();
      FlutterRingtonePlayer().stop();

      Navigator.pop(context);
    }

    @override
    void dispose() {
      _stepCountSubscription?.cancel();
      _pedestrianStatusSubscription?.cancel();
      audio.stop();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      final progress = _currentSteps / _requiredSteps;
      final cappedProgress = progress > 1.0 ? 1.0 : progress;
      
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'ALARM RINGING!',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 10),
              
              // Status icon
              Icon(
                _status == 'walking'
                    ? Icons.directions_walk
                    : _status == 'stopped'
                        ? Icons.accessibility_new
                        : Icons.error,
                size: 30,
                color: Colors.white,
              ),
              
              // Step counter
              Text(
                "$_currentSteps / $_requiredSteps",
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
              
              // Progress bar
              const SizedBox(height: 10),
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  value: cappedProgress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[800],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00B5FF)),
                ),
              ),
              
              const SizedBox(height: 10),
              const Text(
                'Walk to dismiss',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _dismissAlarm,
                child: const Text("Dismiss"),
              )
            ],
          ),
        ),
      );
    }
  }