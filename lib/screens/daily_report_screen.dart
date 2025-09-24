import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:farmpact/providers/farmer_provider.dart';
import 'package:farmpact/services/database_service.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  // Report data
  DateTime _selectedDate = DateTime.now();
  String _weatherCondition = 'sunny';
  double _temperature = 25.0;
  String _generalNotes = '';

  // Livestock data
  final Map<String, Map<String, dynamic>> _livestockData = {
    'pigs': {
      'healthy': 0,
      'sick': 0,
      'feed_consumption': 0.0,
      'mortality': 0,
      'production': 0.0,
      'notes': '',
    },
    'chickens': {
      'healthy': 0,
      'sick': 0,
      'feed_consumption': 0.0,
      'mortality': 0,
      'egg_production': 0,
      'notes': '',
    },
  };

  // Crop data
  String _cropActivity = '';
  String _cropNotes = '';
  List<String> _activities = [
    'Watering',
    'Fertilizing',
    'Pest Control',
    'Harvesting',
    'Planting',
    'Weeding',
    'Soil Preparation',
    'Other'
  ];

  final List<String> _weatherOptions = [
    'sunny',
    'cloudy',
    'rainy',
    'stormy',
    'foggy'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Report'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitReport,
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  for (int i = 0; i < 4; i++)
                    Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                        decoration: BoxDecoration(
                          color: i <= _currentPage
                              ? Colors.green
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildGeneralInfoPage(),
                  _buildLivestockPage(),
                  _buildCropPage(),
                  _buildSummaryPage(),
                ],
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    ElevatedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                      ),
                      child: const Text('Previous'),
                    )
                  else
                    const SizedBox.shrink(),
                  if (_currentPage < 3)
                    ElevatedButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Next'),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'General Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
          ),
          const SizedBox(height: 24),

          // Date picker
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.green),
              title: const Text('Report Date'),
              subtitle: Text(DateFormat('MMMM dd, yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
          ),

          const SizedBox(height: 16),

          // Weather condition
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.wb_sunny, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Weather Condition',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _weatherOptions.map((weather) {
                      return ChoiceChip(
                        label: Text(_capitalizeFirst(weather)),
                        selected: _weatherCondition == weather,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _weatherCondition = weather);
                          }
                        },
                        selectedColor: Colors.green.withOpacity(0.3),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Temperature
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.thermostat, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Temperature (°C)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _temperature,
                    min: 0,
                    max: 50,
                    divisions: 50,
                    label: '${_temperature.round()}°C',
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() => _temperature = value);
                    },
                  ),
                  Text(
                    '${_temperature.round()}°C',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // General notes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.notes, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'General Notes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Any general observations or notes for today...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _generalNotes = value,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivestockPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Livestock Report',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
          ),
          const SizedBox(height: 24),

          // Pigs section
          _buildLivestockSection(
            'Pigs',
            Icons.pets,
            Colors.pink,
            'pigs',
            hasProduction: true,
            productionLabel: 'Weight Gain (kg)',
          ),

          const SizedBox(height: 24),

          // Chickens section
          _buildLivestockSection(
            'Chickens',
            Icons.egg,
            Colors.orange,
            'chickens',
            hasProduction: true,
            productionLabel: 'Egg Production',
          ),
        ],
      ),
    );
  }

  Widget _buildLivestockSection(
      String title, IconData icon, Color color, String key,
      {bool hasProduction = false, String productionLabel = ''}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Healthy count
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Healthy Animals',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.favorite, color: Colors.green),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _livestockData[key]!['healthy'] =
                          int.tryParse(value) ?? 0;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Sick Animals',
                      border: OutlineInputBorder(),
                      prefixIcon:
                          Icon(Icons.medical_services, color: Colors.red),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _livestockData[key]!['sick'] = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Feed consumption and mortality
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Feed Consumed (kg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.grass, color: Colors.brown),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _livestockData[key]!['feed_consumption'] =
                          double.tryParse(value) ?? 0.0;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Mortality',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.warning, color: Colors.red),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _livestockData[key]!['mortality'] =
                          int.tryParse(value) ?? 0;
                    },
                  ),
                ),
              ],
            ),

            if (hasProduction) ...[
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: productionLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.trending_up, color: color),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (key == 'pigs') {
                    _livestockData[key]!['production'] =
                        double.tryParse(value) ?? 0.0;
                  } else {
                    _livestockData[key]!['egg_production'] =
                        int.tryParse(value) ?? 0;
                  }
                },
              ),
            ],

            const SizedBox(height: 16),

            // Notes
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              onChanged: (value) {
                _livestockData[key]!['notes'] = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crop Activities',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.agriculture, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Today\'s Activities',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Activity selection
                  const Text(
                    'Select activities performed today:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    children: _activities.map((activity) {
                      final isSelected = _cropActivity.contains(activity);
                      return FilterChip(
                        label: Text(activity),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              if (_cropActivity.isEmpty) {
                                _cropActivity = activity;
                              } else {
                                _cropActivity += ', $activity';
                              }
                            } else {
                              _cropActivity = _cropActivity
                                  .split(', ')
                                  .where((a) => a != activity)
                                  .join(', ');
                            }
                          });
                        },
                        selectedColor: Colors.green.withOpacity(0.3),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Crop notes
                  const Text(
                    'Activity Details & Notes:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText:
                          'Describe the activities performed, areas covered, quantities used, observations, etc.',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _cropNotes = value,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Summary',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
          ),
          const SizedBox(height: 24),

          // Date and weather summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'General Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                      'Date: ${DateFormat('MMMM dd, yyyy').format(_selectedDate)}'),
                  Text('Weather: ${_capitalizeFirst(_weatherCondition)}'),
                  Text('Temperature: ${_temperature.round()}°C'),
                  if (_generalNotes.isNotEmpty) Text('Notes: $_generalNotes'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Livestock summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Livestock Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...['pigs', 'chickens'].map((type) {
                    final data = _livestockData[type]!;
                    final total =
                        (data['healthy'] as int) + (data['sick'] as int);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${_capitalizeFirst(type)}: $total total (${data['healthy']} healthy, ${data['sick']} sick)',
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Crop activity summary
          if (_cropActivity.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Crop Activities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Activities: $_cropActivity'),
                    if (_cropNotes.isNotEmpty) Text('Details: $_cropNotes'),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Submit Daily Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final farmerProvider =
          Provider.of<FarmerProvider>(context, listen: false);
      final farmer = farmerProvider.currentFarmer;

      if (farmer == null) {
        throw Exception('No farmer data found');
      }

      // Prepare report data
      final reportData = {
        'farmer_id': farmer.id,
        'date': _selectedDate.toIso8601String(),
        'weather': _weatherCondition,
        'temperature': _temperature,
        'general_notes': _generalNotes,
        'livestock_data': _livestockData,
        'crop_activity': _cropActivity,
        'crop_notes': _cropNotes,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Save to database
      final databaseService = DatabaseService.instance;
      await databaseService.insertDailyReport(reportData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily report submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
