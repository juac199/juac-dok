import 'package:flutter/material.dart';

import '../main.dart';
import '../services/api_service.dart';
import 'student_attendance_page.dart';
import 'student_performance_page.dart';
import 'student_results_page.dart';
import 'student_subjects_page.dart';

class StudentDashboardPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const StudentDashboardPage({
    super.key,
    required this.user,
  });

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  Map<String, dynamic>? student;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadStudentProfile();
  }

  Future<void> loadStudentProfile() async {
    try {
      final token = widget.user['access_token'] as String;

      final result = await ApiService.getMyStudentProfile(token);

      if (!mounted) return;

      setState(() {
        student = result;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  void openMySubjects() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentSubjectsPage(
          user: widget.user,
        ),
      ),
    );
  }

  void openMyResults() {
    final token = widget.user['access_token'] as String;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentResultsPage(
          token: token,
        ),
      ),
    );
  }

  void openMyPerformance() {
    final token = widget.user['access_token'] as String;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentPerformancePage(
          token: token,
        ),
      ),
    );
  }

  void openMyAttendance() {
    final token = widget.user['access_token'] as String;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentAttendancePage(
          token: token,
        ),
      ),
    );
  }

  Widget profileItem(
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  String getValue(String key) {
    final value = student?[key];

    if (value == null || value.toString().isEmpty) {
      return 'Not available';
    }

    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              errorMessage = null;
                            });

                            loadStudentProfile();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadStudentProfile,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 42,
                                child: Icon(
                                  Icons.person,
                                  size: 48,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                getValue('full_name'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                getValue('program'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Academic Services',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // My Subjects
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(
                              Icons.menu_book_outlined,
                            ),
                          ),
                          title: const Text(
                            'My Subjects',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: const Text(
                            'View and manage your registered subjects',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                          onTap: openMySubjects,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Register Subjects
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(
                              Icons.add_circle_outline,
                            ),
                          ),
                          title: const Text(
                            'Register Subjects',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: const Text(
                            'Browse available subjects and register',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                          onTap: openMySubjects,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Academic Results
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(
                              Icons.assessment_outlined,
                            ),
                          ),
                          title: const Text(
                            'Academic Results',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: const Text(
                            'View your grades, GPA and CGPA',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                          onTap: openMyResults,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Academic Performance
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(
                              Icons.analytics_outlined,
                            ),
                          ),
                          title: const Text(
                            'Academic Performance',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: const Text(
                            'Track your academic progress and performance',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                          onTap: openMyPerformance,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Attendance
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(
                              Icons.calendar_today_outlined,
                            ),
                          ),
                          title: const Text(
                            'Attendance',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: const Text(
                            'View your attendance records and percentage',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                          onTap: openMyAttendance,
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      profileItem(
                        Icons.badge_outlined,
                        'Student Number',
                        getValue('student_number'),
                      ),

                      profileItem(
                        Icons.email_outlined,
                        'Email',
                        getValue('email'),
                      ),

                      profileItem(
                        Icons.school_outlined,
                        'Program',
                        getValue('program'),
                      ),

                      profileItem(
                        Icons.cake_outlined,
                        'Date of Birth',
                        getValue('date_of_birth'),
                      ),

                      profileItem(
                        Icons.phone_outlined,
                        'Phone',
                        getValue('phone'),
                      ),

                      profileItem(
                        Icons.location_on_outlined,
                        'Address',
                        getValue('address'),
                      ),

                      profileItem(
                        Icons.calendar_month_outlined,
                        'Enrollment Date',
                        getValue('enrollment_date'),
                      ),
                    ],
                  ),
                ),
    );
  }
}