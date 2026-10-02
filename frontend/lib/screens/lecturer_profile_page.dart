import 'package:flutter/material.dart';

import '../services/api_service.dart';

class LecturerProfilePage extends StatefulWidget {
  final String token;

  const LecturerProfilePage({super.key, required this.token});

  @override
  State<LecturerProfilePage> createState() => _LecturerProfilePageState();
}

class _LecturerProfilePageState extends State<LecturerProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.getMyLecturerProfile(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load profile.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No profile information found.'));
          }

          final profile = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 55),
                ),

                const SizedBox(height: 20),

                Text(
                  profile['full_name'] ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  profile['lecturer_number'] ?? 'N/A',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 30),

                _profileItem(
                  icon: Icons.email,
                  title: 'Email',
                  value: profile['email'],
                ),

                _profileItem(
                  icon: Icons.badge,
                  title: 'Lecturer Number',
                  value: profile['lecturer_number'],
                ),

                _profileItem(
                  icon: Icons.business,
                  title: 'Department',
                  value: profile['department'],
                ),

                _profileItem(
                  icon: Icons.phone,
                  title: 'Phone',
                  value: profile['phone'],
                ),

                _profileItem(
                  icon: Icons.school,
                  title: 'Specialization',
                  value: profile['specialization'],
                ),

                _profileItem(
                  icon: Icons.calendar_today,
                  title: 'Hire Date',
                  value: profile['hire_date'],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _profileItem({
    required IconData icon,
    required String title,
    dynamic value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value?.toString() ?? 'N/A'),
      ),
    );
  }
}
