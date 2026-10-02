import 'package:flutter/material.dart';

import 'student_academic_calendar_page.dart';
import 'student_timetable_page.dart';
import 'student_documents_page.dart';
import 'student_campus_services_page.dart';
import 'student_career_page.dart';
import 'student_support_page.dart';
import 'student_notifications_page.dart';

class StudentServicesHubPage extends StatelessWidget {
  const StudentServicesHubPage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Services',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                SizedBox(height: 16),
                Text(
                  'Student Services',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Everything you need for your university journey.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _section(
            context,
            'Academic',
            [
              _item(
                context,
                Icons.calendar_month_rounded,
                'Academic Calendar',
                'Semester dates, examinations and important deadlines',
                () => _open(
                  context,
                  const StudentAcademicCalendarPage(),
                ),
              ),
              _item(
                context,
                Icons.schedule_rounded,
                'Class Timetable',
                'View your weekly lecture schedule',
                () => _open(
                  context,
                  const StudentTimetablePage(),
                ),
              ),
            ],
          ),
          _section(
            context,
            'University Services',
            [
              _item(
                context,
                Icons.description_rounded,
                'My Documents',
                'Access important student documents',
                () => _open(
                  context,
                  const StudentDocumentsPage(),
                ),
              ),
              _item(
                context,
                Icons.apartment_rounded,
                'Campus Services',
                'Library, transport, health, sports and more',
                () => _open(
                  context,
                  const StudentCampusServicesPage(),
                ),
              ),
            ],
          ),
          _section(
            context,
            'Future & Support',
            [
              _item(
                context,
                Icons.work_outline_rounded,
                'Career Center',
                'Internships, jobs and career resources',
                () => _open(
                  context,
                  const StudentCareerPage(),
                ),
              ),
              _item(
                context,
                Icons.support_agent_rounded,
                'Help & Support',
                'Get help and submit support requests',
                () => _open(
                  context,
                  const StudentSupportPage(),
                ),
              ),
              _item(
                context,
                Icons.notifications_none_rounded,
                'Notifications',
                'Important student and university alerts',
                () => _open(
                  context,
                  const StudentNotificationsPage(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        ...items,
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.35),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor:
              theme.colorScheme.primaryContainer,
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(subtitle),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
        ),
      ),
    );
  }
}
