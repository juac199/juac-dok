import 'package:flutter/material.dart';

import '../services/api_service.dart';

class StudentResultsPage extends StatefulWidget {
  final String token;

  const StudentResultsPage({
    super.key,
    required this.token,
  });

  @override
  State<StudentResultsPage> createState() => _StudentResultsPageState();
}

class _StudentResultsPageState extends State<StudentResultsPage> {
  List<dynamic> results = [];
  List<dynamic> gpaData = [];

  double cgpa = 0.0;
  int totalCreditHours = 0;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadResults();
  }

  Future<void> loadResults() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final resultsData =
          await ApiService.getMyResults(widget.token);

      final gpaResult =
          await ApiService.getMyGpa(widget.token);

      final cgpaResult =
          await ApiService.getMyCgpa(widget.token);

      if (!mounted) return;

      setState(() {
        results = resultsData;
        gpaData = gpaResult;

        cgpa =
            (cgpaResult['cgpa'] as num?)?.toDouble() ?? 0.0;

        totalCreditHours =
            (cgpaResult['total_credit_hours'] as num?)?.toInt() ?? 0;

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

  double getGpaForResult(dynamic result) {
    final semester =
        result['semester']?.toString() ?? '';

    final academicYear =
        result['academic_year']?.toString() ?? '';

    for (final gpa in gpaData) {
      if (gpa['semester']?.toString() == semester &&
          gpa['academic_year']?.toString() == academicYear) {
        return (gpa['gpa'] as num?)?.toDouble() ?? 0.0;
      }
    }

    return 0.0;
  }

  List<dynamic> getSemesterResults(
    String semester,
    String academicYear,
  ) {
    return results.where((result) {
      return result['semester']?.toString() == semester &&
          result['academic_year']?.toString() == academicYear;
    }).toList();
  }

  List<Map<String, String>> getSemesterGroups() {
    final groups = <Map<String, String>>[];

    for (final result in results) {
      final semester =
          result['semester']?.toString() ?? '';

      final academicYear =
          result['academic_year']?.toString() ?? '';

      final exists = groups.any(
        (group) =>
            group['semester'] == semester &&
            group['academic_year'] == academicYear,
      );

      if (!exists) {
        groups.add({
          'semester': semester,
          'academic_year': academicYear,
        });
      }
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Academic Results',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadResults,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load academic results',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: loadResults,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadResults,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Icon(
              Icons.school_outlined,
              size: 70,
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'No published results yet.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Your academic results will appear here.',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadResults,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _buildCgpaCard(),
          const SizedBox(height: 24),
          ..._buildSemesterSections(),
        ],
      ),
    );
  }

  Widget _buildCgpaCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.school,
              size: 42,
            ),
            const SizedBox(height: 10),
            const Text(
              'Cumulative GPA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              cgpa.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$totalCreditHours Credit Hours',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSemesterSections() {
    final sections = <Widget>[];

    final groups = getSemesterGroups();

    for (final group in groups) {
      final semester =
          group['semester'] ?? '';

      final academicYear =
          group['academic_year'] ?? '';

      final semesterResults =
          getSemesterResults(
        semester,
        academicYear,
      );

      final semesterGpa =
          semesterResults.isNotEmpty
              ? getGpaForResult(
                  semesterResults.first,
                )
              : 0.0;

      sections.add(
        _buildSemesterCard(
          semester: semester,
          academicYear: academicYear,
          results: semesterResults,
          gpa: semesterGpa,
        ),
      );

      sections.add(
        const SizedBox(height: 20),
      );
    }

    return sections;
  }

  Widget _buildSemesterCard({
    required String semester,
    required String academicYear,
    required List<dynamic> results,
    required double gpa,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$semester • $academicYear',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...results.map(
              (result) =>
                  _buildResultItem(result),
            ),
            const Divider(height: 28),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Semester GPA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  gpa.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(dynamic result) {
    final subjectCode =
        result['subject_code']?.toString() ??
            'N/A';

    final subjectName =
        result['subject_name']?.toString() ??
            'Unknown Subject';

    final marks =
        (result['marks'] as num?)
                ?.toDouble() ??
            0.0;

    final grade =
        result['grade']?.toString() ??
            'N/A';

    final gradePoint =
        (result['grade_point'] as num?)
                ?.toDouble() ??
            0.0;

    final creditHours =
        (result['credit_hours'] as num?)
                ?.toInt() ??
            0;

    return Container(
      margin:
          const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),
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
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$creditHours Credit Hours',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildResultValue(
                  'Marks',
                  marks.toStringAsFixed(1),
                ),
              ),
              Expanded(
                child: _buildResultValue(
                  'Grade',
                  grade,
                ),
              ),
              Expanded(
                child: _buildResultValue(
                  'Point',
                  gradePoint.toStringAsFixed(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultValue(
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}