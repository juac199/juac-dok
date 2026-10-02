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

  String _desktopSection = 'Dashboard';

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
                      StudentServicesHubPage(user: widget.user),
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

  Widget _desktopContent() {
    switch (_desktopSection) {
      case 'My Profile':
        return StudentProfilePage(user: widget.user);
      case 'My Subjects':
        return StudentSubjectsPage(user: widget.user);
      case 'Results':
        return StudentResultsPage(user: widget.user);
      case 'Attendance':
        return StudentAttendancePage(user: widget.user);
      case 'Performance':
        return StudentPerformancePage(user: widget.user);
      case 'Academic Center':
        return StudentServicesHubPage(user: widget.user);
      case 'Fees & Payments':
        return StudentFeesPage(user: widget.user);
      case 'Visa & Student Pass':
        return StudentVisaPage(user: widget.user);
      case 'Hostel':
        return StudentHostelPage(user: widget.user);
      case 'Announcements':
        return StudentAnnouncementsPage(user: widget.user);
      case 'AI Student Help':
        return StudentAiHelpPage(user: widget.user);
      default:
        return _dashboard();
    }
  }

  Widget _desktopNavItem(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selected = _desktopSection == title;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              _desktopSection = title;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 21,
                  color: selected
                      ? colors.primary
                      : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight:
                          selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected
                          ? colors.primary
                          : colors.onSurface,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.chevron_left_rounded,
                    size: 19,
                    color: colors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _desktopDashboardPanel(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final name = _value(
      'full_name',
      widget.user['full_name']?.toString() ?? 'Student',
    );

    final studentNumber = _value(
      'student_number',
      'Student ID not available',
    );

    final program = _value(
      'program',
      'University Student',
    );

    return Container(
      width: 315,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          left: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.65),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary,
                    colors.primaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.20),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor:
                        colors.onPrimary.withValues(alpha: 0.16),
                    child: Icon(
                      Icons.person_rounded,
                      size: 29,
                      color: colors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          studentNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onPrimary.withValues(alpha: 0.78),
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          program,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onPrimary.withValues(alpha: 0.78),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'STUDENT DASHBOARD',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const ThemeToggleButton(),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
                child: Column(
                  children: [
                    _desktopNavItem(
                      context,
                      Icons.dashboard_rounded,
                      'Dashboard',
                    ),

                    const SizedBox(height: 10),

                    _desktopSectionLabel(
                      context,
                      'ACADEMIC',
                    ),

                    _desktopNavItem(
                      context,
                      Icons.person_rounded,
                      'My Profile',
                    ),
                    _desktopNavItem(
                      context,
                      Icons.menu_book_rounded,
                      'My Subjects',
                    ),
                    _desktopNavItem(
                      context,
                      Icons.assignment_rounded,
                      'Results',
                    ),
                    _desktopNavItem(
                      context,
                      Icons.event_available_rounded,
                      'Attendance',
                    ),
                    _desktopNavItem(
                      context,
                      Icons.insights_rounded,
                      'Performance',
                    ),
                    _desktopNavItem(
                      context,
                      Icons.school_rounded,
                      'Academic Center',
                    ),

                    const SizedBox(height: 10),

                    _desktopSectionLabel(
                      context,
                      'STUDENT SERVICES',
                    ),

                    _desktopNavItem(
                      context,
                      Icons.account_balance_wallet_rounded,
                      'Fees & Payments',
                    ),
                    _desktopNavItem(
                      context,
                      Icons.badge_rounded,
                      'Visa & Student Pass',
                    ),
                    _desktopNavItem(
                      context,
                      Icons.home_work_rounded,
                      'Hostel',
                    ),
                    _desktopNavItem(
                      context,
                      Icons.campaign_rounded,
                      'Announcements',
                    ),
                    _desktopNavItem(
                      context,
                      Icons.smart_toy_rounded,
                      'AI Student Help',
                    ),
                  ],
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.school_rounded,
                    color: colors.onPrimaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Student Portal',
                      style: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.verified_rounded,
                    color: colors.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _desktopSectionLabel(BuildContext context, String title) {
    final colors = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 7),
        child: Text(
          title,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1000;
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        if (!isDesktop) {
          return Scaffold(
            backgroundColor: colors.surfaceContainerLowest,
            appBar: AppBar(
              backgroundColor: colors.surfaceContainerLowest,
              elevation: 0,
              title: Text(
                'Student Portal',
                style: TextStyle(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              actions: [
                const ThemeToggleButton(),
                IconButton(
                  onPressed: _loadProfile,
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
            body: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _errorView()
                    : _dashboard(),
          );
        }

        return Scaffold(
          backgroundColor: colors.surfaceContainerLowest,
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _errorView()
                  : Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: colors.surfaceContainerLowest,
                            child: Column(
                              children: [
                                Container(
                                  height: 70,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: colors.outlineVariant
                                            .withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.school_rounded,
                                        color: colors.primary,
                                        size: 29,
                                      ),
                                      const SizedBox(width: 11),
                                      Text(
                                        'STUDENT MANAGEMENT SYSTEM',
                                        style: TextStyle(
                                          color: colors.onSurface,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        _desktopSection,
                                        style: TextStyle(
                                          color: colors.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: AnimatedSwitcher(
                                    duration:
                                        const Duration(milliseconds: 220),
                                    child: KeyedSubtree(
                                      key: ValueKey(_desktopSection),
                                      child: _desktopContent(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _desktopDashboardPanel(context),
                      ],
                    ),
        );
      },
    );
  }

  Widget _errorView() {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_off_rounded,
              size: 64,
              color: colors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Student Profile Not Available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A student record must exist before the Student Portal can load your profile.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
              ),
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
    );
  }
}
