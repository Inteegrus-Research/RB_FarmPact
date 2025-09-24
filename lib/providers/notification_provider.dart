import 'package:flutter/foundation.dart';
import 'package:farmpact/models/alert_model.dart';
import 'package:farmpact/services/notification_service.dart';
import 'package:farmpact/models/farmer_model.dart';

class NotificationProvider with ChangeNotifier {
  List<WeatherAlert> _alerts = [];
  NotificationSettings _settings = NotificationSettings(
    enablePushNotifications: true,
    enableWhatsAppAlerts: false,
    enableEmailAlerts: false,
    enabledAlertTypes: AlertType.values,
    enabledSeverityLevels: AlertSeverity.values,
  );
  bool _isLoading = false;
  String? _error;

  NotificationService? _notificationService;

  NotificationService? get notificationService {
    try {
      _notificationService ??= NotificationService.instance;
      return _notificationService;
    } catch (e) {
      print('Notification service not available: $e');
      return null;
    }
  }

  // Getters
  List<WeatherAlert> get alerts => _alerts;
  NotificationSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<WeatherAlert> get urgentAlerts => _alerts
      .where((alert) =>
          alert.severity == AlertSeverity.critical ||
          alert.severity == AlertSeverity.high)
      .toList();

  int get urgentCount => urgentAlerts.length;

  Future<void> initialize() async {
    _setLoading(true);

    try {
      await notificationService?.initialize();
      await loadSettings();
      await loadAlerts();
    } catch (e) {
      _setError('Failed to initialize notifications: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAlerts() async {
    try {
      // For now, create sample alerts since database methods don't exist yet
      _alerts = _createSampleAlerts();
      _alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    } catch (e) {
      _setError('Failed to load alerts: $e');
    }
  }

  Future<void> loadSettings() async {
    try {
      // For now, use default settings since database method doesn't exist yet
      _settings = NotificationSettings(
        enablePushNotifications: true,
        enableWhatsAppAlerts: false,
        enableEmailAlerts: false,
        enabledAlertTypes: AlertType.values,
        enabledSeverityLevels: AlertSeverity.values,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load settings: $e');
    }
  }

  Future<void> sendAlert({
    required AlertType type,
    required String title,
    required String message,
    AlertSeverity severity = AlertSeverity.medium,
    FarmLocation? location,
    Map<String, dynamic>? additionalData,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final alert = WeatherAlert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        title: title,
        message: message,
        severity: severity,
        timestamp: DateTime.now(),
        validUntil: DateTime.now().add(const Duration(hours: 24)),
        location: location,
        additionalData: additionalData ?? {},
      );

      // Add to local list
      _alerts.insert(0, alert);

      // Send notification based on settings
      if (_shouldSendNotification(type, severity)) {
        await notificationService?.showAlert(alert);

        // Send WhatsApp alert if enabled and urgent
        if (_settings.enableWhatsAppAlerts && _isUrgentAlert(severity)) {
          await notificationService?.sendWhatsAppMessage(
            phoneNumber: _settings.whatsappNumber ?? '',
            message: '${alert.title}\n\n${alert.message}',
          );
        }
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to send alert: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAlert(String alertId) async {
    try {
      _alerts.removeWhere((alert) => alert.id == alertId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete alert: $e');
    }
  }

  Future<void> clearAllAlerts() async {
    _setLoading(true);

    try {
      _alerts.clear();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear all alerts: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateSettings(NotificationSettings newSettings) async {
    _setLoading(true);
    _setError(null);

    try {
      _settings = newSettings;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> testNotification() async {
    await sendAlert(
      type: AlertType.weather,
      title: 'Test Notification',
      message: 'This is a test notification to verify your settings.',
      severity: AlertSeverity.low,
    );
  }

  Future<void> sendWeatherAlert({
    required String title,
    required String message,
    required AlertSeverity severity,
    FarmLocation? location,
  }) async {
    await sendAlert(
      type: AlertType.weather,
      title: title,
      message: message,
      severity: severity,
      location: location,
    );
  }

  Future<void> sendDiseaseAlert({
    required String title,
    required String message,
    required AlertSeverity severity,
    String? cropName,
  }) async {
    await sendAlert(
      type: AlertType.disease,
      title: title,
      message: message,
      severity: severity,
      additionalData: cropName != null ? {'cropName': cropName} : null,
    );
  }

  Future<void> sendMarketAlert({
    required String title,
    required String message,
    required AlertSeverity severity,
    Map<String, dynamic>? priceData,
  }) async {
    await sendAlert(
      type: AlertType.market,
      title: title,
      message: message,
      severity: severity,
      additionalData: priceData,
    );
  }

  bool _shouldSendNotification(AlertType type, AlertSeverity severity) {
    if (!_settings.enablePushNotifications) return false;

    return _settings.enabledAlertTypes.contains(type) &&
        _settings.enabledSeverityLevels.contains(severity);
  }

  bool _isUrgentAlert(AlertSeverity severity) {
    return severity == AlertSeverity.critical || severity == AlertSeverity.high;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Filter methods
  List<WeatherAlert> getAlertsByType(AlertType type) {
    return _alerts.where((alert) => alert.type == type).toList();
  }

  List<WeatherAlert> getAlertsBySeverity(AlertSeverity severity) {
    return _alerts.where((alert) => alert.severity == severity).toList();
  }

  List<WeatherAlert> getTodaysAlerts() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _alerts
        .where((alert) =>
            alert.timestamp.isAfter(startOfDay) &&
            alert.timestamp.isBefore(endOfDay))
        .toList();
  }

  // Quick alert methods for common scenarios
  Future<void> sendDroughtWarning(String location) async {
    await sendWeatherAlert(
      title: 'Drought Warning',
      message:
          'Drought conditions expected in $location. Consider water conservation measures.',
      severity: AlertSeverity.high,
    );
  }

  Future<void> sendRainAlert(String location) async {
    await sendWeatherAlert(
      title: 'Heavy Rain Alert',
      message:
          'Heavy rainfall expected in $location. Protect crops and livestock.',
      severity: AlertSeverity.medium,
    );
  }

  Future<void> sendPestAlert(String cropName) async {
    await sendDiseaseAlert(
      title: 'Pest Alert',
      message:
          'Pest activity detected in $cropName crops. Take preventive measures.',
      severity: AlertSeverity.medium,
      cropName: cropName,
    );
  }

  Future<void> sendPriceAlert(String commodity, double price) async {
    await sendMarketAlert(
      title: 'Price Alert',
      message: '$commodity prices have reached ₹$price per unit.',
      severity: AlertSeverity.low,
      priceData: {
        'commodity': commodity,
        'price': price,
        'currency': 'INR',
      },
    );
  }

  List<WeatherAlert> _createSampleAlerts() {
    return [
      WeatherAlert(
        id: '1',
        type: AlertType.weather,
        title: 'Heavy Rainfall Warning',
        message:
            'Heavy rainfall expected in your area for the next 24 hours. Secure livestock and protect crops.',
        severity: AlertSeverity.high,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        validUntil: DateTime.now().add(const Duration(hours: 22)),
      ),
      WeatherAlert(
        id: '2',
        type: AlertType.disease,
        title: 'Crop Disease Alert',
        message:
            'Brown spot disease detected in nearby rice fields. Monitor your crops closely.',
        severity: AlertSeverity.medium,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        validUntil: DateTime.now().add(const Duration(days: 3)),
      ),
      WeatherAlert(
        id: '3',
        type: AlertType.market,
        title: 'Market Price Update',
        message:
            'Wheat prices have increased by 8% this week. Good time to sell if you have stock.',
        severity: AlertSeverity.low,
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        validUntil: DateTime.now().add(const Duration(days: 7)),
      ),
    ];
  }
}
