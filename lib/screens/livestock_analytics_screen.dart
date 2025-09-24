import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:farmpact/providers/livestock_provider.dart';
import 'package:farmpact/providers/farmer_provider.dart';
import 'package:farmpact/models/livestock_model.dart';
import 'package:image_picker/image_picker.dart';

class LivestockAnalyticsScreen extends StatefulWidget {
  const LivestockAnalyticsScreen({super.key});

  @override
  State<LivestockAnalyticsScreen> createState() =>
      _LivestockAnalyticsScreenState();
}

class _LivestockAnalyticsScreenState extends State<LivestockAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '7'; // 7, 30, 90 days
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _uploadedVideos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final livestockProvider =
        Provider.of<LivestockProvider>(context, listen: false);
    final farmerProvider = Provider.of<FarmerProvider>(context, listen: false);

    if (farmerProvider.currentFarmer != null) {
      await livestockProvider.loadLivestockData(
          farmerId: farmerProvider.currentFarmer!.id);
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livestock Analytics'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.pets), text: 'Pig Analytics'),
            Tab(icon: Icon(Icons.egg), text: 'Chicken Analytics'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range),
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7', child: Text('Last 7 days')),
              const PopupMenuItem(value: '30', child: Text('Last 30 days')),
              const PopupMenuItem(value: '90', child: Text('Last 90 days')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPigAnalytics(),
                _buildChickenAnalytics(),
              ],
            ),
    );
  }

  Widget _buildPigAnalytics() {
    return Consumer<LivestockProvider>(
      builder: (context, provider, child) {
        final pigData = provider.getDataByType('pig');
        final filteredData = _filterDataByPeriod(pigData);

        if (filteredData.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No pig farm data available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  'Start recording daily data to see analytics',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKPICards(filteredData, 'pig'),
              const SizedBox(height: 24),
              _buildPopulationChart(
                  filteredData, 'Pig Population Trend', Colors.green),
              const SizedBox(height: 24),
              _buildMortalityChart(
                  filteredData, 'Pig Mortality Rate', Colors.red),
              const SizedBox(height: 24),
              _buildVideoUploadSection('pig'),
              const SizedBox(height: 24),
              _buildFeedConsumptionChart(
                  filteredData, 'Feed Consumption (kg)', Colors.blue),
              const SizedBox(height: 24),
              _buildWeightProgressChart(
                  filteredData, 'Average Weight Progress', Colors.orange),
              const SizedBox(height: 24),
              _buildHealthStatusDistribution(
                  filteredData, 'Health Status Distribution'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChickenAnalytics() {
    return Consumer<LivestockProvider>(
      builder: (context, provider, child) {
        final chickenData = provider.getDataByType('chicken');
        final filteredData = _filterDataByPeriod(chickenData);

        if (filteredData.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No chicken farm data available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  'Start recording daily data to see analytics',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKPICards(filteredData, 'chicken'),
              const SizedBox(height: 24),
              _buildPopulationChart(
                  filteredData, 'Chicken Population Trend', Colors.orange),
              const SizedBox(height: 24),
              _buildEggProductionChart(filteredData),
              const SizedBox(height: 24),
              _buildMortalityChart(
                  filteredData, 'Chicken Mortality Rate', Colors.red),
              const SizedBox(height: 24),
              _buildVideoUploadSection('chicken'),
              const SizedBox(height: 24),
              _buildFeedConsumptionChart(
                  filteredData, 'Feed Consumption (kg)', Colors.blue),
              const SizedBox(height: 24),
              _buildHealthStatusDistribution(
                  filteredData, 'Health Status Distribution'),
            ],
          ),
        );
      },
    );
  }

  List<LivestockData> _filterDataByPeriod(List<LivestockData> data) {
    final days = int.parse(_selectedPeriod);
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return data.where((item) => item.date.isAfter(cutoffDate)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Widget _buildKPICards(List<LivestockData> data, String type) {
    if (data.isEmpty) return const SizedBox.shrink();

    final latest = data.last;
    final totalAnimals = latest.totalAnimals;
    final avgMortality =
        data.map((e) => e.mortalityRate).reduce((a, b) => a + b) / data.length;
    final totalEggs = type == 'chicken'
        ? data.map((e) => e.eggsCollected).fold(0, (a, b) => a + b)
        : 0;
    final avgWeight =
        data.map((e) => e.averageWeight).reduce((a, b) => a + b) / data.length;

    return Row(
      children: [
        Expanded(
          child: _buildKPICard(
            'Total Animals',
            totalAnimals.toString(),
            Icons.pets,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKPICard(
            'Avg Mortality',
            '${avgMortality.toStringAsFixed(1)}%',
            Icons.report_problem,
            Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        if (type == 'chicken')
          Expanded(
            child: _buildKPICard(
              'Total Eggs',
              totalEggs.toString(),
              Icons.egg,
              Colors.orange,
            ),
          )
        else
          Expanded(
            child: _buildKPICard(
              'Avg Weight',
              '${avgWeight.toStringAsFixed(1)} kg',
              Icons.monitor_weight,
              Colors.blue,
            ),
          ),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopulationChart(
      List<LivestockData> data, String title, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            final date = data[index].date;
                            return Text('${date.month}/${date.day}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(),
                            entry.value.totalAnimals.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMortalityChart(
      List<LivestockData> data, String title, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            final date = data[index].date;
                            return Text('${date.month}/${date.day}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(
                            entry.key.toDouble(), entry.value.mortalityRate);
                      }).toList(),
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEggProductionChart(List<LivestockData> data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Egg Production',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            final date = data[index].date;
                            return Text('${date.month}/${date.day}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: data.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.eggsCollected.toDouble(),
                          color: Colors.orange,
                          width: 16,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedConsumptionChart(
      List<LivestockData> data, String title, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            final date = data[index].date;
                            return Text('${date.month}/${date.day}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: data.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.feedConsumption,
                          color: color,
                          width: 16,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightProgressChart(
      List<LivestockData> data, String title, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            final date = data[index].date;
                            return Text('${date.month}/${date.day}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(
                            entry.key.toDouble(), entry.value.averageWeight);
                      }).toList(),
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStatusDistribution(
      List<LivestockData> data, String title) {
    final distribution = <String, int>{};
    for (final item in data) {
      distribution[item.healthStatus] =
          (distribution[item.healthStatus] ?? 0) + 1;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...distribution.entries.map((entry) {
              final percentage =
                  (entry.value / data.length * 100).toStringAsFixed(1);
              Color color;
              switch (entry.key) {
                case 'good':
                  color = Colors.green;
                  break;
                case 'fair':
                  color = Colors.orange;
                  break;
                case 'poor':
                  color = Colors.red;
                  break;
                default:
                  color = Colors.grey;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                        '${entry.key.toUpperCase()}: ${entry.value} days ($percentage%)'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoUploadSection(String animalType) {
    final typeVideos = _uploadedVideos
        .where((video) =>
            video.name.toLowerCase().contains(animalType.toLowerCase()))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.video_camera_back,
                  color: animalType == 'pig' ? Colors.pink : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Upload ${animalType.toUpperCase()} Videos',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Record videos to document ${animalType} health, behavior, feeding patterns, or any concerns.',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _recordVideo(animalType),
                    icon: const Icon(Icons.videocam),
                    label: const Text('Record Video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          animalType == 'pig' ? Colors.pink : Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _selectVideoFromGallery(animalType),
                    icon: const Icon(Icons.video_library),
                    label: const Text('From Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (typeVideos.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Recent ${animalType.toUpperCase()} Videos:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: typeVideos.length,
                  itemBuilder: (context, index) {
                    final video = typeVideos[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_circle_filled,
                                  size: 32,
                                  color: animalType == 'pig'
                                      ? Colors.pink
                                      : Colors.orange,
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    video.name.length > 15
                                        ? '${video.name.substring(0, 12)}...'
                                        : video.name,
                                    style: const TextStyle(fontSize: 10),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => _removeVideo(video),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
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

  Future<void> _recordVideo(String animalType) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        // Add animal type to the file name for categorization
        final modifiedVideo = XFile(
          video.path,
          name: '${animalType}_${DateTime.now().millisecondsSinceEpoch}.mp4',
        );

        setState(() {
          _uploadedVideos.insert(0, modifiedVideo);
          // Keep only the last 20 videos
          if (_uploadedVideos.length > 20) {
            _uploadedVideos = _uploadedVideos.take(20).toList();
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${animalType.toUpperCase()} video recorded successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
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

  Future<void> _selectVideoFromGallery(String animalType) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video != null) {
        // Add animal type to the file name for categorization
        final modifiedVideo = XFile(
          video.path,
          name: '${animalType}_${DateTime.now().millisecondsSinceEpoch}.mp4',
        );

        setState(() {
          _uploadedVideos.insert(0, modifiedVideo);
          // Keep only the last 20 videos
          if (_uploadedVideos.length > 20) {
            _uploadedVideos = _uploadedVideos.take(20).toList();
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${animalType.toUpperCase()} video selected successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting video: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeVideo(XFile video) {
    setState(() {
      _uploadedVideos.remove(video);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video removed'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
