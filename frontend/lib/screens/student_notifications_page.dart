import 'package:flutter/material.dart';

class StudentNotificationsPage extends StatelessWidget {
  const StudentNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _notification(
            context,
            Icons.school_rounded,
            'Academic Updates',
            'Important academic announcements will appear here.',
          ),
          _notification(
            context,
            Icons.account_balance_wallet_rounded,
            'Finance',
            'Fee deadlines and payment notifications will appear here.',
          ),
          _notification(
            context,
            Icons.notifications_active_rounded,
            'University Alerts',
            'Important university notices will appear here.',
          ),
          _notification(
            context,
            Icons.event_available_rounded,
            'Upcoming Events',
            'Examinations, events and deadlines will appear here.',
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'You are all caught up.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notification(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}
