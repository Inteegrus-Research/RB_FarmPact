import 'package:flutter/foundation.dart';
import 'package:farmpact/models/farmer_model.dart';
import 'package:farmpact/services/database_service.dart';
import 'package:uuid/uuid.dart';

class FarmerProvider with ChangeNotifier {
  Farmer? _currentFarmer;
  List<Farmer> _farmers = [];
  bool _isLoading = false;
  String? _error;

  DatabaseService? _databaseService;
  final Uuid _uuid = const Uuid();

  DatabaseService? get databaseService {
    try {
      _databaseService ??= DatabaseService.instance;
      return _databaseService;
    } catch (e) {
      print('Database service not available: $e');
      return null;
    }
  }

  // Getters
  Farmer? get currentFarmer => _currentFarmer;
  List<Farmer> get farmers => _farmers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentFarmer != null;

  Future<void> registerFarmer({
    required String name,
    required String phoneNumber,
    required String email,
    required String address,
    required FarmLocation location,
    String? profileImagePath,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final farmer = Farmer(
        id: _uuid.v4(),
        name: name,
        phoneNumber: phoneNumber,
        email: email,
        address: address,
        location: location,
        farms: [],
        registrationDate: DateTime.now(),
        profileImagePath: profileImagePath,
      );

      try {
        await databaseService?.insertFarmer(farmer);
      } catch (e) {
        if (kIsWeb) {
          // On web, store in memory only
          _farmers.add(farmer);
        } else {
          rethrow;
        }
      }

      _currentFarmer = farmer;

      await loadAllFarmers();
      notifyListeners();
    } catch (e) {
      _setError('Failed to register farmer: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginFarmer(String phoneNumber) async {
    _setLoading(true);
    _setError(null);

    try {
      // In a real app, you would validate OTP here
      List<Farmer> farmers;
      try {
        farmers = await databaseService?.getAllFarmers() ?? [];
      } catch (e) {
        if (kIsWeb) {
          // On web, use in-memory farmers
          farmers = _farmers;
        } else {
          rethrow;
        }
      }

      final farmer = farmers.firstWhere(
        (f) => f.phoneNumber == phoneNumber,
        orElse: () => throw Exception('Farmer not found'),
      );

      _currentFarmer = farmer;
      notifyListeners();
    } catch (e) {
      _setError('Login failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllFarmers() async {
    try {
      _farmers = await databaseService?.getAllFarmers() ?? [];
      notifyListeners();
    } catch (e) {
      if (kIsWeb) {
        // On web, keep current in-memory farmers
        print('Database not available on web, using in-memory storage');
      } else {
        _setError('Failed to load farmers: $e');
      }
    }
  }

  Future<void> updateFarmer(Farmer farmer) async {
    _setLoading(true);
    _setError(null);

    try {
      try {
        await databaseService?.updateFarmer(farmer);
      } catch (e) {
        if (kIsWeb) {
          // On web, update in-memory farmer
          final index = _farmers.indexWhere((f) => f.id == farmer.id);
          if (index >= 0) {
            _farmers[index] = farmer;
          }
        } else {
          rethrow;
        }
      }
      _currentFarmer = farmer;
      await loadAllFarmers();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update farmer: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addFarm(Farm farm) async {
    if (_currentFarmer == null) return;

    _setLoading(true);
    _setError(null);

    try {
      final updatedFarms = List<Farm>.from(_currentFarmer!.farms)..add(farm);
      final updatedFarmer = Farmer(
        id: _currentFarmer!.id,
        name: _currentFarmer!.name,
        phoneNumber: _currentFarmer!.phoneNumber,
        email: _currentFarmer!.email,
        address: _currentFarmer!.address,
        location: _currentFarmer!.location,
        farms: updatedFarms,
        registrationDate: _currentFarmer!.registrationDate,
        profileImagePath: _currentFarmer!.profileImagePath,
      );

      await updateFarmer(updatedFarmer);
    } catch (e) {
      _setError('Failed to add farm: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateFarm(Farm farm) async {
    if (_currentFarmer == null) return;

    _setLoading(true);
    _setError(null);

    try {
      final updatedFarms = _currentFarmer!.farms.map((f) {
        return f.id == farm.id ? farm : f;
      }).toList();

      final updatedFarmer = Farmer(
        id: _currentFarmer!.id,
        name: _currentFarmer!.name,
        phoneNumber: _currentFarmer!.phoneNumber,
        email: _currentFarmer!.email,
        address: _currentFarmer!.address,
        location: _currentFarmer!.location,
        farms: updatedFarms,
        registrationDate: _currentFarmer!.registrationDate,
        profileImagePath: _currentFarmer!.profileImagePath,
      );

      await updateFarmer(updatedFarmer);
    } catch (e) {
      _setError('Failed to update farm: $e');
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _currentFarmer = null;
    _error = null;
    notifyListeners();
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

  // Helper methods for farm data
  double get totalFarmArea {
    if (_currentFarmer == null) return 0.0;
    return _currentFarmer!.farms.fold(0.0, (sum, farm) => sum + farm.area);
  }

  int get totalLivestock {
    if (_currentFarmer == null) return 0;
    return _currentFarmer!.farms
        .expand((farm) => farm.livestock)
        .fold(0, (sum, livestock) => sum + livestock.count);
  }

  int get totalCrops {
    if (_currentFarmer == null) return 0;
    return _currentFarmer!.farms.expand((farm) => farm.crops).length;
  }

  List<Crop> get allCrops {
    if (_currentFarmer == null) return [];
    return _currentFarmer!.farms.expand((farm) => farm.crops).toList();
  }

  List<Livestock> get allLivestock {
    if (_currentFarmer == null) return [];
    return _currentFarmer!.farms.expand((farm) => farm.livestock).toList();
  }
}
