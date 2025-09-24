class LivestockData {
  final String id;
  final String farmerId;
  final String type; // 'pig' or 'chicken'
  final DateTime date;
  final int totalAnimals;
  final int newBirths;
  final int deaths;
  final double feedConsumption; // in kg
  final double waterConsumption; // in liters
  final int eggsCollected; // for chickens only
  final double averageWeight; // in kg
  final String healthStatus; // 'good', 'fair', 'poor'
  final String notes;
  final double temperature; // environmental temperature
  final double humidity; // environmental humidity

  LivestockData({
    required this.id,
    required this.farmerId,
    required this.type,
    required this.date,
    required this.totalAnimals,
    this.newBirths = 0,
    this.deaths = 0,
    this.feedConsumption = 0.0,
    this.waterConsumption = 0.0,
    this.eggsCollected = 0,
    this.averageWeight = 0.0,
    this.healthStatus = 'good',
    this.notes = '',
    this.temperature = 0.0,
    this.humidity = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'type': type,
      'date': date.toIso8601String(),
      'totalAnimals': totalAnimals,
      'newBirths': newBirths,
      'deaths': deaths,
      'feedConsumption': feedConsumption,
      'waterConsumption': waterConsumption,
      'eggsCollected': eggsCollected,
      'averageWeight': averageWeight,
      'healthStatus': healthStatus,
      'notes': notes,
      'temperature': temperature,
      'humidity': humidity,
    };
  }

  factory LivestockData.fromJson(Map<String, dynamic> json) {
    return LivestockData(
      id: json['id'],
      farmerId: json['farmerId'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      totalAnimals: json['totalAnimals'],
      newBirths: json['newBirths'] ?? 0,
      deaths: json['deaths'] ?? 0,
      feedConsumption: (json['feedConsumption'] ?? 0.0).toDouble(),
      waterConsumption: (json['waterConsumption'] ?? 0.0).toDouble(),
      eggsCollected: json['eggsCollected'] ?? 0,
      averageWeight: (json['averageWeight'] ?? 0.0).toDouble(),
      healthStatus: json['healthStatus'] ?? 'good',
      notes: json['notes'] ?? '',
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0.0).toDouble(),
    );
  }

  // Calculate mortality rate for the day
  double get mortalityRate {
    if (totalAnimals == 0) return 0.0;
    return (deaths / totalAnimals) * 100;
  }

  // Calculate feed efficiency (weight gain per kg of feed)
  double get feedEfficiency {
    if (feedConsumption == 0) return 0.0;
    return averageWeight / feedConsumption;
  }

  LivestockData copyWith({
    String? id,
    String? farmerId,
    String? type,
    DateTime? date,
    int? totalAnimals,
    int? newBirths,
    int? deaths,
    double? feedConsumption,
    double? waterConsumption,
    int? eggsCollected,
    double? averageWeight,
    String? healthStatus,
    String? notes,
    double? temperature,
    double? humidity,
  }) {
    return LivestockData(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      type: type ?? this.type,
      date: date ?? this.date,
      totalAnimals: totalAnimals ?? this.totalAnimals,
      newBirths: newBirths ?? this.newBirths,
      deaths: deaths ?? this.deaths,
      feedConsumption: feedConsumption ?? this.feedConsumption,
      waterConsumption: waterConsumption ?? this.waterConsumption,
      eggsCollected: eggsCollected ?? this.eggsCollected,
      averageWeight: averageWeight ?? this.averageWeight,
      healthStatus: healthStatus ?? this.healthStatus,
      notes: notes ?? this.notes,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
    );
  }
}

class LivestockAnalytics {
  final List<LivestockData> data;

  LivestockAnalytics(this.data);

  // Get data for a specific type (pig or chicken)
  List<LivestockData> getDataByType(String type) {
    return data.where((item) => item.type == type).toList();
  }

  // Calculate average mortality rate over time
  double getAverageMortalityRate(String type, {int? days}) {
    var typeData = getDataByType(type);
    if (days != null) {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      typeData =
          typeData.where((item) => item.date.isAfter(cutoffDate)).toList();
    }

    if (typeData.isEmpty) return 0.0;
    return typeData.map((e) => e.mortalityRate).reduce((a, b) => a + b) /
        typeData.length;
  }

  // Calculate total production (eggs for chickens)
  int getTotalEggsCollected({int? days}) {
    var chickenData = getDataByType('chicken');
    if (days != null) {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      chickenData =
          chickenData.where((item) => item.date.isAfter(cutoffDate)).toList();
    }

    return chickenData.map((e) => e.eggsCollected).fold(0, (a, b) => a + b);
  }

  // Calculate average daily weight gain
  double getAverageWeightGain(String type, {int? days}) {
    var typeData = getDataByType(type);
    if (days != null) {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      typeData =
          typeData.where((item) => item.date.isAfter(cutoffDate)).toList();
    }

    if (typeData.length < 2) return 0.0;

    typeData.sort((a, b) => a.date.compareTo(b.date));
    final firstWeight = typeData.first.averageWeight;
    final lastWeight = typeData.last.averageWeight;
    final daysDiff = typeData.last.date.difference(typeData.first.date).inDays;

    if (daysDiff == 0) return 0.0;
    return (lastWeight - firstWeight) / daysDiff;
  }

  // Calculate feed consumption trends
  double getAverageFeedConsumption(String type, {int? days}) {
    var typeData = getDataByType(type);
    if (days != null) {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      typeData =
          typeData.where((item) => item.date.isAfter(cutoffDate)).toList();
    }

    if (typeData.isEmpty) return 0.0;
    return typeData.map((e) => e.feedConsumption).reduce((a, b) => a + b) /
        typeData.length;
  }

  // Get health status distribution
  Map<String, int> getHealthStatusDistribution(String type, {int? days}) {
    var typeData = getDataByType(type);
    if (days != null) {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      typeData =
          typeData.where((item) => item.date.isAfter(cutoffDate)).toList();
    }

    final distribution = <String, int>{};
    for (final item in typeData) {
      distribution[item.healthStatus] =
          (distribution[item.healthStatus] ?? 0) + 1;
    }

    return distribution;
  }
}
