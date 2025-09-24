import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:farmpact/providers/location_provider.dart';
import 'package:farmpact/providers/notification_provider.dart';
import 'package:farmpact/providers/livestock_provider.dart';
import 'package:farmpact/models/alert_model.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  LatLng? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      final livestockProvider =
          Provider.of<LivestockProvider>(context, listen: false);

      // Get current location
      await locationProvider.getCurrentLocation();

      if (locationProvider.currentPosition != null) {
        _currentPosition = LatLng(
          locationProvider.currentPosition!.latitude,
          locationProvider.currentPosition!.longitude,
        );
      }

      // Load alerts and create markers
      await _loadAlertMarkers(notificationProvider, livestockProvider);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing map: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAlertMarkers(NotificationProvider notificationProvider,
      LivestockProvider livestockProvider) async {
    _markers.clear();
    _circles.clear();

    // Add current location marker
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Current farm location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Add farm boundaries circle
    if (_currentPosition != null) {
      _circles.add(
        Circle(
          circleId: const CircleId('farm_boundary'),
          center: _currentPosition!,
          radius: 500, // 500 meters radius
          fillColor: Colors.green.withOpacity(0.2),
          strokeColor: Colors.green,
          strokeWidth: 2,
        ),
      );
    }

    // Add alert markers
    final alerts = notificationProvider.alerts;
    for (int i = 0; i < alerts.length; i++) {
      final alert = alerts[i];
      Color markerColor;

      switch (alert.severity) {
        case AlertSeverity.low:
          markerColor = Colors.yellow;
          break;
        case AlertSeverity.medium:
          markerColor = Colors.orange;
          break;
        case AlertSeverity.high:
          markerColor = Colors.red;
          break;
        case AlertSeverity.critical:
          markerColor = Colors.purple;
          break;
      }

      // Create random positions around current location for demo
      final position = _getRandomPosition(_currentPosition!, 1000);

      _markers.add(
        Marker(
          markerId: MarkerId('alert_$i'),
          position: position,
          infoWindow: InfoWindow(
            title: alert.title,
            snippet: alert.message,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              _getHueFromColor(markerColor)),
          onTap: () => _showAlertDetails(alert),
        ),
      );

      // Add risk circle around alert
      _circles.add(
        Circle(
          circleId: CircleId('alert_circle_$i'),
          center: position,
          radius: _getAlertRadius(alert.severity),
          fillColor: markerColor.withOpacity(0.3),
          strokeColor: markerColor,
          strokeWidth: 2,
        ),
      );
    }

    // Add livestock farm markers
    final farmerProvider =
        Provider.of<LocationProvider>(context, listen: false);
    if (farmerProvider.currentPosition != null) {
      // Add pig farm marker
      final pigPosition = _getRandomPosition(_currentPosition!, 300);
      _markers.add(
        Marker(
          markerId: const MarkerId('pig_farm'),
          position: pigPosition,
          infoWindow: const InfoWindow(
            title: 'Pig Farm',
            snippet: 'Livestock farming area',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
      );

      // Add chicken farm marker
      final chickenPosition = _getRandomPosition(_currentPosition!, 400);
      _markers.add(
        Marker(
          markerId: const MarkerId('chicken_farm'),
          position: chickenPosition,
          infoWindow: const InfoWindow(
            title: 'Chicken Farm',
            snippet: 'Poultry farming area',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    }
  }

  LatLng _getRandomPosition(LatLng center, double radiusInMeters) {
    final random = DateTime.now().millisecondsSinceEpoch;
    final distance =
        (random % radiusInMeters.toInt()) / 111320; // Convert meters to degrees

    final lat = center.latitude + (distance * (random % 2 == 0 ? 1 : -1));
    final lng = center.longitude + (distance * (random % 2 == 0 ? 1 : -1));

    return LatLng(lat, lng);
  }

  double _getHueFromColor(Color color) {
    if (color == Colors.yellow) return BitmapDescriptor.hueYellow;
    if (color == Colors.orange) return BitmapDescriptor.hueOrange;
    if (color == Colors.red) return BitmapDescriptor.hueRed;
    if (color == Colors.purple) return BitmapDescriptor.hueViolet;
    return BitmapDescriptor.hueRed;
  }

  double _getAlertRadius(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return 100;
      case AlertSeverity.medium:
        return 200;
      case AlertSeverity.high:
        return 300;
      case AlertSeverity.critical:
        return 500;
    }
  }

  void _showAlertDetails(alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    _getAlertIcon(alert.type),
                    color: _getSeverityColor(alert.severity),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSeverityColor(alert.severity).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  alert.severity.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    color: _getSeverityColor(alert.severity),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                alert.message,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Alert time: ${alert.timestamp.day}/${alert.timestamp.month}/${alert.timestamp.year} ${alert.timestamp.hour}:${alert.timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Valid until: ${alert.validUntil.day}/${alert.validUntil.month}/${alert.validUntil.year}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Handle alert action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Take Action'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.weather:
        return Icons.cloud;
      case AlertType.disease:
        return Icons.health_and_safety;
      case AlertType.market:
        return Icons.trending_up;
      case AlertType.emergency:
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return Colors.yellow[700]!;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.red;
      case AlertSeverity.critical:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Map View'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: () => _showMapOptions(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _initializeMap(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentPosition == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Unable to get location',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please enable location services',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 15.0,
                  ),
                  markers: _markers,
                  circles: _circles,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.hybrid,
                  onTap: (LatLng position) {
                    // Handle map tap
                  },
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "legend",
            mini: true,
            onPressed: () => _showLegend(),
            backgroundColor: Colors.white,
            child: const Icon(Icons.info, color: Colors.green),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "center",
            mini: true,
            onPressed: () => _centerOnLocation(),
            backgroundColor: Colors.green,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showMapOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Normal Map'),
              onTap: () {
                _controller?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: _currentPosition!,
                      zoom: 15.0,
                    ),
                  ),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.satellite),
              title: const Text('Satellite View'),
              onTap: () {
                _controller?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: _currentPosition!,
                      zoom: 15.0,
                    ),
                  ),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.terrain),
              title: const Text('Terrain View'),
              onTap: () {
                _controller?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: _currentPosition!,
                      zoom: 15.0,
                    ),
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLegend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Map Legend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLegendItem(Colors.blue, 'Your Location'),
            _buildLegendItem(Colors.green, 'Farm Boundary'),
            _buildLegendItem(Colors.yellow, 'Low Priority Alert'),
            _buildLegendItem(Colors.orange, 'Medium Priority Alert'),
            _buildLegendItem(Colors.red, 'High Priority Alert'),
            _buildLegendItem(Colors.purple, 'Critical Alert'),
            _buildLegendItem(Colors.deepPurple, 'Pig Farm'),
            _buildLegendItem(Colors.deepOrange, 'Chicken Farm'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  void _centerOnLocation() {
    if (_currentPosition != null && _controller != null) {
      _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 15.0),
      );
    }
  }
}
