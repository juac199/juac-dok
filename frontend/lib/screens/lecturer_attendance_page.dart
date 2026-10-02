import 'package:flutter/material.dart';

import '../services/api_service.dart';

class LecturerAttendancePage extends StatefulWidget {
  final String token;

  const LecturerAttendancePage({super.key, required this.token});

  @override
  State<LecturerAttendancePage> createState() => _LecturerAttendancePageState();
}

class _LecturerAttendancePageState extends State<LecturerAttendancePage> {
  late Future<List<dynamic>> _subjectsFuture;

  @override
  void initState() {
    super.initState();

    _subjectsFuture = ApiService.getMyLecturerSubjects(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance'), centerTitle: true),
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];

              debugPrint('ATTENDANCE SUBJECT DATA: $subject');

              final dynamic rawSubjectId =
                  subject['id'] ??
                  subject['subject_id'] ??
                  subject['course_id'];

              final int? subjectId = rawSubjectId is int
                  ? rawSubjectId
                  : int.tryParse(rawSubjectId?.toString() ?? '');

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 14),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(18),
                  leading: const CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.fact_check),
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
                  onTap: () {
                    if (subjectId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Subject ID not found.')),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubjectAttendancePage(
                          token: widget.token,
                          subjectId: subjectId,
                          subjectName:
                              subject['course_name'] ??
                              subject['subject_name'] ??
                              'Attendance',
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

class SubjectAttendancePage extends StatefulWidget {
  final String token;
  final int subjectId;
  final String subjectName;

  const SubjectAttendancePage({
    super.key,
    required this.token,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<SubjectAttendancePage> createState() => _SubjectAttendancePageState();
}

class _SubjectAttendancePageState extends State<SubjectAttendancePage> {
  late Future<List<dynamic>> _studentsFuture;

  DateTime _selectedDate = DateTime.now();

  int? _selectedStudentId;

  bool _isPresent = true;

  bool _isSaving = false;

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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String get _formattedDate {
    final year = _selectedDate.year.toString().padLeft(4, '0');

    final month = _selectedDate.month.toString().padLeft(2, '0');

    final day = _selectedDate.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<void> _markAttendance() async {
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a student first.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ApiService.markLecturerAttendance(widget.token, {
        'subject_id': widget.subjectId,
        'student_id': _selectedStudentId,
        'attendance_date': _formattedDate,
        'status': _isPresent ? 'present' : 'absent',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance recorded successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to record attendance.\n$e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.subjectName), centerTitle: true),
      body: FutureBuilder<List<dynamic>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Attendance Date',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _selectDate,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(_formattedDate),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Student',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            initialValue: _selectedStudentId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Student',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            items: students.map((student) {
                              final dynamic rawStudentId =
                                  student['student_id'] ?? student['id'];

                              final int? studentId = rawStudentId is int
                                  ? rawStudentId
                                  : int.tryParse(
                                      rawStudentId?.toString() ?? '',
                                    );

                              return DropdownMenuItem<int>(
                                value: studentId,
                                child: Text(
                                  '${student['student_number'] ?? 'N/A'} - '
                                  '${student['full_name'] ?? 'Unknown Student'}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStudentId = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Attendance Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RadioGroup<bool>(
                            groupValue: _isPresent,
                            onChanged: (value) {
                              setState(() {
                                _isPresent = value ?? true;
                              });
                            },
                            child: const Column(
                              children: [
                                RadioListTile<bool>(
                                  title: Text('Present'),
                                  value: true,
                                ),
                                RadioListTile<bool>(
                                  title: Text('Absent'),
                                  value: false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _markAttendance,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isSaving ? 'Saving...' : 'Save Attendance'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
