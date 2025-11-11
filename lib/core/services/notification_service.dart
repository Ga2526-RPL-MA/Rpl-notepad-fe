import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _flnp =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Init timezone
    tz.initializeTimeZones();
    final String localTz = await _safeGetLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz));

    // Init plugin
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings iosInit =
        const DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _flnp.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    // Android Notification
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'tasks_deadline_channel',
      'Task Deadlines',
      description: 'Reminders for upcoming task deadlines',
      importance: Importance.high,
    );
    await _flnp
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _initialized = true;
    debugPrint('[Notif] init completed. timezone=$localTz');
  }

  // iOS Notification
  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      final ios = _flnp
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final android = _flnp
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestNotificationsPermission();
      try {
        await android?.requestExactAlarmsPermission();
      } catch (_) {}
    }
  }

  // Schedule H-1 reminder
  Future<void> scheduleHMinusOne({
    required int id,
    required DateTime deadline,
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();

    final nowTz = tz.TZDateTime.now(tz.local);

    // UTC to Local
    final localDeadline = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
      deadline.hour,
      deadline.minute,
      deadline.second,
      deadline.millisecond,
      deadline.microsecond,
    );

    // Local to TZDateTime
    final tzDeadline = tz.TZDateTime.from(localDeadline, tz.local);

    // TZDateTime - 1 day
    final oneDayBeforeTz = tzDeadline.subtract(const Duration(days: 1));

    final scheduleTz = oneDayBeforeTz.isAfter(nowTz)
        ? oneDayBeforeTz
        : nowTz.add(const Duration(seconds: 5));

    debugPrint(
      '[Notif] scheduleHMinusOne id=$id '
      'deadline=$deadline (UTC) '
      'localDeadline=$localDeadline '
      'oneDayBefore=$oneDayBeforeTz '
      'scheduleAt=$scheduleTz',
    );

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'tasks_deadline_channel',
        'Task Deadlines',
        channelDescription: 'Reminders for upcoming task deadlines',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _flnp.zonedSchedule(
      id,
      title,
      body,
      scheduleTz,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );

    debugPrint('[Notif] scheduled id=$id at=$scheduleTz title=$title');
  }

  Future<void> cancel(int id) async {
    debugPrint('[Notif] cancel id=$id');
    await _flnp.cancel(id);
  }

  Future<void> cancelAll() async {
    debugPrint('[Notif] cancelAll');
    await _flnp.cancelAll();
  }

  Future<String> _safeGetLocalTimezone() async {
    try {
      final dynamic localTz = await FlutterTimezone.getLocalTimezone();
      if (localTz is String) {
        return localTz;
      }
      try {
        final name = (localTz as dynamic).name as String?;
        if (name != null && name.isNotEmpty) return name;
      } catch (_) {}
      try {
        final tzName = (localTz as dynamic).timezone as String?;
        if (tzName != null && tzName.isNotEmpty) return tzName;
      } catch (_) {}
      return 'Asia/Jakarta';
    } catch (_) {
      return 'Asia/Jakarta';
    }
  }
}
