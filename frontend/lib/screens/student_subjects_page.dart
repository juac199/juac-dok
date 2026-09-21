import 'package:flutter/material.dart';

import '../services/api_service.dart';

class StudentSubjectsPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const StudentSubjectsPage({
    super.key,
    required this.user,
  });

  @override
  State<StudentSubjectsPage> createState() =>
      _StudentSubjectsPageState();
}

class _StudentSubjectsPageState
    extends State<StudentSubjectsPage> {
  late final String _token;

  List<dynamic> _subjects = [];
  List<dynamic> _availableSubjects = [];

  bool _isLoading = true;
  bool _isRegistering = false;

  String _semester = 'Semester 1';
  String _academicYear = '2026/2027';

  @override
  void initState() {
    super.initState();

    _token = widget.user['access_token'] ?? '';

    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final subjects =
          await ApiService.getMySubjects(_token);

      final available =
          await ApiService.getAvailableSubjects(_token);

      if (!mounted) return;

      setState(() {
        _subjects = subjects;
        _availableSubjects = available;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _registerSubject(
    Map<String, dynamic> subject,
  ) async {
    if (_isRegistering) return;

    setState(() {
      _isRegistering = true;
    });

    try {
      await ApiService.registerSubject(
        _token,
        subject['id'],
        _semester,
        _academicYear,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${subject['subject_code']} registered successfully.',
          ),
        ),
      );

      await _loadSubjects();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  Future<void> _dropSubject(
    Map<String, dynamic> subject,
  ) async {
    final registrationId = subject['registration_id'];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Drop Subject'),
          content: Text(
            'Are you sure you want to drop '
            '${subject['subject_code']} - '
            '${subject['subject_name']}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Drop'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await ApiService.dropSubject(
        _token,
        registrationId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${subject['subject_code']} dropped successfully.',
          ),
        ),
      );

      await _loadSubjects();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  void _showRegisterSubjectDialog() {
    if (_availableSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No subjects are currently available.',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Register Subject'),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _semester,
                        decoration: const InputDecoration(
                          labelText: 'Semester',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Semester 1',
                            child: Text('Semester 1'),
                          ),
                          DropdownMenuItem(
                            value: 'Semester 2',
                            child: Text('Semester 2'),
                          ),
                          DropdownMenuItem(
                            value: 'Semester 3',
                            child: Text('Semester 3'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;

                          setDialogState(() {
                            _semester = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _academicYear,
                        decoration: const InputDecoration(
                          labelText: 'Academic Year',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: '2026/2027',
                            child: Text('2026/2027'),
                          ),
                          DropdownMenuItem(
                            value: '2027/2028',
                            child: Text('2027/2028'),
                          ),
                          DropdownMenuItem(
                            value: '2028/2029',
                            child: Text('2028/2029'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;

                          setDialogState(() {
                            _academicYear = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Available Subjects',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._availableSubjects.map(
                        (subject) {
                          return Card(
                            margin: const EdgeInsets.only(
                              bottom: 8,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  '${subject['credit_hours']}',
                                ),
                              ),
                              title: Text(
                                subject['subject_code'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                subject['subject_name'],
                              ),
                              trailing: FilledButton(
                                onPressed: _isRegistering
                                    ? null
                                    : () {
                                        _registerSubject(
                                          subject,
                                        );
                                      },
                                child: _isRegistering
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Register'),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  int get _totalCredits {
    int total = 0;

    for (final subject in _subjects) {
      total +=
          int.tryParse(
            subject['credit_hours'].toString(),
          ) ??
          0;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Subjects',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadSubjects,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSubjects,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _subjects.isEmpty
                ? ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 150),
                      Icon(
                        Icons.menu_book_outlined,
                        size: 72,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: Text(
                          'No subjects registered',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Register a subject to get started.',
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 28,
                                child: Icon(
                                  Icons.school_outlined,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.user['full_name'] ??
                                          'Student',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_subjects.length} subject(s) • '
                                      '$_totalCredits credit hours',
                                      style: TextStyle(
                                        color:
                                            Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._subjects.map(
                        (subject) {
                          return Card(
                            margin: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    child: Text(
                                      '${subject['credit_hours']}',
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          subject['subject_code'] ??
                                              '',
                                          style:
                                              const TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          subject['subject_name'] ??
                                              '',
                                          style:
                                              const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 6,
                                          children: [
                                            Chip(
                                              label: Text(
                                                subject[
                                                        'semester'] ??
                                                    '',
                                              ),
                                            ),
                                            Chip(
                                              label: Text(
                                                subject[
                                                        'academic_year'] ??
                                                    '',
                                              ),
                                            ),
                                            Chip(
                                              label: Text(
                                                subject[
                                                        'status'] ??
                                                    '',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      _dropSubject(subject);
                                    },
                                    tooltip: 'Drop subject',
                                    icon: const Icon(
                                      Icons.delete_outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRegisterSubjectDialog,
        icon: const Icon(Icons.add),
        label: const Text('Register Subject'),
      ),
    );
  }
}