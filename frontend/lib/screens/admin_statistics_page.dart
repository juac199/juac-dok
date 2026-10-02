import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AdminStatisticsPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminStatisticsPage({super.key, required this.user});

  @override
  State<AdminStatisticsPage> createState() => _AdminStatisticsPageState();
}

class _AdminStatisticsPageState extends State<AdminStatisticsPage> {
  bool isLoading = true;
  String? errorMessage;

  int totalStudents = 0;
  int totalLecturers = 0;
  int totalSubjects = 0;
  int activeSubjects = 0;
  int inactiveSubjects = 0;

  int totalEnrollments = 0;
  int enrolledCount = 0;
  int completedCount = 0;
  int droppedCount = 0;

  int totalResults = 0;
  int publishedResults = 0;
  int draftResults = 0;

  double averageMarks = 0.0;

  DateTime? lastUpdated;

  String get token => widget.user['access_token'] as String;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await Future.wait([
        ApiService.getStudents(token),
        ApiService.getAdminLecturers(token),
        ApiService.getSubjects(token),
        ApiService.getAdminEnrollments(token),
        ApiService.getAdminResults(token),
      ]);

      final students = List<dynamic>.from(data[0]);
      final lecturers = List<dynamic>.from(data[1]);
      final subjects = List<dynamic>.from(data[2]);
      final enrollments = List<dynamic>.from(data[3]);
      final results = List<dynamic>.from(data[4]);

      int countStatus(List<dynamic> items, String key, String value) {
        return items.where((item) {
          if (item is! Map) return false;

          return item[key]?.toString().toLowerCase().trim() ==
              value.toLowerCase().trim();
        }).length;
      }

      final marks = results
          .map((item) {
            if (item is! Map) return null;
            return double.tryParse(item['marks']?.toString() ?? '');
          })
          .whereType<double>()
          .toList();

      final calculatedAverage = marks.isEmpty
          ? 0.0
          : marks.reduce((a, b) => a + b) / marks.length;

      if (!mounted) return;

      setState(() {
        totalStudents = students.length;
        totalLecturers = lecturers.length;
        totalSubjects = subjects.length;

        activeSubjects = countStatus(subjects, 'status', 'active');

        inactiveSubjects = countStatus(subjects, 'status', 'inactive');

        totalEnrollments = enrollments.length;

        enrolledCount = countStatus(enrollments, 'status', 'enrolled');

        completedCount = countStatus(enrollments, 'status', 'completed');

        droppedCount = countStatus(enrollments, 'status', 'dropped');

        totalResults = results.length;

        publishedResults = countStatus(results, 'status', 'published');

        draftResults = countStatus(results, 'status', 'draft');

        averageMarks = calculatedAverage;

        lastUpdated = DateTime.now();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  String _formatAverage(double value) {
    return value.toStringAsFixed(2);
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required String description,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(radius: 25, child: Icon(icon)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.dashboard_customize_outlined, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'System Overview',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Current statistics across the Student Management System.',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          _sectionTitle('Users', Icons.people_outline),

          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 800 ? 3 : 1;

              return GridView.count(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 3 ? 2.3 : 2.8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _statCard(
                    title: 'Students',
                    value: '$totalStudents',
                    icon: Icons.school_outlined,
                    description: 'Registered students',
                  ),
                  _statCard(
                    title: 'Lecturers',
                    value: '$totalLecturers',
                    icon: Icons.person_outline,
                    description: 'Registered lecturers',
                  ),
                  _statCard(
                    title: 'Subjects',
                    value: '$totalSubjects',
                    icon: Icons.menu_book_outlined,
                    description: 'Total subjects',
                  ),
                ],
              );
            },
          ),

          _sectionTitle('Subjects', Icons.library_books_outlined),

          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 800 ? 2 : 1;

              return GridView.count(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 2 ? 2.5 : 2.8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _statCard(
                    title: 'Active Subjects',
                    value: '$activeSubjects',
                    icon: Icons.check_circle_outline,
                    description: 'Currently active',
                  ),
                  _statCard(
                    title: 'Inactive Subjects',
                    value: '$inactiveSubjects',
                    icon: Icons.pause_circle_outline,
                    description: 'Currently inactive',
                  ),
                ],
              );
            },
          ),

          _sectionTitle('Enrollments', Icons.how_to_reg_outlined),

          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 800 ? 4 : 2;

              return GridView.count(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _statCard(
                    title: 'Total',
                    value: '$totalEnrollments',
                    icon: Icons.assignment_outlined,
                    description: 'All enrollments',
                  ),
                  _statCard(
                    title: 'Enrolled',
                    value: '$enrolledCount',
                    icon: Icons.check_circle_outline,
                    description: 'Active enrollments',
                  ),
                  _statCard(
                    title: 'Completed',
                    value: '$completedCount',
                    icon: Icons.task_alt_outlined,
                    description: 'Completed subjects',
                  ),
                  _statCard(
                    title: 'Dropped',
                    value: '$droppedCount',
                    icon: Icons.remove_circle_outline,
                    description: 'Dropped enrollments',
                  ),
                ],
              );
            },
          ),

          _sectionTitle('Results', Icons.assessment_outlined),

          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 800 ? 3 : 1;

              return GridView.count(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 3 ? 2.3 : 2.8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _statCard(
                    title: 'Total Results',
                    value: '$totalResults',
                    icon: Icons.assessment_outlined,
                    description: 'All recorded results',
                  ),
                  _statCard(
                    title: 'Published',
                    value: '$publishedResults',
                    icon: Icons.public_outlined,
                    description: 'Visible to students',
                  ),
                  _statCard(
                    title: 'Draft',
                    value: '$draftResults',
                    icon: Icons.edit_note_outlined,
                    description: 'Waiting for publication',
                  ),
                ],
              );
            },
          ),

          _sectionTitle('Academic Summary', Icons.school_outlined),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Text(
                      _formatAverage(averageMarks),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Average Marks',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          totalResults == 0
                              ? 'No results available yet'
                              : 'Average across all recorded results',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Center(
                child: Text(
                  'Last updated: '
                  '${lastUpdated!.hour.toString().padLeft(2, '0')}:'
                  '${lastUpdated!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Statistics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: isLoading ? null : _loadStatistics,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh statistics',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 56),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load statistics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _loadStatistics,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          : _buildStatistics(),
    );
  }
}
