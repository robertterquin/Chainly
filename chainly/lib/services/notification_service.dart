import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/reminder.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  debugPrint('Handling background message: ${message.messageId}');
}

/// Notification Service
/// Handles push notifications and local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  static const String _channelId = 'chainly_reminders';
  static const String _channelName = 'Maintenance Reminders';
  static const String _channelDescription = 'Notifications for bike maintenance reminders';

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Initialize Firebase Cloud Messaging (not for web)
    if (!kIsWeb) {
      await _initializeFirebaseMessaging();
    }

    _isInitialized = true;
    debugPrint('NotificationService initialized');
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (!kIsWeb && Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request permission
    await requestPermission();

    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listen for background message tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle initial message (app opened from terminated state)
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    if (kIsWeb) return true;

    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    
    debugPrint('Notification permission granted: $granted');
    return granted;
  }

  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.notification?.title}');
    
    // Show local notification when app is in foreground
    if (message.notification != null) {
      showNotification(
        title: message.notification!.title ?? 'Chainly',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Handle message when app is opened from notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.notification?.title}');
    // Navigate to specific screen based on message data
    // This can be expanded to navigate to specific reminders
  }

  /// Handle notification tap (local notifications)
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Navigate to specific screen based on payload
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Schedule a notification for a reminder
  Future<void> scheduleReminderNotification(Reminder reminder) async {
    if (reminder.dueDate == null || reminder.id == null) return;

    // Generate a unique notification ID from reminder ID
    final notificationId = reminder.id.hashCode;

    // Schedule notification for the due date
    await _scheduleNotification(
      id: notificationId,
      title: 'Maintenance Due: ${reminder.title}',
      body: 'Time to perform maintenance on your bike!',
      scheduledDate: reminder.dueDate!,
      payload: 'reminder:${reminder.id}',
    );

    // Also schedule a reminder 1 day before if due date is more than 1 day away
    final dayBefore = reminder.dueDate!.subtract(const Duration(days: 1));
    if (dayBefore.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: notificationId + 1000000, // Offset ID for day-before notification
        title: 'Upcoming Maintenance: ${reminder.title}',
        body: 'Maintenance due tomorrow!',
        scheduledDate: dayBefore,
        payload: 'reminder:${reminder.id}',
      );
    }

    debugPrint('Scheduled notification for reminder: ${reminder.title}');
  }

  /// Schedule a notification at a specific time
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // Don't schedule if date is in the past
    if (scheduledDate.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convert to TZDateTime
    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
    await _localNotifications.cancel(id + 1000000); // Cancel day-before notification too
  }

  /// Cancel notification for a reminder
  Future<void> cancelReminderNotification(Reminder reminder) async {
    if (reminder.id == null) return;
    final notificationId = reminder.id.hashCode;
    await cancelNotification(notificationId);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  /// Set notifications enabled/disabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    
    if (!enabled) {
      await cancelAllNotifications();
    }
  }

  /// Get FCM token for push notifications
  Future<String?> getFCMToken() async {
    if (kIsWeb) return null;
    return await _firebaseMessaging.getToken();
  }

  /// Subscribe to a topic for push notifications
  Future<void> subscribeToTopic(String topic) async {
    if (kIsWeb) return;
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (kIsWeb) return;
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}
