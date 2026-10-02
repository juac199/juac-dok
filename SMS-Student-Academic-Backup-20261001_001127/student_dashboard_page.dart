import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/theme_controller.dart';
import 'student_subjects_page.dart';
import 'student_results_page.dart';
import 'student_attendance_page.dart';
import 'student_performance_page.dart';
import 'student_ai_help_page.dart';
import 'student_hostel_page.dart';
import 'student_announcements_page.dart';
import 'student_visa_page.dart';
import 'student_fees_page.dart';
import 'student_profile_page.dart';
import 'student_services_hub_page.dart';

class StudentDashboardPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const StudentDashboardPage({super.key, required this.user});

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _student;

  String get token => widget.user['access_token'] as String;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ApiService.getMyStudentProfile(token);

      if (!mounted) return;

      setState(() {
        _student = data;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  String _value(String key, String fallback) {
    final value = _student?[key];

    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }

    return value.toString();
  }

  Widget _statCard(IconData icon, String title, String value) {
    return Expanded(
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFE3E8F0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: const Color(0xFFEAF2FF),
                child: Icon(icon, color: const Color(0xFF2457A6), size: 21),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF102A43),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _serviceTile(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE3E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEAF2FF),
          child: Icon(icon, color: const Color(0xFF2457A6)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF102A43),
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF6B7280)),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF8A94A6),
        ),
        onTap:
            onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$title will be connected in the next Student 2.0 layer.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
      ),
    );
  }


  Widget _dashboard() {
    final name = _value(
      'full_name',
      widget.user['full_name']?.toString() ?? 'Student',
    );

    final studentNumber = _value('student_number', 'Student ID not available');

    final program = _value('program', 'University Student');

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF102A43), Color(0xFF2457A6)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF102A43).withValues(alpha: 0.16),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0x33FFFFFF),
                  child: Icon(
                    Icons.person_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome back,',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        studentNumber,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Academic Overview',
            style: TextStyle(
              color: Color(0xFF102A43),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statCard(Icons.school_rounded, 'Program', program),
              const SizedBox(width: 12),
              _statCard(Icons.badge_rounded, 'Student ID', studentNumber),
            ],
          ),
          const SizedBox(height: 26),
          const Text(
            'Academic Services',
            style: TextStyle(
              color: Color(0xFF102A43),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _serviceTile(
            Icons.person_rounded,
            'My Profile',
            'View your personal and academic information',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentProfilePage(user: widget.user),
                ),
              );
            },
          ),

          _serviceTile(
            Icons.menu_book_rounded,
            'My Subjects',
            'View and manage your registered subjects',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentSubjectsPage(user: widget.user),
                ),
              );
            },
          ),
          _serviceTile(
            Icons.assignment_rounded,
            'Results',
            'View examination results and grades',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentResultsPage(user: widget.user),
                ),
              );
            },
          ),
          _serviceTile(
            Icons.event_available_rounded,
            'Attendance',
            'Track your attendance records',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      StudentAttendancePage(user: widget.user),
                ),
              );
            },
          ),
          _serviceTile(
            Icons.insights_rounded,
            'Performance',
            'Review your academic progress',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      StudentPerformancePage(user: widget.user),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          const SizedBox(height: 12),
          _serviceTile(
            Icons.dashboard_customize_rounded,
            'Student Services Hub',
            'Academic calendar, timetable, documents, campus and career services',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      StudentServicesHubPage(),
                ),
              );
            },
          ),
          const Text(
            'Student Services',
            style: TextStyle(
              color: Color(0xFF102A43),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _serviceTile(
            Icons.account_balance_wallet_rounded,
            'Fees & Payments',
            'Check fees, invoices and payments',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentFeesPage(user: widget.user),
                ),
              );
            },
          ),
          _serviceTile(
            Icons.badge_rounded,
            'Visa & Student Pass',
            'View visa status and important dates',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentVisaPage(user: widget.user),
                ),
              );
            },
          ),
          _serviceTile(
            Icons.home_work_rounded,
            'Hostel',
            'Accommodation information and services',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentHostelPage(user: widget.user),
                ),
              );
            },
          ),
          _serviceTile(
            Icons.campaign_rounded,
            'Announcements',
            'University news and important notices',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      StudentAnnouncementsPage(user: widget.user),
                ),
              );
            },
          ),
          _serviceTile(
            Icons.smart_toy_rounded,
            'AI Student Help',
            'Get help with university services',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentAiHelpPage(user: widget.user),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: const Text(
          'Student Portal',
          style: TextStyle(
            color: Color(0xFF102A43),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            onPressed: _loadProfile,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF102A43)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_off_rounded,
                      size: 64,
                      color: Color(0xFF2457A6),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Student Profile Not Available',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF102A43),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A student record must exist before the Student Portal can load your profile.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: _loadProfile,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          : _dashboard(),
    );
  }
}
