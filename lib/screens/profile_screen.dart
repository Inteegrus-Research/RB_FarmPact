import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmpact/providers/farmer_provider.dart';
import 'package:farmpact/models/farmer_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadFarmerData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
  }

  void _loadFarmerData() {
    final farmerProvider = Provider.of<FarmerProvider>(context, listen: false);
    final farmer = farmerProvider.currentFarmer;

    if (farmer != null) {
      _nameController.text = farmer.name;
      _phoneController.text = farmer.phoneNumber;
      _emailController.text = farmer.email;
      _addressController.text = farmer.address;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profile',
            ),
          if (_isEditing)
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Save',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<FarmerProvider>(
              builder: (context, farmerProvider, child) {
                final farmer = farmerProvider.currentFarmer;
                if (farmer == null) {
                  return const Center(
                    child: Text('No farmer data found'),
                  );
                }
                return _buildProfileContent(farmer);
              },
            ),
    );
  }

  Widget _buildProfileContent(Farmer farmer) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(farmer),
            const SizedBox(height: 32),

            // Personal Information Section
            _buildSection(
              title: 'Personal Information',
              icon: Icons.person,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  enabled: _isEditing,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  enabled: _isEditing,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.location_on_outlined,
                  enabled: _isEditing,
                  maxLines: 3,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Location Information Section
            _buildSection(
              title: 'Location Information',
              icon: Icons.location_city,
              children: [
                _buildInfoTile(
                  icon: Icons.location_city_outlined,
                  title: 'City',
                  value: farmer.location.city,
                ),
                const SizedBox(height: 12),
                _buildInfoTile(
                  icon: Icons.map_outlined,
                  title: 'State',
                  value: farmer.location.state,
                ),
                const SizedBox(height: 12),
                _buildInfoTile(
                  icon: Icons.pin_drop_outlined,
                  title: 'Pin Code',
                  value: farmer.location.pincode,
                ),
                const SizedBox(height: 12),
                _buildInfoTile(
                  icon: Icons.public_outlined,
                  title: 'Country',
                  value: farmer.location.country,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Farms Information Section
            _buildSection(
              title: 'Farms (${farmer.farms.length})',
              icon: Icons.agriculture,
              children: [
                if (farmer.farms.isEmpty)
                  const Text(
                    'No farms registered',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ...farmer.farms.map((farm) => _buildFarmCard(farm)),
              ],
            ),

            const SizedBox(height: 24),

            // Statistics Section
            _buildStatisticsSection(farmer),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Farmer farmer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage: farmer.profileImagePath != null
                ? AssetImage(farmer.profileImagePath!)
                : null,
            child: farmer.profileImagePath == null
                ? Text(
                    farmer.name.isNotEmpty ? farmer.name[0].toUpperCase() : 'F',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  farmer.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  farmer.phoneNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Member since ${_formatDate(farmer.registrationDate)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green),
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
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[100],
      ),
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (label.contains('Email') && (value == null || value.isEmpty)) {
          return null; // Email is optional
        }
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFarmCard(Farm farm) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.agriculture, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    farm.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFarmStat(
                    icon: Icons.crop_landscape,
                    label: 'Area',
                    value: '${farm.area} acres',
                  ),
                ),
                Expanded(
                  child: _buildFarmStat(
                    icon: Icons.terrain,
                    label: 'Soil Type',
                    value: farm.soilType,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFarmStat(
                    icon: Icons.eco,
                    label: 'Crops',
                    value: '${farm.crops.length}',
                  ),
                ),
                Expanded(
                  child: _buildFarmStat(
                    icon: Icons.pets,
                    label: 'Livestock',
                    value: '${farm.livestock.length}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatisticsSection(Farmer farmer) {
    final totalFarmArea =
        farmer.farms.fold<double>(0, (sum, farm) => sum + farm.area);
    final totalCrops =
        farmer.farms.fold<int>(0, (sum, farm) => sum + farm.crops.length);
    final totalLivestock =
        farmer.farms.fold<int>(0, (sum, farm) => sum + farm.livestock.length);

    return _buildSection(
      title: 'Statistics',
      icon: Icons.analytics,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Farms',
                value: '${farmer.farms.length}',
                icon: Icons.agriculture,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Total Area',
                value: '$totalFarmArea acres',
                icon: Icons.crop_landscape,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Crops',
                value: '$totalCrops',
                icon: Icons.eco,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Total Livestock',
                value: '$totalLivestock',
                icon: Icons.pets,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final farmerProvider =
          Provider.of<FarmerProvider>(context, listen: false);
      final currentFarmer = farmerProvider.currentFarmer;

      if (currentFarmer != null) {
        final updatedFarmer = Farmer(
          id: currentFarmer.id,
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
          location: currentFarmer.location,
          farms: currentFarmer.farms,
          registrationDate: currentFarmer.registrationDate,
          profileImagePath: currentFarmer.profileImagePath,
        );

        await farmerProvider.updateFarmer(updatedFarmer);

        setState(() => _isEditing = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
