import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:farmpact/models/alert_model.dart';
import 'package:farmpact/services/database_service.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> initialize() async {
    if (kIsWeb) {
      print('Notification service not available on web platform');
      return;
    }

    try {
      // Request notification permissions
      await _requestPermissions();

      // Initialize the plugin
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );
    } catch (e) {
      print('Failed to initialize notifications: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  Future<void> showAlert(WeatherAlert alert) async {
    // Save alert to database
    await DatabaseService.instance.insertAlert(alert);

    // Check notification settings
    final settings = await DatabaseService.instance.getNotificationSettings();

    if (settings.enablePushNotifications) {
      await _showLocalNotification(alert);
    }

    if (settings.enableWhatsAppAlerts && settings.whatsappNumber != null) {
      await _sendWhatsAppAlert(alert, settings.whatsappNumber!);
    }
  }

  Future<void> _showLocalNotification(WeatherAlert alert) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'sarvam_alerts',
      'Farm Alerts',
      channelDescription: 'Important alerts for farmers',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      alert.id.hashCode,
      alert.title,
      alert.message,
      platformChannelSpecifics,
      payload: alert.id,
    );
  }

  Future<void> _sendWhatsAppAlert(
      WeatherAlert alert, String phoneNumber) async {
    try {
      final message = '''
🚨 *${alert.title}*

${alert.message}

Severity: ${alert.severity.toString().split('.').last.toUpperCase()}
Time: ${alert.timestamp.toString()}

- Sarvam Farmer App
''';

      final whatsappUrl = Uri.parse(
          'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error sending WhatsApp alert: $e');
    }
  }

  Future<void> sendWhatsAppMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final whatsappUrl = Uri.parse(
          'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error sending WhatsApp message: $e');
    }
  }

  Future<void> showWeatherAlert({
    required String title,
    required String message,
    AlertSeverity severity = AlertSeverity.medium,
  }) async {
    final alert = WeatherAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: AlertType.weather,
      severity: severity,
      timestamp: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(hours: 24)),
    );

    await showAlert(alert);
  }

  Future<void> showDiseaseAlert({
    required String title,
    required String message,
    AlertSeverity severity = AlertSeverity.high,
  }) async {
    final alert = WeatherAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: AlertType.disease,
      severity: severity,
      timestamp: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 7)),
    );

    await showAlert(alert);
  }

  Future<void> showEmergencyAlert({
    required String title,
    required String message,
  }) async {
    final alert = WeatherAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: AlertType.emergency,
      severity: AlertSeverity.critical,
      timestamp: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(hours: 1)),
    );

    await showAlert(alert);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
