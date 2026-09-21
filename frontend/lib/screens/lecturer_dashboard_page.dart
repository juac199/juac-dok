import 'package:flutter/material.dart';

import 'lecturer_profile_page.dart';
import 'lecturer_subjects_page.dart';
import 'lecturer_students_page.dart';
import 'lecturer_attendance_page.dart';
import 'lecturer_results_page.dart';

class LecturerDashboardPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const LecturerDashboardPage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final String name = user['full_name'] ?? 'Lecturer';
    final String email = user['email'] ?? '';
    final String role = user['role'] ?? 'lecturer';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1000,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          child: Icon(
                            Icons.person,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, $name',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(email),
                              const SizedBox(height: 4),
                              Text(
                                role.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.indigo.shade700,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Lecturer Management',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _DashboardCard(
                      icon: Icons.person_outline,
                      title: 'My Profile',
                      subtitle: 'View lecturer profile',
                      onTap: () {
                        final token =
                            user['access_token'];

                        if (token == null ||
                            token.toString().isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Authentication token not found.',
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LecturerProfilePage(
                              token: token.toString(),
                            ),
                          ),
                        );
                      },
                    ),
                    _DashboardCard(
                      icon: Icons.menu_book_outlined,
                      title: 'My Subjects',
                      subtitle: 'View assigned subjects',
                      onTap: () {
                        final token =
                            user['access_token'];

                        if (token == null ||
                            token.toString().isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Authentication token not found.',
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LecturerSubjectsPage(
                              token: token.toString(),
                            ),
                          ),
                        );
                      },
                    ),
                    _DashboardCard(
                      icon: Icons.groups_outlined,
                      title: 'Students',
                      subtitle: 'View enrolled students',
                      onTap: () {
                        final token =
                            user['access_token'];

                        if (token == null ||
                            token.toString().isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Authentication token not found.',
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LecturerStudentsPage(
                              token: token.toString(),
                            ),
                          ),
                        );
                      },
                    ),
                    _DashboardCard(
                      icon: Icons.fact_check_outlined,
                      title: 'Attendance',
                      subtitle: 'Manage student attendance',
                      onTap: () {
                        final token =
                            user['access_token'];

                        if (token == null ||
                            token.toString().isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Authentication token not found.',
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LecturerAttendancePage(
                              token: token.toString(),
                            ),
                          ),
                        );
                      },
                    ),
                    _DashboardCard(
                      icon: Icons.assignment_outlined,
                      title: 'Results',
                      subtitle: 'Manage student results',
                      onTap: () {
                        final token =
                            user['access_token'];

                        if (token == null ||
                            token.toString().isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Authentication token not found.',
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LecturerResultsPage(
                              token: token.toString(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 42,
                color: Colors.indigo,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
