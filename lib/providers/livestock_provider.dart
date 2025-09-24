import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:farmpact/models/livestock_model.dart';
import 'package:farmpact/services/database_service.dart';
import 'package:uuid/uuid.dart';

class LivestockProvider with ChangeNotifier {
  DatabaseService? _databaseService;
  final List<LivestockData> _livestockData = [];
  final Uuid _uuid = const Uuid();

  bool _isLoading = false;
  String? _error;

  DatabaseService? get databaseService {
    try {
      _databaseService ??= DatabaseService.instance;
      return _databaseService;
    } catch (e) {
      print('Database service not available: $e');
      return null;
    }
  }

  List<LivestockData> get livestockData => List.unmodifiable(_livestockData);
  bool get isLoading => _isLoading;
  String? get error => _error;

  LivestockAnalytics get analytics => LivestockAnalytics(_livestockData);

  // Get data for a specific farmer
  List<LivestockData> getDataForFarmer(String farmerId) {
    return _livestockData.where((data) => data.farmerId == farmerId).toList();
  }

  // Get data for a specific type (pig or chicken)
  List<LivestockData> getDataByType(String type) {
    return _livestockData.where((data) => data.type == type).toList();
  }

  // Get recent data (last 30 days)
  List<LivestockData> getRecentData({int days = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _livestockData
        .where((data) => data.date.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Add new livestock data entry
  Future<void> addLivestockData(LivestockData data) async {
    _setLoading(true);
    try {
      final newData = data.copyWith(id: _uuid.v4());
      try {
        await databaseService?.insertLivestockData(newData);
      } catch (e) {
        if (kIsWeb) {
          // On web, add to in-memory storage
          print('Database not available on web, using in-memory storage');
        } else {
          rethrow;
        }
      }
      _livestockData.add(newData);
      _livestockData.sort((a, b) => b.date.compareTo(a.date));
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to add livestock data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update existing livestock data
  Future<void> updateLivestockData(LivestockData data) async {
    _setLoading(true);
    try {
      try {
        await databaseService?.updateLivestockData(data);
      } catch (e) {
        if (kIsWeb) {
          // On web, update in-memory storage
          print('Database not available on web, using in-memory storage');
        } else {
          rethrow;
        }
      }
      final index = _livestockData.indexWhere((item) => item.id == data.id);
      if (index != -1) {
        _livestockData[index] = data;
        notifyListeners();
      }
      _clearError();
    } catch (e) {
      _setError('Failed to update livestock data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete livestock data
  Future<void> deleteLivestockData(String id) async {
    _setLoading(true);
    try {
      try {
        await databaseService?.deleteLivestockData(id);
      } catch (e) {
        if (kIsWeb) {
          // On web, delete from in-memory storage
          print('Database not available on web, using in-memory storage');
        } else {
          rethrow;
        }
      }
      _livestockData.removeWhere((item) => item.id == id);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete livestock data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load all livestock data
  Future<void> loadLivestockData({String? farmerId}) async {
    _setLoading(true);
    try {
      List<LivestockData> data;
      try {
        data = await databaseService?.getAllLivestockData(farmerId: farmerId) ??
            [];
      } catch (e) {
        if (kIsWeb) {
          // On web, use current in-memory data
          print('Database not available on web, using in-memory storage');
          data = farmerId != null
              ? _livestockData.where((d) => d.farmerId == farmerId).toList()
              : _livestockData;
        } else {
          rethrow;
        }
      }
      _livestockData.clear();
      _livestockData.addAll(data);
      _livestockData.sort((a, b) => b.date.compareTo(a.date));
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load livestock data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get today's data for a specific type
  LivestockData? getTodayData(String farmerId, String type) {
    final today = DateTime.now();
    return _livestockData.cast<LivestockData?>().firstWhere(
          (data) =>
              data?.farmerId == farmerId &&
              data?.type == type &&
              data?.date.year == today.year &&
              data?.date.month == today.month &&
              data?.date.day == today.day,
          orElse: () => null,
        );
  }

  // Calculate statistics for dashboard
  Map<String, dynamic> getStatistics(String farmerId, String type) {
    final farmerData = _livestockData
        .where((data) => data.farmerId == farmerId && data.type == type)
        .toList();

    if (farmerData.isEmpty) {
      return {
        'totalAnimals': 0,
        'averageMortality': 0.0,
        'totalEggs': 0,
        'averageWeight': 0.0,
        'feedEfficiency': 0.0,
        'healthStatus': 'Unknown',
      };
    }

    final recent = farmerData.take(7).toList(); // Last 7 days
    final latest = farmerData.first;

    return {
      'totalAnimals': latest.totalAnimals,
      'averageMortality': recent.isNotEmpty
          ? recent.map((e) => e.mortalityRate).reduce((a, b) => a + b) /
              recent.length
          : 0.0,
      'totalEggs': type == 'chicken'
          ? recent.map((e) => e.eggsCollected).fold(0, (a, b) => a + b)
          : 0,
      'averageWeight': recent.isNotEmpty
          ? recent.map((e) => e.averageWeight).reduce((a, b) => a + b) /
              recent.length
          : 0.0,
      'feedEfficiency': recent.isNotEmpty
          ? recent.map((e) => e.feedEfficiency).reduce((a, b) => a + b) /
              recent.length
          : 0.0,
      'healthStatus': latest.healthStatus,
      'trend': _calculateTrend(farmerData, type),
    };
  }

  // Calculate trend data for charts
  Map<String, dynamic> _calculateTrend(List<LivestockData> data, String type) {
    if (data.length < 2) return {'direction': 'stable', 'percentage': 0.0};

    data.sort((a, b) => a.date.compareTo(b.date));
    final recent = data.take(7).toList();
    final previous = data.skip(7).take(7).toList();

    if (recent.isEmpty || previous.isEmpty) {
      return {'direction': 'stable', 'percentage': 0.0};
    }

    final recentAvg =
        recent.map((e) => e.totalAnimals).reduce((a, b) => a + b) /
            recent.length;
    final previousAvg =
        previous.map((e) => e.totalAnimals).reduce((a, b) => a + b) /
            previous.length;

    final change = ((recentAvg - previousAvg) / previousAvg) * 100;
    final direction = change > 5
        ? 'increasing'
        : change < -5
            ? 'decreasing'
            : 'stable';

    return {
      'direction': direction,
      'percentage': change.abs(),
    };
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Get alerts based on livestock data
  List<Map<String, dynamic>> getAlerts(String farmerId) {
    final alerts = <Map<String, dynamic>>[];
    final farmerData = getDataForFarmer(farmerId);

    if (farmerData.isEmpty) return alerts;

    // Check for high mortality rates
    for (final data in farmerData.take(7)) {
      if (data.mortalityRate > 5.0) {
        alerts.add({
          'type': 'high_mortality',
          'severity': 'high',
          'title': 'High Mortality Rate Alert',
          'message':
              'Mortality rate of ${data.mortalityRate.toStringAsFixed(1)}% detected in ${data.type} farm on ${data.date.day}/${data.date.month}',
          'location': {'lat': 0.0, 'lng': 0.0}, // Add actual farm location
          'timestamp': data.date,
        });
      }
    }

    // Check for low egg production (chickens only)
    final chickenData =
        farmerData.where((d) => d.type == 'chicken').take(3).toList();
    if (chickenData.isNotEmpty) {
      final avgEggs =
          chickenData.map((e) => e.eggsCollected).reduce((a, b) => a + b) /
              chickenData.length;
      final expectedEggs =
          chickenData.first.totalAnimals * 0.8; // 80% laying rate

      if (avgEggs < expectedEggs * 0.7) {
        alerts.add({
          'type': 'low_production',
          'severity': 'medium',
          'title': 'Low Egg Production',
          'message':
              'Egg production is ${((expectedEggs - avgEggs) / expectedEggs * 100).toStringAsFixed(1)}% below expected levels',
          'location': {'lat': 0.0, 'lng': 0.0},
          'timestamp': DateTime.now(),
        });
      }
    }

    // Check for poor health status
    for (final data in farmerData.take(3)) {
      if (data.healthStatus == 'poor') {
        alerts.add({
          'type': 'health_warning',
          'severity': 'high',
          'title': 'Poor Health Status',
          'message':
              'Poor health status reported for ${data.type} farm on ${data.date.day}/${data.date.month}',
          'location': {'lat': 0.0, 'lng': 0.0},
          'timestamp': data.date,
        });
      }
    }

    return alerts;
  }
}
