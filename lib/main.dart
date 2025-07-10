import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService().init();
  runApp(MyApp());
}

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pk_channel_id',
      'PK Notifications',
      channelDescription: 'Channel for PK new post notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'PK',
      'New Post',
      platformChannelSpecifics,
      payload: 'New Post',
    );
  }

  void schedulePeriodicNotification() {
    final now = tz.TZDateTime.now(tz.local);
    final next = now.add(Duration(hours: 3 - (now.hour % 3), minutes: -now.minute, seconds: -now.second));

    flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'PK',
      'New Post',
      next,
      const NotificationDetails(
          android: AndroidNotificationDetails(
        'pk_channel_id',
        'PK Notifications',
        channelDescription: 'Channel for PK new post notifications',
        importance: Importance.max,
        priority: Priority.high,
      )),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'New Post',
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final WebViewController _controller;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.schedulePeriodicNotification();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('PK - p-k.me'),
          centerTitle: true,
        ),
        body: WebView(
          initialUrl: 'https://p-k.me',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (controller) {
            _controller = controller;
          },
          navigationDelegate: (request) {
            return NavigationDecision.navigate;
          },
          gestureNavigationEnabled: true,
          debuggingEnabled: false,
        ),
      ),
    );
  }
}
