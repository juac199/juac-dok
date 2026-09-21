import 'package:flutter/material.dart';

import '../services/api_service.dart';

class StudentPerformancePage extends StatefulWidget {
  final String token;

  const StudentPerformancePage({
    super.key,
    required this.token,
  });

  @override
  State<StudentPerformancePage> createState() =>
      _StudentPerformancePageState();
}

class _StudentPerformancePageState
    extends State<StudentPerformancePage> {
  Map<String, dynamic>? performance;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadPerformance();
  }

  Future<void> loadPerformance() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await ApiService.getMyPerformance(
        widget.token,
      );

      if (!mounted) return;

      setState(() {
        performance = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String getValue(String key) {
    if (performance == null) {
      return '0';
    }

    return performance![key]?.toString() ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Academic Performance',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadPerformance,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
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
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Unable to load academic performance',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: loadPerformance,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadPerformance,
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Academic Overview',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Track your academic progress and overall performance.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 24),

                        _buildCgpaCard(),

                        const SizedBox(height: 20),

                        GridView.count(
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 700
                                  ? 4
                                  : 2,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.25,
                          children: [
                            _buildStatCard(
                              icon: Icons.menu_book_outlined,
                              title: 'Subjects',
                              value: getValue('total_subjects'),
                            ),
                            _buildStatCard(
                              icon: Icons.check_circle_outline,
                              title: 'Passed',
                              value: getValue('passed_subjects'),
                            ),
                            _buildStatCard(
                              icon: Icons.cancel_outlined,
                              title: 'Failed',
                              value: getValue('failed_subjects'),
                            ),
                            _buildStatCard(
                              icon: Icons.percent_outlined,
                              title: 'Average Marks',
                              value: getValue('average_marks'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        _buildStatusCard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildCgpaCard() {
    final cgpa = performance?['cgpa']?.toString() ?? '0.00';
    final creditHours =
        performance?['total_credit_hours']?.toString() ?? '0';

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
              ),
              child: Icon(
                Icons.school_outlined,
                size: 36,
                color: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer,
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cumulative GPA',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cgpa,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$creditHours total credit hours',
                    style: const TextStyle(
                      color: Colors.grey,
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

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final status =
        performance?['academic_status']?.toString() ??
            'Unknown';

    IconData icon;

    if (status == 'Excellent') {
      icon = Icons.emoji_events_outlined;
    } else if (status == 'Good') {
      icon = Icons.thumb_up_outlined;
    } else if (status == 'At Risk') {
      icon = Icons.warning_amber_outlined;
    } else {
      icon = Icons.info_outline;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Academic Status',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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
}
