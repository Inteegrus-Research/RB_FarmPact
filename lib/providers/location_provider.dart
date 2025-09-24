import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:farmpact/models/farmer_model.dart';
import 'package:farmpact/services/location_service.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  Placemark? _currentPlacemark;
  List<FarmLocation> _nearbyFarms = [];
  bool _isLoadingLocation = false;
  String? _locationError;

  LocationService? _locationService;

  LocationService? get locationService {
    try {
      _locationService ??= LocationService.instance;
      return _locationService;
    } catch (e) {
      print('Location service not available: $e');
      return null;
    }
  }

  // Getters
  Position? get currentPosition => _currentPosition;
  Placemark? get currentPlacemark => _currentPlacemark;
  List<FarmLocation> get nearbyFarms => _nearbyFarms;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get locationError => _locationError;
  bool get hasLocation => _currentPosition != null;

  String get currentAddress {
    if (_currentPlacemark == null) {
      return 'Location not available';
    }

    final parts = <String>[];
    if (_currentPlacemark!.name != null) parts.add(_currentPlacemark!.name!);
    if (_currentPlacemark!.locality != null) {
      parts.add(_currentPlacemark!.locality!);
    }
    if (_currentPlacemark!.administrativeArea != null) {
      parts.add(_currentPlacemark!.administrativeArea!);
    }
    if (_currentPlacemark!.postalCode != null) {
      parts.add(_currentPlacemark!.postalCode!);
    }

    return parts.isNotEmpty ? parts.join(', ') : 'Address not available';
  }

  double? get latitude => _currentPosition?.latitude;
  double? get longitude => _currentPosition?.longitude;

  Future<void> getCurrentLocation() async {
    _setLoadingLocation(true);
    _setLocationError(null);

    try {
      final position = await locationService?.getCurrentLocation();
      _currentPosition = position;

      // Get address details
      if (position != null) {
        await _getAddressFromPosition(position);
      }

      notifyListeners();
    } catch (e) {
      _setLocationError('Failed to get location: $e');
    } finally {
      _setLoadingLocation(false);
    }
  }

  Future<void> _getAddressFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        _currentPlacemark = placemarks.first;
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
  }

  Future<FarmLocation?> createFarmLocationFromCurrent() async {
    if (_currentPosition == null) {
      await getCurrentLocation();
    }

    if (_currentPosition == null) return null;

    try {
      return FarmLocation(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        address: currentAddress,
        city: _currentPlacemark?.locality ?? '',
        state: _currentPlacemark?.administrativeArea ?? '',
        pincode: _currentPlacemark?.postalCode ?? '',
        country: _currentPlacemark?.country ?? 'India',
      );
    } catch (e) {
      _setLocationError('Failed to create farm location: $e');
      return null;
    }
  }

  Future<void> searchLocationByAddress(String address) async {
    _setLoadingLocation(true);
    _setLocationError(null);

    try {
      final locations = await locationService?.getCoordinatesFromAddress(
        address,
      );

      if (locations != null && locations.isNotEmpty) {
        final location = locations.first;
        _currentPosition = Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        await _getAddressFromPosition(_currentPosition!);
        notifyListeners();
      } else {
        _setLocationError('Address not found');
      }
    } catch (e) {
      _setLocationError('Failed to search location: $e');
    } finally {
      _setLoadingLocation(false);
    }
  }

  Future<void> findNearbyFarms(
    List<FarmLocation> allFarms, {
    double radiusKm = 10.0,
  }) async {
    if (_currentPosition == null) return;

    _setLoadingLocation(true);

    try {
      _nearbyFarms = await locationService?.getNearbyLocations(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            radiusKm,
          ) ??
          [];
      notifyListeners();
    } catch (e) {
      _setLocationError('Failed to find nearby farms: $e');
    } finally {
      _setLoadingLocation(false);
    }
  }

  double? getDistanceToFarm(FarmLocation farm) {
    if (_currentPosition == null) return null;

    return locationService?.calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          farm.latitude,
          farm.longitude,
        ) ??
        0.0;
  }

  Future<bool> checkLocationPermissions() async {
    try {
      return await locationService?.requestLocationPermission() ?? false;
    } catch (e) {
      _setLocationError('Permission check failed: $e');
      return false;
    }
  }

  Future<bool> requestLocationPermissions() async {
    try {
      return await locationService?.requestLocationPermission() ?? false;
    } catch (e) {
      _setLocationError('Permission request failed: $e');
      return false;
    }
  }

  void updatePosition(double latitude, double longitude) {
    _currentPosition = Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );

    _getAddressFromPosition(_currentPosition!);
    notifyListeners();
  }

  void clearLocation() {
    _currentPosition = null;
    _currentPlacemark = null;
    _nearbyFarms.clear();
    _locationError = null;
    notifyListeners();
  }

  void _setLoadingLocation(bool loading) {
    _isLoadingLocation = loading;
    notifyListeners();
  }

  void _setLocationError(String? error) {
    _locationError = error;
    notifyListeners();
  }

  void clearLocationError() {
    _locationError = null;
    notifyListeners();
  }

  // Utility methods
  String formatCoordinates() {
    if (_currentPosition == null) return 'No location';
    return '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}';
  }

  bool isLocationWithinRadius(FarmLocation farm, double radiusKm) {
    if (_currentPosition == null) return false;

    final distance = getDistanceToFarm(farm);
    return distance != null && distance <= radiusKm;
  }

  Map<String, dynamic> getCurrentLocationData() {
    return {
      'position': _currentPosition != null
          ? {
              'latitude': _currentPosition!.latitude,
              'longitude': _currentPosition!.longitude,
              'accuracy': _currentPosition!.accuracy,
              'timestamp': _currentPosition!.timestamp.toIso8601String(),
            }
          : null,
      'address': currentAddress,
      'placemark': _currentPlacemark != null
          ? {
              'name': _currentPlacemark!.name,
              'locality': _currentPlacemark!.locality,
              'administrativeArea': _currentPlacemark!.administrativeArea,
              'country': _currentPlacemark!.country,
              'postalCode': _currentPlacemark!.postalCode,
            }
          : null,
    };
  }
}
