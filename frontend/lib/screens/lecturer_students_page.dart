import 'package:flutter/material.dart';
import '../services/api_service.dart';


class LecturerStudentsPage extends StatefulWidget {
  final String token;

  const LecturerStudentsPage({
    super.key,
    required this.token,
  });

  @override
  State<LecturerStudentsPage> createState() =>
      _LecturerStudentsPageState();
}

class _LecturerStudentsPageState
    extends State<LecturerStudentsPage> {
  late Future<List<dynamic>> _subjectsFuture;

  @override
  void initState() {
    super.initState();
    _subjectsFuture =
        ApiService.getMyLecturerSubjects(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _subjectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load subjects.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final subjects = snapshot.data ?? [];

          if (subjects.isEmpty) {
            return const Center(
              child: Text(
                'No subjects assigned.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];

              final subjectId = subject['id'];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 14),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(18),
                  leading: const CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.menu_book),
                  ),
                  title: Text(
                    subject['course_code'] ??
                        subject['subject_code'] ??
                        'Unknown Code',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      subject['course_name'] ??
                          subject['subject_name'] ??
                          'Unknown Subject',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {
                    if (subjectId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Subject ID not found.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SubjectStudentsPage(
                          token: widget.token,
                          subjectId: subjectId,
                          subjectName:
                              subject['course_name'] ??
                              subject['subject_name'] ??
                              'Students',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SubjectStudentsPage extends StatefulWidget {
  final String token;
  final int subjectId;
  final String subjectName;

  const SubjectStudentsPage({
    super.key,
    required this.token,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<SubjectStudentsPage> createState() =>
      _SubjectStudentsPageState();
}

class _SubjectStudentsPageState
    extends State<SubjectStudentsPage> {
  late Future<List<dynamic>> _studentsFuture;

  @override
  void initState() {
    super.initState();

    _studentsFuture = ApiService.getMySubjectStudents(
      widget.token,
      widget.subjectId,
    );
  }

  Future<void> _refreshStudents() async {
    setState(() {
      _studentsFuture = ApiService.getMySubjectStudents(
        widget.token,
        widget.subjectId,
      );
    });

    await _studentsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectName),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load students.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final students = snapshot.data ?? [];

          if (students.isEmpty) {
            return const Center(
              child: Text(
                'No students enrolled in this subject.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshStudents,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      student['full_name'] ?? 'Unknown Student',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Student Number: '
                            '${student['student_number'] ?? 'N/A'}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Email: '
                            '${student['email'] ?? 'N/A'}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Program: '
                            '${student['program'] ?? 'N/A'}',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}