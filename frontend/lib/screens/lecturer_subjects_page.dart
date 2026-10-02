import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';

class LecturerSubjectsPage extends StatefulWidget {
  final String token;

  const LecturerSubjectsPage({super.key, required this.token});

  @override
  State<LecturerSubjectsPage> createState() => _LecturerSubjectsPageState();
}

class _LecturerSubjectsPageState extends State<LecturerSubjectsPage> {
  late Future<List<dynamic>> _subjectsFuture;

  @override
  void initState() {
    super.initState();

    _subjectsFuture = ApiService.getMyLecturerSubjects(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Subjects'), centerTitle: true),
      body: FutureBuilder<List<dynamic>>(
        future: _subjectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _subjectsFuture = ApiService.getMyLecturerSubjects(
                  widget.token,
                );
              });

              await _subjectsFuture;
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 14),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(18),
                    leading: CircleAvatar(
                      radius: 28,
                      child: Text(
                        '${subject['id'] ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
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
