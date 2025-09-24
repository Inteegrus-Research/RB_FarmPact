import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmpact/providers/livestock_provider.dart';
import 'package:farmpact/providers/farmer_provider.dart';
import 'package:farmpact/models/livestock_model.dart';
import 'package:uuid/uuid.dart';

class LivestockDataEntryScreen extends StatefulWidget {
  const LivestockDataEntryScreen({super.key});

  @override
  State<LivestockDataEntryScreen> createState() =>
      _LivestockDataEntryScreenState();
}

class _LivestockDataEntryScreenState extends State<LivestockDataEntryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final Uuid _uuid = const Uuid();

  // Controllers for pig farm
  final _pigTotalAnimalsController = TextEditingController();
  final _pigNewBirthsController = TextEditingController();
  final _pigDeathsController = TextEditingController();
  final _pigFeedController = TextEditingController();
  final _pigWaterController = TextEditingController();
  final _pigWeightController = TextEditingController();
  final _pigNotesController = TextEditingController();
  final _pigTemperatureController = TextEditingController();
  final _pigHumidityController = TextEditingController();

  // Controllers for chicken farm
  final _chickenTotalAnimalsController = TextEditingController();
  final _chickenNewBirthsController = TextEditingController();
  final _chickenDeathsController = TextEditingController();
  final _chickenFeedController = TextEditingController();
  final _chickenWaterController = TextEditingController();
  final _chickenEggsController = TextEditingController();
  final _chickenWeightController = TextEditingController();
  final _chickenNotesController = TextEditingController();
  final _chickenTemperatureController = TextEditingController();
  final _chickenHumidityController = TextEditingController();

  String _pigHealthStatus = 'good';
  String _chickenHealthStatus = 'good';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTodayData();
  }

  void _loadTodayData() async {
    final livestockProvider =
        Provider.of<LivestockProvider>(context, listen: false);
    final farmerProvider = Provider.of<FarmerProvider>(context, listen: false);

    if (farmerProvider.currentFarmer != null) {
      // Load today's data for pig farm
      final pigData = livestockProvider.getTodayData(
          farmerProvider.currentFarmer!.id, 'pig');
      if (pigData != null) {
        _pigTotalAnimalsController.text = pigData.totalAnimals.toString();
        _pigNewBirthsController.text = pigData.newBirths.toString();
        _pigDeathsController.text = pigData.deaths.toString();
        _pigFeedController.text = pigData.feedConsumption.toString();
        _pigWaterController.text = pigData.waterConsumption.toString();
        _pigWeightController.text = pigData.averageWeight.toString();
        _pigNotesController.text = pigData.notes;
        _pigTemperatureController.text = pigData.temperature.toString();
        _pigHumidityController.text = pigData.humidity.toString();
        _pigHealthStatus = pigData.healthStatus;
      }

      // Load today's data for chicken farm
      final chickenData = livestockProvider.getTodayData(
          farmerProvider.currentFarmer!.id, 'chicken');
      if (chickenData != null) {
        _chickenTotalAnimalsController.text =
            chickenData.totalAnimals.toString();
        _chickenNewBirthsController.text = chickenData.newBirths.toString();
        _chickenDeathsController.text = chickenData.deaths.toString();
        _chickenFeedController.text = chickenData.feedConsumption.toString();
        _chickenWaterController.text = chickenData.waterConsumption.toString();
        _chickenEggsController.text = chickenData.eggsCollected.toString();
        _chickenWeightController.text = chickenData.averageWeight.toString();
        _chickenNotesController.text = chickenData.notes;
        _chickenTemperatureController.text = chickenData.temperature.toString();
        _chickenHumidityController.text = chickenData.humidity.toString();
        _chickenHealthStatus = chickenData.healthStatus;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Dispose pig controllers
    _pigTotalAnimalsController.dispose();
    _pigNewBirthsController.dispose();
    _pigDeathsController.dispose();
    _pigFeedController.dispose();
    _pigWaterController.dispose();
    _pigWeightController.dispose();
    _pigNotesController.dispose();
    _pigTemperatureController.dispose();
    _pigHumidityController.dispose();
    // Dispose chicken controllers
    _chickenTotalAnimalsController.dispose();
    _chickenNewBirthsController.dispose();
    _chickenDeathsController.dispose();
    _chickenFeedController.dispose();
    _chickenWaterController.dispose();
    _chickenEggsController.dispose();
    _chickenWeightController.dispose();
    _chickenNotesController.dispose();
    _chickenTemperatureController.dispose();
    _chickenHumidityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Livestock Data'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.pets), text: 'Pig Farm'),
            Tab(icon: Icon(Icons.egg), text: 'Chicken Farm'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showAnalytics(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPigFarmTab(),
          _buildChickenFarmTab(),
        ],
      ),
    );
  }

  Widget _buildPigFarmTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
                '🐷 Pig Farm - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
            const SizedBox(height: 16),
            _buildInputCard([
              _buildNumberField(
                controller: _pigTotalAnimalsController,
                label: 'Total Animals',
                icon: Icons.pets,
                required: true,
              ),
              _buildNumberField(
                controller: _pigNewBirthsController,
                label: 'New Births Today',
                icon: Icons.child_care,
              ),
              _buildNumberField(
                controller: _pigDeathsController,
                label: 'Deaths Today',
                icon: Icons.report_problem,
              ),
            ]),
            _buildInputCard([
              _buildNumberField(
                controller: _pigFeedController,
                label: 'Feed Consumption (kg)',
                icon: Icons.dining,
                decimal: true,
              ),
              _buildNumberField(
                controller: _pigWaterController,
                label: 'Water Consumption (L)',
                icon: Icons.water_drop,
                decimal: true,
              ),
              _buildNumberField(
                controller: _pigWeightController,
                label: 'Average Weight (kg)',
                icon: Icons.monitor_weight,
                decimal: true,
              ),
            ]),
            _buildInputCard([
              _buildDropdownField(
                value: _pigHealthStatus,
                label: 'Health Status',
                icon: Icons.health_and_safety,
                items: const ['good', 'fair', 'poor'],
                onChanged: (value) => setState(() => _pigHealthStatus = value!),
              ),
              _buildNumberField(
                controller: _pigTemperatureController,
                label: 'Temperature (°C)',
                icon: Icons.thermostat,
                decimal: true,
              ),
              _buildNumberField(
                controller: _pigHumidityController,
                label: 'Humidity (%)',
                icon: Icons.opacity,
                decimal: true,
              ),
            ]),
            _buildInputCard([
              _buildTextField(
                controller: _pigNotesController,
                label: 'Notes & Observations',
                icon: Icons.note,
                maxLines: 3,
              ),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _savePigData(),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Saving...' : 'Save Pig Farm Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChickenFarmTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
                '🐔 Chicken Farm - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
            const SizedBox(height: 16),
            _buildInputCard([
              _buildNumberField(
                controller: _chickenTotalAnimalsController,
                label: 'Total Birds',
                icon: Icons.pets,
                required: true,
              ),
              _buildNumberField(
                controller: _chickenNewBirthsController,
                label: 'New Chicks Today',
                icon: Icons.child_care,
              ),
              _buildNumberField(
                controller: _chickenDeathsController,
                label: 'Deaths Today',
                icon: Icons.report_problem,
              ),
            ]),
            _buildInputCard([
              _buildNumberField(
                controller: _chickenFeedController,
                label: 'Feed Consumption (kg)',
                icon: Icons.dining,
                decimal: true,
              ),
              _buildNumberField(
                controller: _chickenWaterController,
                label: 'Water Consumption (L)',
                icon: Icons.water_drop,
                decimal: true,
              ),
              _buildNumberField(
                controller: _chickenEggsController,
                label: 'Eggs Collected',
                icon: Icons.egg,
              ),
            ]),
            _buildInputCard([
              _buildNumberField(
                controller: _chickenWeightController,
                label: 'Average Weight (kg)',
                icon: Icons.monitor_weight,
                decimal: true,
              ),
              _buildDropdownField(
                value: _chickenHealthStatus,
                label: 'Health Status',
                icon: Icons.health_and_safety,
                items: const ['good', 'fair', 'poor'],
                onChanged: (value) =>
                    setState(() => _chickenHealthStatus = value!),
              ),
            ]),
            _buildInputCard([
              _buildNumberField(
                controller: _chickenTemperatureController,
                label: 'Temperature (°C)',
                icon: Icons.thermostat,
                decimal: true,
              ),
              _buildNumberField(
                controller: _chickenHumidityController,
                label: 'Humidity (%)',
                icon: Icons.opacity,
                decimal: true,
              ),
            ]),
            _buildInputCard([
              _buildTextField(
                controller: _chickenNotesController,
                label: 'Notes & Observations',
                icon: Icons.note,
                maxLines: 3,
              ),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _saveChickenData(),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label:
                    Text(_isLoading ? 'Saving...' : 'Save Chicken Farm Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );
  }

  Widget _buildInputCard(List<Widget> children) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    bool decimal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: decimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
        validator: required
            ? (value) =>
                value?.isEmpty == true ? 'This field is required' : null
            : null,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item.toUpperCase()),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _savePigData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final livestockProvider =
          Provider.of<LivestockProvider>(context, listen: false);
      final farmerProvider =
          Provider.of<FarmerProvider>(context, listen: false);

      if (farmerProvider.currentFarmer == null) {
        throw Exception('No farmer logged in');
      }

      final data = LivestockData(
        id: _uuid.v4(),
        farmerId: farmerProvider.currentFarmer!.id,
        type: 'pig',
        date: DateTime.now(),
        totalAnimals: int.tryParse(_pigTotalAnimalsController.text) ?? 0,
        newBirths: int.tryParse(_pigNewBirthsController.text) ?? 0,
        deaths: int.tryParse(_pigDeathsController.text) ?? 0,
        feedConsumption: double.tryParse(_pigFeedController.text) ?? 0.0,
        waterConsumption: double.tryParse(_pigWaterController.text) ?? 0.0,
        averageWeight: double.tryParse(_pigWeightController.text) ?? 0.0,
        healthStatus: _pigHealthStatus,
        notes: _pigNotesController.text,
        temperature: double.tryParse(_pigTemperatureController.text) ?? 0.0,
        humidity: double.tryParse(_pigHumidityController.text) ?? 0.0,
      );

      await livestockProvider.addLivestockData(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pig farm data saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChickenData() async {
    setState(() => _isLoading = true);

    try {
      final livestockProvider =
          Provider.of<LivestockProvider>(context, listen: false);
      final farmerProvider =
          Provider.of<FarmerProvider>(context, listen: false);

      if (farmerProvider.currentFarmer == null) {
        throw Exception('No farmer logged in');
      }

      final data = LivestockData(
        id: _uuid.v4(),
        farmerId: farmerProvider.currentFarmer!.id,
        type: 'chicken',
        date: DateTime.now(),
        totalAnimals: int.tryParse(_chickenTotalAnimalsController.text) ?? 0,
        newBirths: int.tryParse(_chickenNewBirthsController.text) ?? 0,
        deaths: int.tryParse(_chickenDeathsController.text) ?? 0,
        feedConsumption: double.tryParse(_chickenFeedController.text) ?? 0.0,
        waterConsumption: double.tryParse(_chickenWaterController.text) ?? 0.0,
        eggsCollected: int.tryParse(_chickenEggsController.text) ?? 0,
        averageWeight: double.tryParse(_chickenWeightController.text) ?? 0.0,
        healthStatus: _chickenHealthStatus,
        notes: _chickenNotesController.text,
        temperature: double.tryParse(_chickenTemperatureController.text) ?? 0.0,
        humidity: double.tryParse(_chickenHumidityController.text) ?? 0.0,
      );

      await livestockProvider.addLivestockData(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chicken farm data saved successfully!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAnalytics() {
    Navigator.pushNamed(context, '/livestock-analytics');
  }
}
