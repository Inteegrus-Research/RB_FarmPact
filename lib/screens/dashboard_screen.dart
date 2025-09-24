import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:farmpact/themes/theme.dart';
import 'package:farmpact/widgets/custom_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;

  // Sample data - replace with actual Firebase data
  final double _riskScore = 65.0;
  final String _weatherCondition = 'cloudy';
  final String _weatherAdvice =
      'High humidity expected. Ensure proper ventilation for your livestock. Consider reducing feed portions today.';
  final List<FlSpot> _mortalityData = [
    const FlSpot(0, 3),
    const FlSpot(5, 1),
    const FlSpot(10, 4),
    const FlSpot(15, 2),
    const FlSpot(20, 1),
    const FlSpot(25, 0),
    const FlSpot(30, 2),
  ];

  final List<Map<String, String>> _learningResources = [
    {'title': 'Disease Prevention Tips', 'type': 'video'},
    {'title': 'Optimal Feeding Practices', 'type': 'article'},
    {'title': 'Weather Advisory Guide', 'type': 'video'},
    {'title': 'Emergency Response', 'type': 'article'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Farm Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              // Navigate to profile
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Risk Score Gauge (Hero Element)
              _buildRiskScoreSection(),

              const SizedBox(height: 24.0),

              // Weather Advisory Card
              _buildWeatherAdvisoryCard(),

              const SizedBox(height: 24.0),

              // Health Trends Card
              _buildHealthTrendsCard(),

              const SizedBox(height: 24.0),

              // Upload Video Section
              _buildUploadSection(),

              const SizedBox(height: 24.0),

              // Learning Resources Section
              _buildLearningResourcesSection(),

              const SizedBox(height: 24.0),

              // Contact Veterinarian Section (NEW)
              _buildContactVetSection(),

              const SizedBox(height: 6.0),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Quick report functionality
        },
        label: const Text('Quick Report'),
        icon: const Icon(Icons.add_alert),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildRiskScoreSection() {
    if (_isLoading) {
      return const LoadingCard(height: 300);
    }

    return CustomCard(
      child: Column(
        children: [
          Text(
            'Current Risk Assessment',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),

          // Risk Score Gauge
          SizedBox(
            height: 250,
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  showLabels: false,
                  showTicks: false,
                  radiusFactor: 0.8,
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.15,
                    cornerStyle: CornerStyle.bothCurve,
                    color: Colors.grey[300],
                    thicknessUnit: GaugeSizeUnit.factor,
                  ),
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: _riskScore,
                      width: 0.15,
                      sizeUnit: GaugeSizeUnit.factor,
                      color: AppTheme.getRiskColorByScore(_riskScore),
                      cornerStyle: CornerStyle.bothCurve,
                    ),
                    NeedlePointer(
                      value: _riskScore,
                      enableDragging: false,
                      needleColor: AppTheme.primaryTextColor,
                      needleStartWidth: 1,
                      needleEndWidth: 4,
                      needleLength: 0.7,
                      knobStyle: const KnobStyle(
                        knobRadius: 0.05,
                        color: AppTheme.primaryTextColor,
                      ),
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: RiskScoreDisplay(
                        score: _riskScore,
                        riskLevel: AppTheme.getRiskLevelText(_riskScore),
                      ),
                      angle: 90,
                      positionFactor: 0.1,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16.0),

          // Risk level indicator
          StatusBadge(
            text: AppTheme.getRiskLevelText(_riskScore),
            backgroundColor: AppTheme.getRiskColorByScore(_riskScore),
          ),

          const SizedBox(height: 8.0),

          Text(
            'Based on current weather, livestock health, and environmental factors',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherAdvisoryCard() {
    if (_isLoading) {
      return const LoadingCard(height: 120);
    }

    return CustomCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weather icon
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: WeatherIcon(weatherCondition: _weatherCondition, size: 40.0),
          ),

          const SizedBox(width: 16.0),

          // Weather info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Weather',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      'Updated 1h ago',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  _weatherAdvice,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTrendsCard() {
    if (_isLoading) {
      return const LoadingCard(height: 200);
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mortality Trend (Last 30 Days)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Icon(
                Icons.trending_down,
                color: AppTheme.lowRisk,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 16.0),

          // Line chart
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 1,
                      dashArray: [3, 3],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 10,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            '${value.toInt()}d',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            value.toInt().toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    left: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                minX: 0,
                maxX: 30,
                minY: 0,
                maxY: 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: _mortalityData,
                    isCurved: true,
                    color: AppTheme.primaryGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.primaryGreen,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload a Video for Analysis',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16.0),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[400]!,
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 40,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Tap to upload a video',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12.0),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement video upload functionality
                  },
                  icon: const Icon(Icons.video_library_outlined),
                  label: const Text('Upload from Device'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningResourcesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recommended for You',
          trailing: TextButton(
            onPressed: () {
              // Navigate to all resources
            },
            child: const Text('View All'),
          ),
        ),
        const SizedBox(height: 8.0),
        if (_isLoading)
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12.0),
                  child: const LoadingCard(height: 160),
                );
              },
            ),
          )
        else
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _learningResources.length,
              itemBuilder: (context, index) {
                final resource = _learningResources[index];
                return LearningResourceCard(
                  title: resource['title']!,
                  onTap: () {
                    // Navigate to resource detail
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  /// Newly Added Section
  Widget _buildContactVetSection() {
    return CustomCard(
      child: Row(
        children: [
          Icon(
            Icons.local_hospital_outlined,
            size: 70,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Expert Help?',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Connect with a certified veterinarian for a consultation.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12.0),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement navigation to contact a vet
                  },
                  child: const Text('Schedule a Call'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
