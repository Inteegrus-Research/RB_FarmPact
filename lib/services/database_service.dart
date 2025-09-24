import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:farmpact/models/farmer_model.dart';
import 'package:farmpact/models/alert_model.dart';
import 'package:farmpact/models/livestock_model.dart';
import 'dart:convert';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError(
          'SQLite database is not supported on web platform');
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'sarvam_farmer.db');

    return await openDatabase(path,
        version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Farmers table
    await db.execute('''
      CREATE TABLE farmers(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        email TEXT,
        address TEXT,
        location TEXT,
        farms TEXT,
        registrationDate TEXT,
        profileImagePath TEXT
      )
    ''');

    // Alerts table
    await db.execute('''
      CREATE TABLE alerts(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        severity TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        validUntil TEXT NOT NULL,
        location TEXT,
        additionalData TEXT,
        isRead INTEGER DEFAULT 0
      )
    ''');

    // Notification settings table
    await db.execute('''
      CREATE TABLE notification_settings(
        id INTEGER PRIMARY KEY,
        enablePushNotifications INTEGER DEFAULT 1,
        enableWhatsAppAlerts INTEGER DEFAULT 0,
        enableEmailAlerts INTEGER DEFAULT 0,
        enabledAlertTypes TEXT,
        enabledSeverityLevels TEXT,
        whatsappNumber TEXT,
        emailAddress TEXT
      )
    ''');

    // Livestock data table
    await db.execute('''
      CREATE TABLE livestock_data(
        id TEXT PRIMARY KEY,
        farmerId TEXT NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        totalAnimals INTEGER NOT NULL,
        newBirths INTEGER DEFAULT 0,
        deaths INTEGER DEFAULT 0,
        feedConsumption REAL DEFAULT 0.0,
        waterConsumption REAL DEFAULT 0.0,
        eggsCollected INTEGER DEFAULT 0,
        averageWeight REAL DEFAULT 0.0,
        healthStatus TEXT DEFAULT 'good',
        notes TEXT DEFAULT '',
        temperature REAL DEFAULT 0.0,
        humidity REAL DEFAULT 0.0,
        FOREIGN KEY(farmerId) REFERENCES farmers(id)
      )
    ''');

    // Insert default notification settings
    await db.insert('notification_settings', {
      'enablePushNotifications': 1,
      'enableWhatsAppAlerts': 0,
      'enableEmailAlerts': 0,
      'enabledAlertTypes': jsonEncode(['weather', 'disease', 'emergency']),
      'enabledSeverityLevels': jsonEncode(['medium', 'high', 'critical']),
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add livestock data table for version 2
      await db.execute('''
        CREATE TABLE livestock_data(
          id TEXT PRIMARY KEY,
          farmerId TEXT NOT NULL,
          type TEXT NOT NULL,
          date TEXT NOT NULL,
          totalAnimals INTEGER NOT NULL,
          newBirths INTEGER DEFAULT 0,
          deaths INTEGER DEFAULT 0,
          feedConsumption REAL DEFAULT 0.0,
          waterConsumption REAL DEFAULT 0.0,
          eggsCollected INTEGER DEFAULT 0,
          averageWeight REAL DEFAULT 0.0,
          healthStatus TEXT DEFAULT 'good',
          notes TEXT DEFAULT '',
          temperature REAL DEFAULT 0.0,
          humidity REAL DEFAULT 0.0,
          FOREIGN KEY(farmerId) REFERENCES farmers(id)
        )
      ''');
    }
  }

  // Farmer operations
  Future<void> insertFarmer(Farmer farmer) async {
    final db = await database;
    await db.insert(
        'farmers',
        {
          'id': farmer.id,
          'name': farmer.name,
          'phoneNumber': farmer.phoneNumber,
          'email': farmer.email,
          'address': farmer.address,
          'location': jsonEncode(farmer.location.toJson()),
          'farms': jsonEncode(farmer.farms.map((f) => f.toJson()).toList()),
          'registrationDate': farmer.registrationDate.toIso8601String(),
          'profileImagePath': farmer.profileImagePath,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Farmer?> getFarmer(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'farmers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return Farmer(
        id: map['id'],
        name: map['name'],
        phoneNumber: map['phoneNumber'],
        email: map['email'],
        address: map['address'],
        location: FarmLocation.fromJson(jsonDecode(map['location'])),
        farms: (jsonDecode(map['farms']) as List)
            .map((f) => Farm.fromJson(f))
            .toList(),
        registrationDate: DateTime.parse(map['registrationDate']),
        profileImagePath: map['profileImagePath'],
      );
    }
    return null;
  }

  Future<List<Farmer>> getAllFarmers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('farmers');

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return Farmer(
        id: map['id'],
        name: map['name'],
        phoneNumber: map['phoneNumber'],
        email: map['email'],
        address: map['address'],
        location: FarmLocation.fromJson(jsonDecode(map['location'])),
        farms: (jsonDecode(map['farms']) as List)
            .map((f) => Farm.fromJson(f))
            .toList(),
        registrationDate: DateTime.parse(map['registrationDate']),
        profileImagePath: map['profileImagePath'],
      );
    });
  }

  Future<void> updateFarmer(Farmer farmer) async {
    final db = await database;
    await db.update(
      'farmers',
      {
        'name': farmer.name,
        'phoneNumber': farmer.phoneNumber,
        'email': farmer.email,
        'address': farmer.address,
        'location': jsonEncode(farmer.location.toJson()),
        'farms': jsonEncode(farmer.farms.map((f) => f.toJson()).toList()),
        'profileImagePath': farmer.profileImagePath,
      },
      where: 'id = ?',
      whereArgs: [farmer.id],
    );
  }

  // Alert operations
  Future<void> insertAlert(WeatherAlert alert) async {
    final db = await database;
    await db.insert(
        'alerts',
        {
          'id': alert.id,
          'title': alert.title,
          'message': alert.message,
          'type': alert.type.toString().split('.').last,
          'severity': alert.severity.toString().split('.').last,
          'timestamp': alert.timestamp.toIso8601String(),
          'validUntil': alert.validUntil.toIso8601String(),
          'location': alert.location != null
              ? jsonEncode(alert.location!.toJson())
              : null,
          'additionalData': alert.additionalData != null
              ? jsonEncode(alert.additionalData!)
              : null,
          'isRead': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<WeatherAlert>> getAlerts({int? limit}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'alerts',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return WeatherAlert(
        id: map['id'],
        title: map['title'],
        message: map['message'],
        type: AlertType.values.firstWhere(
          (e) => e.toString().split('.').last == map['type'],
        ),
        severity: AlertSeverity.values.firstWhere(
          (e) => e.toString().split('.').last == map['severity'],
        ),
        timestamp: DateTime.parse(map['timestamp']),
        validUntil: DateTime.parse(map['validUntil']),
        location: map['location'] != null
            ? FarmLocation.fromJson(jsonDecode(map['location']))
            : null,
        additionalData: map['additionalData'] != null
            ? jsonDecode(map['additionalData'])
            : null,
      );
    });
  }

  Future<void> markAlertAsRead(String alertId) async {
    final db = await database;
    await db.update(
      'alerts',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [alertId],
    );
  }

  // Notification settings operations
  Future<NotificationSettings> getNotificationSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notification_settings',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return NotificationSettings(
        enablePushNotifications: map['enablePushNotifications'] == 1,
        enableWhatsAppAlerts: map['enableWhatsAppAlerts'] == 1,
        enableEmailAlerts: map['enableEmailAlerts'] == 1,
        enabledAlertTypes: (jsonDecode(map['enabledAlertTypes']) as List)
            .map(
              (e) => AlertType.values.firstWhere(
                (type) => type.toString().split('.').last == e,
              ),
            )
            .toList(),
        enabledSeverityLevels:
            (jsonDecode(map['enabledSeverityLevels']) as List)
                .map(
                  (e) => AlertSeverity.values.firstWhere(
                    (severity) => severity.toString().split('.').last == e,
                  ),
                )
                .toList(),
        whatsappNumber: map['whatsappNumber'],
        emailAddress: map['emailAddress'],
      );
    }

    // Return default settings if none exist
    return NotificationSettings(
      enablePushNotifications: true,
      enableWhatsAppAlerts: false,
      enableEmailAlerts: false,
      enabledAlertTypes: [
        AlertType.weather,
        AlertType.disease,
        AlertType.emergency,
      ],
      enabledSeverityLevels: [
        AlertSeverity.medium,
        AlertSeverity.high,
        AlertSeverity.critical,
      ],
    );
  }

  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    final db = await database;
    await db.update(
        'notification_settings',
        {
          'enablePushNotifications': settings.enablePushNotifications ? 1 : 0,
          'enableWhatsAppAlerts': settings.enableWhatsAppAlerts ? 1 : 0,
          'enableEmailAlerts': settings.enableEmailAlerts ? 1 : 0,
          'enabledAlertTypes': jsonEncode(
            settings.enabledAlertTypes
                .map((e) => e.toString().split('.').last)
                .toList(),
          ),
          'enabledSeverityLevels': jsonEncode(
            settings.enabledSeverityLevels
                .map((e) => e.toString().split('.').last)
                .toList(),
          ),
          'whatsappNumber': settings.whatsappNumber,
          'emailAddress': settings.emailAddress,
        },
        where: 'id = 1');
  }

  // Livestock data operations
  Future<void> insertLivestockData(LivestockData data) async {
    final db = await database;
    await db.insert(
        'livestock_data',
        {
          'id': data.id,
          'farmerId': data.farmerId,
          'type': data.type,
          'date': data.date.toIso8601String(),
          'totalAnimals': data.totalAnimals,
          'newBirths': data.newBirths,
          'deaths': data.deaths,
          'feedConsumption': data.feedConsumption,
          'waterConsumption': data.waterConsumption,
          'eggsCollected': data.eggsCollected,
          'averageWeight': data.averageWeight,
          'healthStatus': data.healthStatus,
          'notes': data.notes,
          'temperature': data.temperature,
          'humidity': data.humidity,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<LivestockData>> getAllLivestockData({String? farmerId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'livestock_data',
      where: farmerId != null ? 'farmerId = ?' : null,
      whereArgs: farmerId != null ? [farmerId] : null,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return LivestockData(
        id: map['id'],
        farmerId: map['farmerId'],
        type: map['type'],
        date: DateTime.parse(map['date']),
        totalAnimals: map['totalAnimals'],
        newBirths: map['newBirths'] ?? 0,
        deaths: map['deaths'] ?? 0,
        feedConsumption: (map['feedConsumption'] ?? 0.0).toDouble(),
        waterConsumption: (map['waterConsumption'] ?? 0.0).toDouble(),
        eggsCollected: map['eggsCollected'] ?? 0,
        averageWeight: (map['averageWeight'] ?? 0.0).toDouble(),
        healthStatus: map['healthStatus'] ?? 'good',
        notes: map['notes'] ?? '',
        temperature: (map['temperature'] ?? 0.0).toDouble(),
        humidity: (map['humidity'] ?? 0.0).toDouble(),
      );
    });
  }

  Future<void> updateLivestockData(LivestockData data) async {
    final db = await database;
    await db.update(
      'livestock_data',
      {
        'farmerId': data.farmerId,
        'type': data.type,
        'date': data.date.toIso8601String(),
        'totalAnimals': data.totalAnimals,
        'newBirths': data.newBirths,
        'deaths': data.deaths,
        'feedConsumption': data.feedConsumption,
        'waterConsumption': data.waterConsumption,
        'eggsCollected': data.eggsCollected,
        'averageWeight': data.averageWeight,
        'healthStatus': data.healthStatus,
        'notes': data.notes,
        'temperature': data.temperature,
        'humidity': data.humidity,
      },
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }

  Future<void> deleteLivestockData(String id) async {
    final db = await database;
    await db.delete(
      'livestock_data',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<LivestockData?> getLivestockDataById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'livestock_data',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return LivestockData(
        id: map['id'],
        farmerId: map['farmerId'],
        type: map['type'],
        date: DateTime.parse(map['date']),
        totalAnimals: map['totalAnimals'],
        newBirths: map['newBirths'] ?? 0,
        deaths: map['deaths'] ?? 0,
        feedConsumption: (map['feedConsumption'] ?? 0.0).toDouble(),
        waterConsumption: (map['waterConsumption'] ?? 0.0).toDouble(),
        eggsCollected: map['eggsCollected'] ?? 0,
        averageWeight: (map['averageWeight'] ?? 0.0).toDouble(),
        healthStatus: map['healthStatus'] ?? 'good',
        notes: map['notes'] ?? '',
        temperature: (map['temperature'] ?? 0.0).toDouble(),
        humidity: (map['humidity'] ?? 0.0).toDouble(),
      );
    }
    return null;
  }

  // Daily Report methods
  Future<void> insertDailyReport(Map<String, dynamic> reportData) async {
    final db = await database;

    // Create daily_reports table if it doesn't exist
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_reports(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        farmer_id TEXT NOT NULL,
        date TEXT NOT NULL,
        weather TEXT,
        temperature REAL,
        general_notes TEXT,
        livestock_data TEXT,
        crop_activity TEXT,
        crop_notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.insert(
      'daily_reports',
      {
        'farmer_id': reportData['farmer_id'],
        'date': reportData['date'],
        'weather': reportData['weather'],
        'temperature': reportData['temperature'],
        'general_notes': reportData['general_notes'],
        'livestock_data': jsonEncode(reportData['livestock_data']),
        'crop_activity': reportData['crop_activity'],
        'crop_notes': reportData['crop_notes'],
        'created_at': reportData['created_at'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getDailyReports(String farmerId) async {
    final db = await database;
    return await db.query(
      'daily_reports',
      where: 'farmer_id = ?',
      whereArgs: [farmerId],
      orderBy: 'date DESC',
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
