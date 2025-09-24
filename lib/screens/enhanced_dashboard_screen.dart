import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmpact/providers/farmer_provider.dart';
import 'package:farmpact/providers/location_provider.dart';
import 'package:farmpact/providers/notification_provider.dart';
import 'package:farmpact/screens/simple_map_screen.dart';
import 'package:farmpact/screens/livestock_data_entry_screen.dart';
import 'package:farmpact/screens/livestock_analytics_screen.dart';
import 'package:farmpact/screens/profile_screen.dart';
import 'package:farmpact/screens/daily_report_screen.dart';
import 'package:farmpact/screens/veterinarian_contact_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _uploadedMedia = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Initialize providers
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    await Future.wait([
      locationProvider.getCurrentLocation(),
      notificationProvider.initialize(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Consumer<FarmerProvider>(
          builder: (context, farmerProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.agriculture,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'FarmPact',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Welcome, ${farmerProvider.currentFarmer?.name ?? 'Farmer'}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            );
          },
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      _showAlertsBottomSheet(context, notificationProvider);
                    },
                  ),
                  if (notificationProvider.urgentCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${notificationProvider.urgentCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.map, color: Colors.white),
            onPressed: () {
              _showMapView(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationCard(),
              const SizedBox(height: 16),
              _buildMediaUploadCard(),
              const SizedBox(height: 16),
              _buildQuickStats(),
              const SizedBox(height: 16),
              _buildWeatherCard(),
              const SizedBox(height: 16),
              _buildRecentAlerts(),
              const SizedBox(height: 16),
              _buildMortalityTrendCard(), // <<< NEW CARD ADDED HERE
              const SizedBox(height: 16),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  // New Card for Mortality Trend
  Widget _buildMortalityTrendCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_down, color: Colors.red.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Mortality Trend',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Monitor and report livestock mortality. Upload a video for documentation or veterinary consultation.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _pickVideo, // Reuses the existing video picking logic
                icon: const Icon(Icons.videocam_outlined),
                label: const Text('Upload Video of Issue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    const Text(
                      'Current Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (locationProvider.hasLocation) ...[
                  Text(
                    locationProvider.currentAddress,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Coordinates: ${locationProvider.formatCoordinates()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Location not available',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: locationProvider.isLoadingLocation
                        ? null
                        : () => locationProvider.getCurrentLocation(),
                    icon: locationProvider.isLoadingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(locationProvider.isLoadingLocation
                        ? 'Getting Location...'
                        : 'Get Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Consumer<FarmerProvider>(
      builder: (context, farmerProvider, child) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Area',
                value:
                    '${farmerProvider.totalFarmArea.toStringAsFixed(1)} acres',
                icon: Icons.landscape,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Crops',
                value: '${farmerProvider.totalCrops}',
                icon: Icons.agriculture,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Livestock',
                value: '${farmerProvider.totalLivestock}',
                icon: Icons.pets,
                color: Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Weather Conditions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '28°C',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade600,
                        ),
                      ),
                      const Text(
                        'Partly Cloudy',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Humidity: 65% | Wind: 12 km/h',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Icon(Icons.cloud, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Good for farming',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAlerts() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final recentAlerts = notificationProvider.alerts.take(3).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications_active,
                            color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        const Text(
                          'Recent Alerts',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () =>
                          _showAlertsBottomSheet(context, notificationProvider),
                      child: Text(
                        'View All',
                        style: TextStyle(color: Colors.green.shade600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (recentAlerts.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: Text(
                        'No recent alerts',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...recentAlerts.map((alert) => _buildAlertItem(alert)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertItem(alert) {
    IconData icon;
    Color color;

    switch (alert.type.toString().split('.').last) {
      case 'weather':
        icon = Icons.wb_sunny;
        color = Colors.orange;
        break;
      case 'disease':
        icon = Icons.bug_report;
        color = Colors.red;
        break;
      case 'market':
        icon = Icons.trending_up;
        color = Colors.green;
        break;
      default:
        icon = Icons.info;
        color = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  alert.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.2,
              children: [
                _buildQuickActionButton(
                  title: 'View Map',
                  icon: Icons.map,
                  color: Colors.blue,
                  onTap: () => _showMapView(context),
                ),
                _buildQuickActionButton(
                  title: 'Daily Data Entry',
                  icon: Icons.edit_note,
                  color: Colors.green,
                  onTap: () => _navigateToDataEntry(),
                ),
                _buildQuickActionButton(
                  title: 'Livestock Analytics',
                  icon: Icons.analytics,
                  color: Colors.purple,
                  onTap: () => _navigateToAnalytics(),
                ),
                _buildQuickActionButton(
                  title: 'Profile',
                  icon: Icons.person,
                  color: Colors.indigo,
                  onTap: () => _navigateToProfile(),
                ),
                _buildQuickActionButton(
                  title: 'Daily Report',
                  icon: Icons.assignment,
                  color: Colors.teal,
                  onTap: () => _navigateToDailyReport(),
                ),
                _buildQuickActionButton(
                  title: 'Vet Services',
                  icon: Icons.medical_services,
                  color: Colors.red,
                  onTap: () => _navigateToVetServices(),
                ),
                _buildQuickActionButton(
                  title: 'Weather',
                  icon: Icons.wb_sunny,
                  color: Colors.orange,
                  onTap: () => _showWeatherDetails(),
                ),
                _buildQuickActionButton(
                  title: 'Settings',
                  icon: Icons.settings,
                  color: Colors.grey,
                  onTap: () => _showSettingsDialog(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await _initializeData();
  }

  void _showAlertsBottomSheet(
      BuildContext context, NotificationProvider notificationProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Alerts & Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: notificationProvider.alerts.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No alerts available',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: notificationProvider.alerts.length,
                        itemBuilder: (context, index) {
                          final alert = notificationProvider.alerts[index];
                          return _buildAlertItem(alert);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMapView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SimpleMapScreen()),
    );
  }

  void _navigateToDataEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LivestockDataEntryScreen()),
    );
  }

  void _navigateToAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LivestockAnalyticsScreen()),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  void _navigateToDailyReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DailyReportScreen()),
    );
  }

  void _navigateToVetServices() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const VeterinarianContactScreen()),
    );
  }

  void _showWeatherDetails() {
    // Placeholder for weather details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Detailed weather view coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Settings functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaUploadCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Upload Farm Photos/Videos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Capture and share photos or videos of your farm activities, crops, livestock, or any issues you want to document.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('From Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _pickVideo(),
                icon: const Icon(Icons.videocam),
                label: const Text('Record Video'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            if (_uploadedMedia.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Recently Uploaded:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _uploadedMedia.length,
                  itemBuilder: (context, index) {
                    final media = _uploadedMedia[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(media.path),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    media.path.toLowerCase().contains('.mp4') ||
                                            media.path
                                                .toLowerCase()
                                                .contains('.mov')
                                        ? Icons.video_library
                                        : Icons.image,
                                    color: Colors.grey.shade600,
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => _removeMedia(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _uploadedMedia.insert(0, image);
          // Keep only the last 10 media files
          if (_uploadedMedia.length > 10) {
            _uploadedMedia = _uploadedMedia.take(10).toList();
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Photo ${source == ImageSource.camera ? "captured" : "selected"} successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        setState(() {
          _uploadedMedia.insert(0, video);
          // Keep only the last 10 media files
          if (_uploadedMedia.length > 10) {
            _uploadedMedia = _uploadedMedia.take(10).toList();
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video recorded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error recording video: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _uploadedMedia.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Media removed'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
