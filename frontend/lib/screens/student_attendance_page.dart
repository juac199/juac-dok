import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';

class StudentAttendancePage extends StatefulWidget {
  final String token;

  const StudentAttendancePage({
    super.key,
    required this.token,
  });

  @override
  State<StudentAttendancePage> createState() =>
      _StudentAttendancePageState();
}

class _StudentAttendancePageState
    extends State<StudentAttendancePage> {
  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic> summary = {};
  List<dynamic> attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final attendance =
          await ApiService.getMyAttendance(widget.token);

      final attendanceSummary =
          await ApiService.getMyAttendanceSummary(widget.token);

      if (!mounted) return;

      setState(() {
        attendanceRecords = attendance;
        summary = attendanceSummary;
        isLoading = false;
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

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      case 'late':
        return Icons.access_time;
      default:
        return Icons.help_outline;
    }
  }

  String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);

      return '${parsedDate.day.toString().padLeft(2, '0')}/'
          '${parsedDate.month.toString().padLeft(2, '0')}/'
          '${parsedDate.year}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Attendance',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadAttendance,
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
              ? buildErrorState()
              : buildAttendancePage(),
    );
  }

  Widget buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load attendance',
              style: TextStyle(
                fontSize: 20,
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
              onPressed: loadAttendance,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAttendancePage() {
    final double percentage =
        (summary['attendance_percentage'] ?? 0).toDouble();

    final int totalClasses =
        summary['total_classes'] ?? 0;

    final int presentClasses =
        summary['present_classes'] ?? 0;

    final int absentClasses =
        summary['absent_classes'] ?? 0;

    final int lateClasses =
        summary['late_classes'] ?? 0;

    return RefreshIndicator(
      onRefresh: loadAttendance,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildAttendanceOverview(
            percentage,
            totalClasses,
          ),

          const SizedBox(height: 20),

          buildStatistics(
            totalClasses,
            presentClasses,
            absentClasses,
            lateClasses,
          ),

          const SizedBox(height: 28),

          const Text(
            'Attendance Records',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          if (attendanceRecords.isEmpty)
            buildEmptyState()
          else
            ...attendanceRecords.map(
              (record) => buildAttendanceRecord(record),
            ),
        ],
      ),
    );
  }

  Widget buildAttendanceOverview(
    double percentage,
    int totalClasses,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Overall Attendance',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value:
                          (percentage / 100).clamp(0.0, 1.0),
                      strokeWidth: 12,
                      backgroundColor:
                          Colors.grey.shade200,
                    ),
                  ),

                  Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$totalClasses classes',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              getAttendanceMessage(percentage),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getAttendanceMessage(double percentage) {
    if (percentage >= 90) {
      return 'Excellent attendance. Keep it up!';
    }

    if (percentage >= 80) {
      return 'Good attendance. Keep attending regularly.';
    }

    if (percentage >= 75) {
      return 'Your attendance is acceptable.';
    }

    return 'Your attendance is below the recommended level.';
  }

  Widget buildStatistics(
    int total,
    int present,
    int absent,
    int late,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: [
        buildStatisticCard(
          'Total Classes',
          total.toString(),
          Icons.school,
          Colors.blue,
        ),
        buildStatisticCard(
          'Present',
          present.toString(),
          Icons.check_circle,
          Colors.green,
        ),
        buildStatisticCard(
          'Absent',
          absent.toString(),
          Icons.cancel,
          Colors.red,
        ),
        buildStatisticCard(
          'Late',
          late.toString(),
          Icons.access_time,
          Colors.orange,
        ),
      ],
    );
  }

  Widget buildStatisticCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 30,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
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

  Widget buildAttendanceRecord(dynamic record) {
    final String status =
        (record['status'] ?? 'unknown').toString();

    final String subjectCode =
        (record['subject_code'] ?? 'Unknown').toString();

    final String subjectName =
        (record['subject_name'] ?? 'Unknown Subject')
            .toString();

    final String date =
        (record['attendance_date'] ?? '').toString();

    final String remarks =
        (record['remarks'] ?? '').toString();

    final Color statusColor =
        getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    statusColor.withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Icon(
                getStatusIcon(status),
                color: statusColor,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectCode,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subjectName,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formatDate(date),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  if (remarks.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      remarks,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color:
                    statusColor.withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.event_busy,
              size: 60,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 16),

            const Text(
              'No attendance records yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Your attendance records will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}