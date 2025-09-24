import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:farmpact/models/farmer_model.dart';

class LocationService {
  static final LocationService instance = LocationService._internal();

  LocationService._internal();

  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  Future<FarmLocation?> getCurrentFarmLocation() async {
    try {
      final position = await getCurrentLocation();
      if (position == null) return null;

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return FarmLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          address: '${placemark.street}, ${placemark.subLocality}',
          city: placemark.locality ?? '',
          state: placemark.administrativeArea ?? '',
          pincode: placemark.postalCode ?? '',
          country: placemark.country ?? 'India',
        );
      }

      return FarmLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address:
            'Location coordinates: ${position.latitude}, ${position.longitude}',
        city: '',
        state: '',
        pincode: '',
        country: 'India',
      );
    } catch (e) {
      print('Error getting farm location: $e');
      return null;
    }
  }

  Future<FarmLocation?> getLocationFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return FarmLocation(
          latitude: latitude,
          longitude: longitude,
          address: '${placemark.street}, ${placemark.subLocality}',
          city: placemark.locality ?? '',
          state: placemark.administrativeArea ?? '',
          pincode: placemark.postalCode ?? '',
          country: placemark.country ?? 'India',
        );
      }

      return FarmLocation(
        latitude: latitude,
        longitude: longitude,
        address: 'Coordinates: $latitude, $longitude',
        city: '',
        state: '',
        pincode: '',
        country: 'India',
      );
    } catch (e) {
      print('Error getting location from coordinates: $e');
      return null;
    }
  }

  Future<List<Location>?> getCoordinatesFromAddress(String address) async {
    try {
      return await locationFromAddress(address);
    } catch (e) {
      print('Error getting coordinates from address: $e');
      return null;
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  String getDistanceString(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  Future<bool> isLocationWithinRadius(
    double centerLat,
    double centerLon,
    double targetLat,
    double targetLon,
    double radiusInMeters,
  ) async {
    final distance = calculateDistance(
      centerLat,
      centerLon,
      targetLat,
      targetLon,
    );
    return distance <= radiusInMeters;
  }

  // Get nearby farms or agricultural resources
  Future<List<FarmLocation>> getNearbyLocations(
    double latitude,
    double longitude,
    double radiusInKm,
  ) async {
    // This would typically connect to a backend service
    // For now, return sample data
    return [
      FarmLocation(
        latitude: latitude + 0.01,
        longitude: longitude + 0.01,
        address: 'Sample Farm 1',
        city: 'Sample City',
        state: 'Sample State',
        pincode: '123456',
        country: 'India',
      ),
      FarmLocation(
        latitude: latitude - 0.01,
        longitude: longitude - 0.01,
        address: 'Sample Farm 2',
        city: 'Sample City',
        state: 'Sample State',
        pincode: '123456',
        country: 'India',
      ),
    ];
  }
}
