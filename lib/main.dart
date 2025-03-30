import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'dart:isolate';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_check/alarm_screen.dart';
import 'package:audio_check/ringing_screen.dart';

// Unique name for the port
const String isolateName = 'isolate';
// Background port for communication
ReceivePort port = ReceivePort();

// Entry point function that will be invoked by the alarm manager
@pragma('vm:entry-point')
void alarmCallback() async {
  // Get the instance of SendPort
  final SendPort? sendPort = IsolateNameServer.lookupPortByName(isolateName);
  
  // Play alarm sound directly
  FlutterRingtonePlayer().playAlarm(looping: true);
  
  // Send notification through isolate
  sendPort?.send('ALARM_TRIGGERED');
  
  // Save to shared preferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('alarmTriggered', true);
  
  // Show a full-screen notification
  await showFullScreenNotification();
}

// Notification setup
final FlutterLocalNotificationsPlugin flnp = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  // Define the notification channel for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'alarm_channel_id',
    'Alarm Channel',
    description: 'Channel for alarm notifications',
    importance: Importance.max,
    enableVibration: true,
    showBadge: true,
    enableLights: true,
  );

  // Create the notification channel
  await flnp
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Initialize settings
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  
  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
  );

  // Initialize plugin
  await flnp.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse details) {
      // Handle notification taps here
      navigateToRingingScreen();
    },
  );
}

// Global navigator key to access navigation from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Function to navigate to the ringing screen
void navigateToRingingScreen() {
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const RingingScreen()),
    (route) => false,
  );
}

// Show a full-screen intent notification that can open the app even when locked
Future<void> showFullScreenNotification() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'alarm_channel_id',
    'Alarm Channel',
    channelDescription: 'Channel for alarm notifications',
    importance: Importance.max,
    priority: Priority.high,
    fullScreenIntent: true, // This is key for opening on lock screen
    category: AndroidNotificationCategory.alarm,
    visibility: NotificationVisibility.public,
    autoCancel: false,
    ongoing: true,
    sound: null, // We handle sound separately with FlutterRingtonePlayer
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await flnp.show(
    0,
    'Alarm',
    'Time\'s up! Your alarm is ringing.',
    notificationDetails,
    payload: 'ringing_screen',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Register the SendPort for communication
  IsolateNameServer.registerPortWithName(port.sendPort, isolateName);
  
  // Initialize alarm manager
  await AndroidAlarmManager.initialize();
  
  // Initialize notifications
  await initNotifications();
  
  // Listen for alarm triggers from background
  port.listen((message) {
    if (message == 'ALARM_TRIGGERED') {
      showFullScreenNotification();
      navigateToRingingScreen();
    }
  });
  
  // Check if app was launched from a notification
  final NotificationAppLaunchDetails? launchDetails = 
      await flnp.getNotificationAppLaunchDetails();
  
  final bool didLaunchFromNotification = 
      launchDetails?.notificationResponse?.payload == 'ringing_screen';
  
  runApp(App(launchedFromNotification: didLaunchFromNotification));
}

class App extends StatelessWidget {
  final bool launchedFromNotification;
  
  const App({super.key, this.launchedFromNotification = false});

  @override
  Widget build(BuildContext context) {
    return AmbientMode(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        theme: ThemeData(
          useMaterial3: true,
          visualDensity: VisualDensity.compact,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00B5FF),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          visualDensity: VisualDensity.compact,
          colorScheme: const ColorScheme.dark(
            primary: Colors.white24,
            onSurface: Colors.white10,
          ),
        ),
        home: launchedFromNotification 
          ? const RingingScreen() // Go directly to ringing screen if launched from notification
          : const AlarmScreen(),
      ),
      builder: (context, mode, child) {
        // Apply ambient mode theme if needed
        return child!;
      },
    );
  }
}