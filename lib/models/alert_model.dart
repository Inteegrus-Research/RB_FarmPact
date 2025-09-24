import 'package:farmpact/models/farmer_model.dart';

class WeatherAlert {
  final String id;
  final String title;
  final String message;
  final AlertType type;
  final AlertSeverity severity;
  final DateTime timestamp;
  final DateTime validUntil;
  final FarmLocation? location;
  final Map<String, dynamic>? additionalData;

  WeatherAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.severity,
    required this.timestamp,
    required this.validUntil,
    this.location,
    this.additionalData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'severity': severity.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'location': location?.toJson(),
      'additionalData': additionalData,
    };
  }

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: AlertType.values
          .firstWhere((e) => e.toString().split('.').last == json['type']),
      severity: AlertSeverity.values
          .firstWhere((e) => e.toString().split('.').last == json['severity']),
      timestamp: DateTime.parse(json['timestamp']),
      validUntil: DateTime.parse(json['validUntil']),
      location: json['location'] != null
          ? FarmLocation.fromJson(json['location'])
          : null,
      additionalData: json['additionalData'],
    );
  }
}

enum AlertType { weather, disease, emergency, maintenance, market, government }

enum AlertSeverity { low, medium, high, critical }

class NotificationSettings {
  final bool enablePushNotifications;
  final bool enableWhatsAppAlerts;
  final bool enableEmailAlerts;
  final List<AlertType> enabledAlertTypes;
  final List<AlertSeverity> enabledSeverityLevels;
  final String? whatsappNumber;
  final String? emailAddress;

  NotificationSettings({
    required this.enablePushNotifications,
    required this.enableWhatsAppAlerts,
    required this.enableEmailAlerts,
    required this.enabledAlertTypes,
    required this.enabledSeverityLevels,
    this.whatsappNumber,
    this.emailAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'enablePushNotifications': enablePushNotifications,
      'enableWhatsAppAlerts': enableWhatsAppAlerts,
      'enableEmailAlerts': enableEmailAlerts,
      'enabledAlertTypes':
          enabledAlertTypes.map((e) => e.toString().split('.').last).toList(),
      'enabledSeverityLevels': enabledSeverityLevels
          .map((e) => e.toString().split('.').last)
          .toList(),
      'whatsappNumber': whatsappNumber,
      'emailAddress': emailAddress,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enablePushNotifications: json['enablePushNotifications'],
      enableWhatsAppAlerts: json['enableWhatsAppAlerts'],
      enableEmailAlerts: json['enableEmailAlerts'],
      enabledAlertTypes: (json['enabledAlertTypes'] as List)
          .map((e) => AlertType.values
              .firstWhere((type) => type.toString().split('.').last == e))
          .toList(),
      enabledSeverityLevels: (json['enabledSeverityLevels'] as List)
          .map((e) => AlertSeverity.values.firstWhere(
              (severity) => severity.toString().split('.').last == e))
          .toList(),
      whatsappNumber: json['whatsappNumber'],
      emailAddress: json['emailAddress'],
    );
  }
}
