import 'package:flutter/material.dart';

import '../services/api_service.dart';

class StudentPerformancePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const StudentPerformancePage({super.key, required this.user});

  @override
  State<StudentPerformancePage> createState() => _StudentPerformancePageState();
}

class _StudentPerformancePageState extends State<StudentPerformancePage> {
  bool _loading = true;
  String? _error;

  Map<String, dynamic> _cgpa = {};
  Map<String, dynamic> _performance = {};

  String get token => widget.user['access_token'] as String;

  @override
  void initState() {
    super.initState();
    _loadPerformance();
  }

  Future<void> _loadPerformance() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final responses = await Future.wait([
        ApiService.getMyCgpa(token),
        ApiService.getMyPerformance(token),
      ]);

      final cgpa = responses[0];
      final performance = responses[1];

      if (!mounted) return;

      setState(() {
        _cgpa = cgpa;
        _performance = performance;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  double _number(String key) {
    final value = _performance[key] ?? _cgpa[key];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }

  int _integer(String key) {
    final value = _performance[key] ?? _cgpa[key];

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  String _text(String key) {
    final value = _performance[key] ?? _cgpa[key];
    return value?.toString() ?? '-';
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();

    if (normalized.contains('good') ||
        normalized.contains('excellent') ||
        normalized.contains('pass') ||
        normalized.contains('active')) {
      return Colors.green;
    }

    if (normalized.contains('warning') || normalized.contains('probation')) {
      return Colors.orange;
    }

    if (normalized.contains('fail') || normalized.contains('inactive')) {
      return Colors.red;
    }

    return const Color(0xFF2F6DB2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Academic Performance',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF14213D),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPerformance,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildError()
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final cgpa = _number('cgpa');
    final academicStatus = _text('academic_status');

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        _buildCgpaCard(cgpa),
        const SizedBox(height: 24),
        const Text(
          'Academic Overview',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF14213D),
          ),
        ),
        const SizedBox(height: 12),
        _buildStatisticsGrid(),
        const SizedBox(height: 24),
        _buildAcademicStatus(academicStatus),
        const SizedBox(height: 24),
        _buildPerformanceDetails(),
      ],
    );
  }

  Widget _buildCgpaCard(double cgpa) {
    final progress = (cgpa / 4.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF173B72), Color(0xFF2F6DB2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 94,
                  height: 94,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 9,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cgpa.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'CGPA',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cumulative GPA',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Academic Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your cumulative academic performance across completed subjects.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _statCard(
          'Subjects',
          _integer('total_subjects').toString(),
          Icons.menu_book_rounded,
        ),
        _statCard(
          'Credit Hours',
          _integer('total_credit_hours').toString(),
          Icons.school_rounded,
        ),
        _statCard(
          'Passed',
          _integer('passed_subjects').toString(),
          Icons.check_circle_rounded,
        ),
        _statCard(
          'Failed',
          _integer('failed_subjects').toString(),
          Icons.cancel_rounded,
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2F6DB2).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: const Color(0xFF2F6DB2), size: 23),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF14213D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicStatus(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.verified_rounded, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Academic Status',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceDetails() {
    final averageMarks = _number('average_marks');
    final totalSubjects = _integer('total_subjects');
    final passed = _integer('passed_subjects');

    final passRate = totalSubjects == 0 ? 0.0 : (passed / totalSubjects) * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Details',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF14213D),
            ),
          ),
          const SizedBox(height: 16),
          _detailRow('Average Marks', '${averageMarks.toStringAsFixed(2)}%'),
          _detailRow('Pass Rate', '${passRate.toStringAsFixed(1)}%'),
          _detailRow('Total Subjects', totalSubjects.toString()),
          _detailRow(
            'Completed Credits',
            _integer('total_credit_hours').toString(),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF14213D),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.cloud_off_rounded, size: 58, color: Colors.black26),
        const SizedBox(height: 18),
        const Text(
          'Unable to load performance',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF14213D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _error ?? 'Something went wrong.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 20),
        Center(
          child: FilledButton.icon(
            onPressed: _loadPerformance,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ),
      ],
    );
  }
}
