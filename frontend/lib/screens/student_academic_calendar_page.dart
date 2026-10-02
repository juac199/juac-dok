import 'package:flutter/material.dart';

class StudentAcademicCalendarPage extends StatelessWidget {
  const StudentAcademicCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final events = [
      ('Course Registration', 'Important academic registration period', Icons.edit_calendar_rounded),
      ('Add / Drop Period', 'Subject changes and registration adjustments', Icons.swap_horiz_rounded),
      ('Mid-Semester', 'Academic progress and assessments', Icons.menu_book_rounded),
      ('Final Examinations', 'Check your examination timetable', Icons.assignment_rounded),
      ('Semester Break', 'University semester break', Icons.beach_access_rounded),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Academic Calendar',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _HeaderCard(
            icon: Icons.calendar_month_rounded,
            title: 'Academic Calendar',
            subtitle: 'Important dates and university academic events.',
          ),
          const SizedBox(height: 20),
          ...events.map(
            (event) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(event.$3),
                ),
                title: Text(
                  event.$1,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(event.$2),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HeaderCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
