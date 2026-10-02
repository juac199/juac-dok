
import 'package:flutter/material.dart';

import 'student_academic_calendar_page.dart';
import 'student_timetable_page.dart';
import 'student_documents_page.dart';
import 'student_campus_services_page.dart';
import 'student_career_page.dart';
import 'student_support_page.dart';
import 'student_notifications_page.dart';
import 'student_transcript_page.dart';
import 'student_exam_timetable_page.dart';
import 'student_course_materials_page.dart';
import 'student_graduation_progress_page.dart';
import 'student_gpa_calculator_page.dart';
import 'student_lecturer_course_info_page.dart';

class StudentServicesHubPage extends StatelessWidget {
  final Map<String, dynamic>? user;

  const StudentServicesHubPage({
    super.key,
    this.user,
  });

  void _open(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Services',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
        children: [
          _hero(context),
          const SizedBox(height: 24),

          _section(
            context,
            'Academic Center',
            Icons.school_rounded,
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
              _item(
                context,
                Icons.event_note_rounded,
                'Examination Timetable',
                'View examination dates, times and venues',
                () => _open(
                  context,
                  const StudentExamTimetablePage(),
                ),
              ),
              _item(
                context,
                Icons.description_rounded,
                'Academic Transcript',
                'View your academic record, grades and credits',
                user == null
                    ? () => _showUnavailable(context)
                    : () => _open(
                          context,
                          StudentTranscriptPage(user: user!),
                        ),
              ),
              _item(
                context,
                Icons.folder_copy_rounded,
                'Course Materials',
                'Access notes, tutorials and course resources',
                () => _open(
                  context,
                  const StudentCourseMaterialsPage(),
                ),
              ),
              _item(
                context,
                Icons.calculate_rounded,
                'GPA Calculator',
                'Calculate your semester GPA',
                () => _open(
                  context,
                  const StudentGpaCalculatorPage(),
                ),
              ),
              _item(
                context,
                Icons.school_outlined,
                'Graduation Progress',
                'Track credits and graduation requirements',
                user == null
                    ? () => _showUnavailable(context)
                    : () => _open(
                          context,
                          StudentGraduationProgressPage(user: user!),
                        ),
              ),
              _item(
                context,
                Icons.people_alt_rounded,
                'Lecturer & Course Info',
                'Course details, lecturers and teaching information',
                () => _open(
                  context,
                  const StudentLecturerCourseInfoPage(),
                ),
              ),
            ],
          ),

          _section(
            context,
            'University Services',
            Icons.apartment_rounded,
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
            Icons.support_agent_rounded,
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

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: colors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'University services are being expanded to give you one central place for academic and campus needs.',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Student Services',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Your central university portal for academic, campus and support services.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> items,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 21,
              color: colors.primary,
            ),
            const SizedBox(width: 9),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        ...items,
        const SizedBox(height: 14),
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
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shadowColor: colors.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(19),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.25),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.3,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Student information is not available on this page.'),
      ),
    );
  }
}
