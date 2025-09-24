import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VeterinarianContactScreen extends StatefulWidget {
  const VeterinarianContactScreen({super.key});

  @override
  State<VeterinarianContactScreen> createState() =>
      _VeterinarianContactScreenState();
}

class _VeterinarianContactScreenState extends State<VeterinarianContactScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample veterinarian data - in real app this would come from API/database
  final List<Veterinarian> _veterinarians = [
    Veterinarian(
      id: '1',
      name: 'Dr. Rajesh Kumar',
      specialization: 'Large Animal Medicine',
      experience: '15 years',
      location: 'Delhi, India',
      phone: '+91 9876543210',
      email: 'dr.rajesh@vetcare.com',
      rating: 4.8,
      availability: 'Mon-Fri: 9AM-6PM',
      isEmergencyAvailable: true,
      consultationFee: 500,
      distance: '2.5 km',
    ),
    Veterinarian(
      id: '2',
      name: 'Dr. Priya Sharma',
      specialization: 'Poultry & Small Animals',
      experience: '12 years',
      location: 'Mumbai, India',
      phone: '+91 9876543211',
      email: 'dr.priya@animalcare.com',
      rating: 4.6,
      availability: 'Mon-Sat: 8AM-7PM',
      isEmergencyAvailable: false,
      consultationFee: 400,
      distance: '5.1 km',
    ),
    Veterinarian(
      id: '3',
      name: 'Dr. Amit Patel',
      specialization: 'Livestock Health & Nutrition',
      experience: '20 years',
      location: 'Bangalore, India',
      phone: '+91 9876543212',
      email: 'dr.amit@livestockcare.com',
      rating: 4.9,
      availability: 'Mon-Sun: 7AM-8PM',
      isEmergencyAvailable: true,
      consultationFee: 600,
      distance: '1.8 km',
    ),
  ];

  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAppointments() {
    // Load user's appointments - mock data for now
    _appointments = [
      Appointment(
        id: '1',
        veterinarianId: '1',
        veterinarianName: 'Dr. Rajesh Kumar',
        date: DateTime.now().add(const Duration(days: 2)),
        time: '10:00 AM',
        type: 'Regular Checkup',
        status: 'Confirmed',
        notes: 'Routine health checkup for cattle',
      ),
      Appointment(
        id: '2',
        veterinarianId: '3',
        veterinarianName: 'Dr. Amit Patel',
        date: DateTime.now().subtract(const Duration(days: 5)),
        time: '2:30 PM',
        type: 'Emergency',
        status: 'Completed',
        notes: 'Pig vaccination and health assessment',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veterinarian Services'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Find Vets', icon: Icon(Icons.search)),
            Tab(text: 'My Appointments', icon: Icon(Icons.schedule)),
            Tab(text: 'Emergency', icon: Icon(Icons.emergency)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVeterinarianListTab(),
          _buildAppointmentsTab(),
          _buildEmergencyTab(),
        ],
      ),
    );
  }

  Widget _buildVeterinarianListTab() {
    return Column(
      children: [
        // Search and filter bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search veterinarians...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', true),
                    _buildFilterChip('Large Animals', false),
                    _buildFilterChip('Poultry', false),
                    _buildFilterChip('Emergency Available', false),
                    _buildFilterChip('Nearby', false),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Veterinarian list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _veterinarians.length,
            itemBuilder: (context, index) {
              final vet = _veterinarians[index];
              return _buildVeterinarianCard(vet);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // Implement filter logic
        },
        selectedColor: Colors.green.withOpacity(0.3),
      ),
    );
  }

  Widget _buildVeterinarianCard(Veterinarian vet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.green,
                  child: Text(
                    vet.name.split(' ').map((n) => n[0]).take(2).join(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vet.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        vet.specialization,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            vet.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${vet.experience} experience',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (vet.isEmergencyAvailable)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Emergency',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(vet.location),
                const Spacer(),
                Icon(Icons.near_me, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(vet.distance),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(vet.availability),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.currency_rupee, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('₹${vet.consultationFee} consultation fee'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callVeterinarian(vet.phone),
                    icon: const Icon(Icons.phone),
                    label: const Text('Call'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _bookAppointment(vet),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Book'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return _appointments.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No appointments yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Book your first appointment with a veterinarian',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _appointments.length,
            itemBuilder: (context, index) {
              final appointment = _appointments[index];
              return _buildAppointmentCard(appointment);
            },
          );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    Color statusColor;
    IconData statusIcon;

    switch (appointment.status.toLowerCase()) {
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusIcon = Icons.done_all;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  appointment.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  appointment.type,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              appointment.veterinarianName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}',
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(appointment.time),
              ],
            ),
            if (appointment.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${appointment.notes}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
            if (appointment.status.toLowerCase() == 'confirmed') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _cancelAppointment(appointment),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _rescheduleAppointment(appointment),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Reschedule'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.emergency,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Emergency Veterinary Services',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'For immediate veterinary assistance, contact our emergency hotline or find the nearest emergency vet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _callEmergency(),
                    icon: const Icon(Icons.phone),
                    label: const Text('Call Emergency Hotline'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Emergency Veterinarians Nearby',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount:
                  _veterinarians.where((v) => v.isEmergencyAvailable).length,
              itemBuilder: (context, index) {
                final emergencyVets = _veterinarians
                    .where((v) => v.isEmergencyAvailable)
                    .toList();
                final vet = emergencyVets[index];
                return _buildEmergencyVetCard(vet);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyVetCard(Veterinarian vet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red,
          child: Text(
            vet.name.split(' ').map((n) => n[0]).take(2).join(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(vet.name),
        subtitle: Text('${vet.distance} • ${vet.specialization}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _callVeterinarian(vet.phone),
              icon: const Icon(Icons.phone, color: Colors.green),
            ),
            IconButton(
              onPressed: () => _getDirections(vet),
              icon: const Icon(Icons.directions, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _callVeterinarian(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not call $phoneNumber')),
      );
    }
  }

  Future<void> _callEmergency() async {
    const emergencyNumber = '+91 9999999999'; // Emergency hotline number
    final Uri url = Uri.parse('tel:$emergencyNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not call emergency number')),
      );
    }
  }

  void _getDirections(Veterinarian vet) {
    // In a real app, this would open Google Maps with directions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Getting directions to ${vet.name}...')),
    );
  }

  void _bookAppointment(Veterinarian vet) {
    showDialog(
      context: context,
      builder: (context) => AppointmentBookingDialog(
        veterinarian: vet,
        onBooked: (appointment) {
          setState(() {
            _appointments.add(appointment);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment booked successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _cancelAppointment(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content:
            const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                appointment.status = 'Cancelled';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment cancelled'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _rescheduleAppointment(Appointment appointment) {
    // Show reschedule dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reschedule feature coming soon!')),
    );
  }
}

// Models
class Veterinarian {
  final String id;
  final String name;
  final String specialization;
  final String experience;
  final String location;
  final String phone;
  final String email;
  final double rating;
  final String availability;
  final bool isEmergencyAvailable;
  final int consultationFee;
  final String distance;

  Veterinarian({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.location,
    required this.phone,
    required this.email,
    required this.rating,
    required this.availability,
    required this.isEmergencyAvailable,
    required this.consultationFee,
    required this.distance,
  });
}

class Appointment {
  final String id;
  final String veterinarianId;
  final String veterinarianName;
  final DateTime date;
  final String time;
  final String type;
  String status;
  final String notes;

  Appointment({
    required this.id,
    required this.veterinarianId,
    required this.veterinarianName,
    required this.date,
    required this.time,
    required this.type,
    required this.status,
    required this.notes,
  });
}

// Appointment booking dialog
class AppointmentBookingDialog extends StatefulWidget {
  final Veterinarian veterinarian;
  final Function(Appointment) onBooked;

  const AppointmentBookingDialog({
    super.key,
    required this.veterinarian,
    required this.onBooked,
  });

  @override
  State<AppointmentBookingDialog> createState() =>
      _AppointmentBookingDialogState();
}

class _AppointmentBookingDialogState extends State<AppointmentBookingDialog> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '10:00 AM';
  String _appointmentType = 'Regular Checkup';
  String _notes = '';

  final List<String> _timeSlots = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM'
  ];

  final List<String> _appointmentTypes = [
    'Regular Checkup',
    'Vaccination',
    'Emergency',
    'Follow-up',
    'Consultation'
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Book Appointment with ${widget.veterinarian.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date picker
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),

            // Time picker
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Time',
                prefixIcon: Icon(Icons.access_time),
              ),
              value: _selectedTime,
              items: _timeSlots.map((time) {
                return DropdownMenuItem(value: time, child: Text(time));
              }).toList(),
              onChanged: (value) => setState(() => _selectedTime = value!),
            ),

            const SizedBox(height: 16),

            // Appointment type
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Appointment Type',
                prefixIcon: Icon(Icons.medical_services),
              ),
              value: _appointmentType,
              items: _appointmentTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) => setState(() => _appointmentType = value!),
            ),

            const SizedBox(height: 16),

            // Notes
            TextField(
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) => _notes = value,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final appointment = Appointment(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              veterinarianId: widget.veterinarian.id,
              veterinarianName: widget.veterinarian.name,
              date: _selectedDate,
              time: _selectedTime,
              type: _appointmentType,
              status: 'Confirmed',
              notes: _notes,
            );

            widget.onBooked(appointment);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Book Appointment'),
        ),
      ],
    );
  }
}
