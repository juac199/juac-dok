import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';

import 'lecturer_attendance_page.dart';
import 'lecturer_profile_page.dart';
import 'lecturer_results_page.dart';
import 'lecturer_students_page.dart';
import 'lecturer_subjects_page.dart';

class LecturerDashboardPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const LecturerDashboardPage({super.key, required this.user});

  @override
  State<LecturerDashboardPage> createState() => _LecturerDashboardPageState();
}

class _LecturerDashboardPageState extends State<LecturerDashboardPage> {
  int _selectedIndex = 0;

  String get _token => widget.user['access_token']?.toString() ?? '';

  String get _name => widget.user['full_name']?.toString() ?? 'Lecturer';

  String get _email => widget.user['email']?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Management System',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          const ThemeToggleButton(),
          if (!isWide)
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
        ],
      ),
      drawer: isWide ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isWide) _buildSideNavigation(context),
          Expanded(child: _buildCurrentPage(context)),
        ],
      ),
    );
  }

  Widget _buildSideNavigation(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),

          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.school,
              size: 34,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'LECTURER PORTAL',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),

          const SizedBox(height: 24),

          Expanded(child: _buildNavigationItems()),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: _logout,
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    child: Text(
                      _initials(_name),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _email,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(child: _buildNavigationItems(closeDrawer: true)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItems({bool closeDrawer = false}) {
    final items = [
      (Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
      (Icons.person_outline, Icons.person, 'My Profile'),
      (Icons.menu_book_outlined, Icons.menu_book, 'My Subjects'),
      (Icons.groups_outlined, Icons.groups, 'Students'),
      (Icons.fact_check_outlined, Icons.fact_check, 'Attendance'),
      (Icons.assignment_outlined, Icons.assignment, 'Results'),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final selected = _selectedIndex == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: ListTile(
            selected: selected,
            selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: Icon(selected ? item.$2 : item.$1),
            title: Text(item.$3),
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });

              if (closeDrawer) {
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildCurrentPage(BuildContext context) {
    switch (_selectedIndex) {
      case 1:
        return LecturerProfilePage(token: _token);

      case 2:
        return LecturerSubjectsPage(token: _token);

      case 3:
        return LecturerStudentsPage(token: _token);

      case 4:
        return LecturerAttendancePage(token: _token);

      case 5:
        return LecturerResultsPage(token: _token);

      default:
        return _buildDashboardHome(context);
    }
  }

  Widget _buildDashboardHome(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(context),

              const SizedBox(height: 28),

              const Text(
                'Teaching Overview',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 900
                      ? 4
                      : constraints.maxWidth >= 600
                      ? 2
                      : 1;

                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.45,
                    children: [
                      _statCard(
                        context,
                        icon: Icons.menu_book,
                        title: 'My Subjects',
                        value: 'View',
                        subtitle: 'Assigned courses',
                        index: 2,
                      ),
                      _statCard(
                        context,
                        icon: Icons.groups,
                        title: 'Students',
                        value: 'View',
                        subtitle: 'Enrolled students',
                        index: 3,
                      ),
                      _statCard(
                        context,
                        icon: Icons.fact_check,
                        title: 'Attendance',
                        value: 'Manage',
                        subtitle: 'Track attendance',
                        index: 4,
                      ),
                      _statCard(
                        context,
                        icon: Icons.assignment,
                        title: 'Results',
                        value: 'Manage',
                        subtitle: 'Student results',
                        index: 5,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 900
                      ? 3
                      : constraints.maxWidth >= 600
                      ? 2
                      : 1;

                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.7,
                    children: [
                      _actionCard(
                        context,
                        icon: Icons.person,
                        title: 'My Profile',
                        subtitle: 'View your lecturer information',
                        index: 1,
                      ),
                      _actionCard(
                        context,
                        icon: Icons.menu_book,
                        title: 'Teaching Subjects',
                        subtitle: 'Open your assigned subjects',
                        index: 2,
                      ),
                      _actionCard(
                        context,
                        icon: Icons.groups,
                        title: 'My Students',
                        subtitle: 'View students by subject',
                        index: 3,
                      ),
                      _actionCard(
                        context,
                        icon: Icons.fact_check,
                        title: 'Take Attendance',
                        subtitle: 'Record student attendance',
                        index: 4,
                      ),
                      _actionCard(
                        context,
                        icon: Icons.edit_note,
                        title: 'Enter Results',
                        subtitle: 'Add student marks',
                        index: 5,
                      ),
                      _actionCard(
                        context,
                        icon: Icons.analytics_outlined,
                        title: 'Teaching Analytics',
                        subtitle: 'Performance tools coming next',
                        index: 0,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              _buildInformationCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: Text(
              _initials(_name),
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $_name',
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Manage your teaching, students, attendance and results from one place.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required int index,
  }) {
    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Icon(icon),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 15),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required int index,
  }) {
    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Icon(icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInformationCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lecturer Portal',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Use the navigation menu to manage your teaching activities. Additional analytics, announcements and lecturer services will be added in the next development phases.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'L';
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }
}
