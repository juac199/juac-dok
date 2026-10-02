import 'package:flutter/material.dart';

import '../services/api_service.dart';

class StudentResultsPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const StudentResultsPage({super.key, required this.user});

  @override
  State<StudentResultsPage> createState() => _StudentResultsPageState();
}

class _StudentResultsPageState extends State<StudentResultsPage> {
  bool _loading = true;
  String? _error;

  List<dynamic> _results = [];
  Map<String, dynamic> _cgpa = {};
  Map<String, dynamic> _performance = {};

  String get token => widget.user['access_token'] as String;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final responses = await Future.wait([
        ApiService.getMyResults(token),
        ApiService.getMyGpa(token),
        ApiService.getMyCgpa(token),
        ApiService.getMyPerformance(token),
      ]);

      if (!mounted) return;

      final results = responses[0] as List<dynamic>;
      final cgpa = responses[2] as Map<String, dynamic>;
      final performance = responses[3] as Map<String, dynamic>;

      setState(() {
        _results = results;
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

  String _text(dynamic source, List<String> keys, [String fallback = '—']) {
    if (source is! Map) return fallback;

    for (final key in keys) {
      final value = source[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  String _number(dynamic source, List<String> keys, [String fallback = '—']) {
    final value = _text(source, keys, fallback);

    if (value == fallback) return fallback;

    final parsed = double.tryParse(value);

    if (parsed == null) return value;

    if (parsed == parsed.roundToDouble()) {
      return parsed.toInt().toString();
    }

    return parsed.toStringAsFixed(2);
  }

  String _cgpaValue() {
    return _number(_cgpa, [
      'cgpa',
      'value',
      'cumulative_gpa',
    ], _number(_performance, ['cgpa'], '—'));
  }

  String _averageMarks() {
    return _number(_performance, ['average_marks', 'average_mark'], '—');
  }

  String _totalCredits() {
    return _number(_performance, ['total_credit_hours', 'credit_hours'], '—');
  }

  String _totalSubjects() {
    return _number(_performance, [
      'total_subjects',
      'subjects_count',
    ], _results.length.toString());
  }

  String _academicStatus() {
    return _text(_performance, ['academic_status', 'status'], '—');
  }

  String _subjectCode(Map<String, dynamic> result) {
    return _text(result, ['subject_code', 'code'], 'SUBJECT');
  }

  String _subjectName(Map<String, dynamic> result) {
    return _text(result, ['subject_name', 'name', 'title'], 'Unnamed Subject');
  }

  String _marks(Map<String, dynamic> result) {
    return _number(result, ['marks', 'mark', 'score'], '—');
  }

  String _grade(Map<String, dynamic> result) {
    return _text(result, ['grade', 'letter_grade'], '—');
  }

  String _gradePoint(Map<String, dynamic> result) {
    return _number(result, ['grade_point', 'points', 'gpa'], '—');
  }

  String _credits(Map<String, dynamic> result) {
    return _number(result, ['credit_hours', 'credits', 'credit'], '—');
  }

  String _semester(Map<String, dynamic> result) {
    return _text(result, ['semester'], '—');
  }

  String _academicYear(Map<String, dynamic> result) {
    return _text(result, ['academic_year'], '—');
  }

  Color _gradeColor(String grade) {
    final normalized = grade.toUpperCase();

    if (normalized == 'A' || normalized == 'A+' || normalized == 'A-') {
      return const Color(0xFF176B4D);
    }

    if (normalized == 'B' || normalized == 'B+' || normalized == 'B-') {
      return const Color(0xFF2457A6);
    }

    if (normalized == 'C' || normalized == 'C+' || normalized == 'C-') {
      return const Color(0xFF8A6200);
    }

    if (normalized == 'D' || normalized == 'D+' || normalized == 'D-') {
      return const Color(0xFF9A5A00);
    }

    if (normalized == 'F') {
      return const Color(0xFFB42318);
    }

    return const Color(0xFF5F6B7A);
  }

  Widget _summaryCard(IconData icon, String title, String value) {
    return Expanded(
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFE3E8F0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFEAF2FF),
                child: Icon(icon, color: const Color(0xFF2457A6), size: 20),
              ),
              const SizedBox(height: 11),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

  Widget _resultCard(Map<String, dynamic> result) {
    final grade = _grade(result);
    final gradeColor = _gradeColor(grade);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE3E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFEAF2FF),
                  child: const Icon(
                    Icons.assignment_rounded,
                    color: Color(0xFF2457A6),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _subjectCode(result),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2457A6),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _subjectName(result),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF102A43),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: gradeColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    grade,
                    style: TextStyle(
                      color: gradeColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoChip(Icons.percent_rounded, 'Marks: ${_marks(result)}'),
                _infoChip(Icons.star_rounded, 'Point: ${_gradePoint(result)}'),
                _infoChip(Icons.school_rounded, 'Credits: ${_credits(result)}'),
                _infoChip(Icons.calendar_month_rounded, _semester(result)),
                _infoChip(Icons.event_rounded, _academicYear(result)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF5F6B7A)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF5F6B7A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _performancePanel() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE3E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Academic Summary',
              style: TextStyle(
                color: Color(0xFF102A43),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 15),
            _summaryRow(
              Icons.trending_up_rounded,
              'Academic Status',
              _academicStatus(),
            ),
            _summaryRow(
              Icons.percent_rounded,
              'Average Marks',
              _averageMarks(),
            ),
            _summaryRow(
              Icons.menu_book_rounded,
              'Total Subjects',
              _totalSubjects(),
            ),
            _summaryRow(
              Icons.schedule_rounded,
              'Credit Hours',
              _totalCredits(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2457A6)),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF102A43),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 60,
                color: Color(0xFF2457A6),
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to Load Results',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF102A43),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _loadResults,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadResults,
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
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 27,
                  backgroundColor: Color(0x33FFFFFF),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 29,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Academic Results',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Track your grades and academic progress',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _summaryCard(
                Icons.workspace_premium_rounded,
                'CGPA',
                _cgpaValue(),
              ),
              const SizedBox(width: 10),
              _summaryCard(
                Icons.menu_book_rounded,
                'Subjects',
                _totalSubjects(),
              ),
              const SizedBox(width: 10),
              _summaryCard(Icons.schedule_rounded, 'Credits', _totalCredits()),
            ],
          ),
          const SizedBox(height: 22),
          _performancePanel(),
          const SizedBox(height: 28),
          const Text(
            'Subject Results',
            style: TextStyle(
              color: Color(0xFF102A43),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your published academic results',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
          const SizedBox(height: 12),
          if (_results.isEmpty)
            Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFFE3E8F0)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(26),
                child: Column(
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 46,
                      color: Color(0xFF8A94A6),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No results available yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._results.map(
              (item) => _resultCard(Map<String, dynamic>.from(item as Map)),
            ),
          const SizedBox(height: 30),
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
          'Results',
          style: TextStyle(
            color: Color(0xFF102A43),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadResults,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF102A43)),
          ),
        ],
      ),
      body: _content(),
    );
  }
}
