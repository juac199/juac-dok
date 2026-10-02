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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text(
          'Student Services',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.primary,
                  colors.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.22),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: colors.onPrimary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    size: 32,
                    color: colors.onPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student Services Hub',
                        style: TextStyle(
                          color: colors.onPrimary,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Academic tools, university services and student support in one place.',
                        style: TextStyle(
                          color: colors.onPrimary.withValues(alpha: 0.88),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _sectionTitle(context, 'Academic Center'),

          _serviceCard(
            context,
            icon: Icons.menu_book_rounded,
            title: 'Academic Transcript',
            subtitle: 'View your academic history, grades, credits and CGPA.',
            onTap: user == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentTranscriptPage(user: user!),
                      ),
                    );
                  },
          ),

          _serviceCard(
            context,
            icon: Icons.event_note_rounded,
            title: 'Examination Timetable',
            subtitle: 'View examination dates, times and venues.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentExamTimetablePage(),
                ),
              );
            },
          ),

          _serviceCard(
            context,
            icon: Icons.folder_copy_rounded,
            title: 'Course Materials',
            subtitle: 'Access lecture notes, tutorials and course resources.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentCourseMaterialsPage(),
                ),
              );
            },
          ),

          _serviceCard(
            context,
            icon: Icons.school_rounded,
            title: 'Graduation Progress',
            subtitle: 'Track credits and your progress toward graduation.',
            onTap: user == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            StudentGraduationProgressPage(user: user!),
                      ),
                    );
                  },
          ),

          _serviceCard(
            context,
            icon: Icons.calculate_rounded,
            title: 'GPA Calculator',
            subtitle: 'Calculate your GPA using subjects and grade points.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentGpaCalculatorPage(),
                ),
              );
            },
          ),

          _serviceCard(
            context,
            icon: Icons.people_alt_rounded,
            title: 'Lecturer & Course Information',
            subtitle: 'View course information and lecturer details.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentLecturerCourseInfoPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          _sectionTitle(context, 'University Services'),

          _serviceCard(
            context,
            icon: Icons.calendar_month_rounded,
            title: 'Academic Calendar',
            subtitle: 'Important academic dates and university activities.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentAcademicCalendarPage(),
                ),
              );
            },
          ),

          _serviceCard(
            context,
            icon: Icons.schedule_rounded,
            title: 'Class Timetable',
            subtitle: 'View your weekly classes and schedules.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentTimetablePage(),
                ),
              );
            },
          ),

          _serviceCard(
            context,
            icon: Icons.description_rounded,
            title: 'My Documents',
            subtitle: 'Student documents and academic records.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentDocumentsPage(),
                ),
              );
            },
          ),

          _serviceCard(
            context,
            icon: Icons.location_city_rounded,
            title: 'Campus Services',
            subtitle: 'Explore useful services available around campus.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentCampusServicesPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          _sectionTitle(context, 'Future & Support'),

          _serviceCard(
            context,
            icon: Icons.work_outline_rounded,
            title: 'Career Center',
            subtitle: 'Career development, internships and opportunities.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentCareerPage(),
                ),
              );
            },
          ),

          _serviceCard(
            context,
            icon: Icons.support_agent_rounded,
            title: 'Help & Support',
            subtitle: 'Get help with university and student services.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentSupportPage(),
                ),
              );
            },
          ),

          _serviceCard(
            context,
            icon: Icons.notifications_active_rounded,
            title: 'Notifications',
            subtitle: 'Stay updated with student-related information.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentNotificationsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 22,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shadowColor: colors.primary.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: colors.onPrimaryContainer,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
