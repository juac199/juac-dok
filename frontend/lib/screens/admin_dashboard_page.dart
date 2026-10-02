import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/theme_controller.dart';
import 'admin_student_management_page.dart';
import 'admin_statistics_page.dart';
import 'subject_management_page.dart';
import 'lecturer_management_page.dart';
import 'admin_enrollment_management_page.dart';
import 'admin_results_page.dart';
import 'admin_service_pages.dart';

class AdminDashboardPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminDashboardPage({super.key, required this.user});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int selectedIndex = 0;
  int studentCount = 0;
  bool loading = true;

  String get adminName =>
      (widget.user['full_name'] ?? 'Administrator').toString();

  String get token => widget.user['access_token'] as String;

  final List<_AdminNavItem> navigation = const [
    _AdminNavItem(
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
    ),
    _AdminNavItem(
      title: 'Students',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
    ),
    _AdminNavItem(
      title: 'Lecturers',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
    _AdminNavItem(
      title: 'Subjects',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
    ),
    _AdminNavItem(
      title: 'Enrollments',
      icon: Icons.how_to_reg_outlined,
      selectedIcon: Icons.how_to_reg,
    ),
    _AdminNavItem(
      title: 'Results',
      icon: Icons.assessment_outlined,
      selectedIcon: Icons.assessment,
    ),
    _AdminNavItem(
      title: 'Statistics',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
    ),
    _AdminNavItem(
      title: 'Finance',
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
    ),
    _AdminNavItem(
      title: 'Hostel',
      icon: Icons.apartment_outlined,
      selectedIcon: Icons.apartment,
    ),
    _AdminNavItem(
      title: 'Visa & Pass',
      icon: Icons.badge_outlined,
      selectedIcon: Icons.badge,
    ),
    _AdminNavItem(
      title: 'Documents',
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder,
    ),
    _AdminNavItem(
      title: 'Announcements',
      icon: Icons.campaign_outlined,
      selectedIcon: Icons.campaign,
    ),
    _AdminNavItem(
      title: 'Notifications',
      icon: Icons.notifications_none_outlined,
      selectedIcon: Icons.notifications,
    ),
    _AdminNavItem(
      title: 'AI Assistant',
      icon: Icons.smart_toy_outlined,
      selectedIcon: Icons.smart_toy,
    ),
    _AdminNavItem(
      title: 'Reports',
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
    ),
    _AdminNavItem(
      title: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  Future<void> _loadOverview() async {
    try {
      final students = await ApiService.getStudents(token);

      if (!mounted) return;

      setState(() {
        studentCount = students.length;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  void _logout() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Widget _pageForIndex() {
    switch (selectedIndex) {
      case 1:
        return AdminStudentManagementPage(user: widget.user);
      case 2:
        return LecturerManagementPage(user: widget.user);
      case 3:
        return SubjectManagementPage(user: widget.user);
      case 4:
        return AdminEnrollmentManagementPage(user: widget.user);
      case 5:
        return AdminResultsPage(token: token);
      case 6:
        return AdminStatisticsPage(user: widget.user);
      case 7:
        return AdminFinancePage(user: widget.user);
      case 8:
        return AdminHostelPage(user: widget.user);
      case 9:
        return AdminVisaPage(user: widget.user);
      case 10:
        return AdminDocumentsPage(user: widget.user);
      case 11:
        return AdminAnnouncementsPage(user: widget.user);
      case 12:
        return AdminNotificationsPage(user: widget.user);
      case 13:
        return AdminAiAssistantPage(user: widget.user);
      case 14:
        return AdminReportsPage(user: widget.user);
      case 15:
        return AdminSettingsPage(user: widget.user);
      default:
        return _buildOverview();
    }
  }

  Widget _buildOverview() {
    return RefreshIndicator(
      onRefresh: _loadOverview,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;

          return ListView(
            padding: EdgeInsets.all(wide ? 32 : 20),
            children: [
              _buildWelcomeHeader(wide),
              const SizedBox(height: 24),
              _buildSummaryCards(wide),
              const SizedBox(height: 26),
              _buildQuickActions(wide),
              const SizedBox(height: 26),
              _buildUniversityServices(wide),
              const SizedBox(height: 26),
              _buildSystemNotice(),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(bool wide) {
    return Container(
      padding: EdgeInsets.all(wide ? 30 : 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning, $adminName 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: wide ? 28 : 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'University Administration Portal',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (wide)
            IconButton(
              tooltip: 'Refresh',
              onPressed: loading ? null : _loadOverview,
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(bool wide) {
    final cards = [
      _SummaryCard(
        title: 'Students',
        value: loading ? '...' : '$studentCount',
        icon: Icons.people_alt_outlined,
        description: 'Registered students',
      ),
      const _SummaryCard(
        title: 'Academic',
        value: 'Live',
        icon: Icons.school_outlined,
        description: 'Academic management',
      ),
      const _SummaryCard(
        title: 'Services',
        value: '8+',
        icon: Icons.apps_outlined,
        description: 'University services',
      ),
      const _SummaryCard(
        title: 'Security',
        value: 'RBAC',
        icon: Icons.security_outlined,
        description: 'Role-based access',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisExtent: 135,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (_, index) => _SummaryCardWidget(card: cards[index]),
    );
  }

  Widget _buildQuickActions(bool wide) {
    final actions = [
      _QuickAction('Students', Icons.people_outline, () => _select(1)),
      _QuickAction('Subjects', Icons.menu_book_outlined, () => _select(3)),
      _QuickAction('Enrollments', Icons.how_to_reg_outlined, () => _select(4)),
      _QuickAction('Results', Icons.assessment_outlined, () => _select(5)),
      _QuickAction('Statistics', Icons.insights_outlined, () => _select(6)),
      _QuickAction('AI Assistant', Icons.smart_toy_outlined, () => _select(13)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: actions
              .map(
                (action) => SizedBox(
                  width: wide ? 180 : 145,
                  child: OutlinedButton.icon(
                    onPressed: action.onTap,
                    icon: Icon(action.icon, size: 19),
                    label: Text(action.title),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildUniversityServices(bool wide) {
    final services = [
      _ServiceTile(
        'Finance',
        'Fees & payments',
        Icons.account_balance_wallet_outlined,
        7,
      ),
      _ServiceTile('Hostel', 'Accommodation', Icons.apartment_outlined, 8),
      _ServiceTile(
        'Visa & Pass',
        'Immigration support',
        Icons.badge_outlined,
        9,
      ),
      _ServiceTile('Documents', 'Student documents', Icons.folder_outlined, 10),
      _ServiceTile(
        'Announcements',
        'University news',
        Icons.campaign_outlined,
        11,
      ),
      _ServiceTile(
        'Notifications',
        'System alerts',
        Icons.notifications_none_outlined,
        12,
      ),
      _ServiceTile(
        'Reports',
        'Reports & analytics',
        Icons.analytics_outlined,
        14,
      ),
      _ServiceTile('Settings', 'Administration', Icons.settings_outlined, 15),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'University Services',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 330,
            mainAxisExtent: 110,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemBuilder: (_, index) {
            final service = services[index];

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _select(service.index),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          service.icon,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              service.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
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
          },
        ),
      ],
    );
  }

  Widget _buildSystemNotice() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Administration Center',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Academic management modules are connected to the existing backend. '
                    'University service modules are prepared for their database and API integration.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _select(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget _buildSidebar() {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: _select,
      labelType: NavigationRailLabelType.none,
      extended: true,
      leading: Padding(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 24),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.school,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'SMS UNIVERSITY',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            const Text(
              'ADMINISTRATION',
              style: TextStyle(fontSize: 9, letterSpacing: 1.1),
            ),
          ],
        ),
      ),
      destinations: navigation
          .map(
            (item) => NavigationRailDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: Text(item.title),
            ),
          )
          .toList(),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ThemeToggleButton(),
                const SizedBox(height: 4),
                IconButton(
                  tooltip: 'Logout',
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 1050;

        if (desktop) {
          return Scaffold(
            body: Row(
              children: [
                Material(
                  elevation: 2,
                  child: SizedBox(width: 250, child: _buildSidebar()),
                ),
                Expanded(child: _pageForIndex()),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              navigation[selectedIndex].title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              const ThemeToggleButton(),

              if (selectedIndex == 0)
                IconButton(
                  onPressed: loading ? null : _loadOverview,
                  icon: const Icon(Icons.refresh),
                ),
              IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
            ],
          ),
          drawer: Drawer(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          child: Icon(
                            Icons.admin_panel_settings_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            adminName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: navigation.length,
                      itemBuilder: (_, index) {
                        final item = navigation[index];

                        return ListTile(
                          selected: index == selectedIndex,
                          leading: Icon(
                            index == selectedIndex
                                ? item.selectedIcon
                                : item.icon,
                          ),
                          title: Text(item.title),
                          onTap: () {
                            Navigator.pop(context);
                            _select(index);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: _pageForIndex(),
        );
      },
    );
  }
}

class _AdminNavItem {
  final String title;
  final IconData icon;
  final IconData selectedIcon;

  const _AdminNavItem({
    required this.title,
    required this.icon,
    required this.selectedIcon,
  });
}

class _SummaryCard {
  final String title;
  final String value;
  final IconData icon;
  final String description;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.description,
  });
}

class _QuickAction {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAction(this.title, this.icon, this.onTap);
}

class _ServiceTile {
  final String title;
  final String subtitle;
  final IconData icon;
  final int index;

  const _ServiceTile(this.title, this.subtitle, this.icon, this.index);
}

class _SummaryCardWidget extends StatelessWidget {
  final _SummaryCard card;

  const _SummaryCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(card.icon, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    card.value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(card.description, style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
