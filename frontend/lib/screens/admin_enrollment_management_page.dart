import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AdminEnrollmentManagementPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminEnrollmentManagementPage({super.key, required this.user});

  @override
  State<AdminEnrollmentManagementPage> createState() =>
      _AdminEnrollmentManagementPageState();
}

class _AdminEnrollmentManagementPageState
    extends State<AdminEnrollmentManagementPage> {
  List<dynamic> _enrollments = [];
  List<dynamic> _students = [];
  List<dynamic> _subjects = [];

  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = widget.user['access_token'] as String;

      final results = await Future.wait([
        ApiService.getAdminEnrollments(token),
        ApiService.getStudents(token),
        ApiService.getSubjects(token),
      ]);

      if (!mounted) return;

      setState(() {
        _enrollments = results[0];
        _students = results[1];
        _subjects = results[2];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  List<dynamic> get _filteredEnrollments {
    if (_searchQuery.trim().isEmpty) {
      return _enrollments;
    }

    final query = _searchQuery.toLowerCase().trim();

    return _enrollments.where((enrollment) {
      final studentName = (enrollment['student_name'] ?? '')
          .toString()
          .toLowerCase();
      final studentNumber = (enrollment['student_number'] ?? '')
          .toString()
          .toLowerCase();
      final studentEmail = (enrollment['student_email'] ?? '')
          .toString()
          .toLowerCase();
      final subjectCode = (enrollment['subject_code'] ?? '')
          .toString()
          .toLowerCase();
      final subjectName = (enrollment['subject_name'] ?? '')
          .toString()
          .toLowerCase();

      return studentName.contains(query) ||
          studentNumber.contains(query) ||
          studentEmail.contains(query) ||
          subjectCode.contains(query) ||
          subjectName.contains(query);
    }).toList();
  }

  Future<void> _showAddEnrollmentDialog() async {
    if (_students.isEmpty || _subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Students and subjects are required before creating an enrollment.',
          ),
        ),
      );
      return;
    }

    int? selectedStudentId;
    int? selectedSubjectId;
    String selectedSemester = 'Semester 1';

    final academicYearController = TextEditingController(text: '2026/2027');

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Enrollment'),
              content: SizedBox(
                width: 450,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<int>(
                          initialValue: selectedStudentId,
                          decoration: const InputDecoration(
                            labelText: 'Student',
                            border: OutlineInputBorder(),
                          ),
                          items: _students.map((student) {
                            final id = student['id'] as int;
                            final studentNumber =
                                (student['student_number'] ?? '').toString();
                            final name = (student['full_name'] ?? '')
                                .toString();

                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(
                                '$studentNumber - $name',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedStudentId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a student';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          initialValue: selectedSubjectId,
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                            border: OutlineInputBorder(),
                          ),
                          items: _subjects.map((subject) {
                            final id = subject['id'] as int;
                            final code = (subject['subject_code'] ?? '')
                                .toString();
                            final name = (subject['subject_name'] ?? '')
                                .toString();

                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(
                                '$code - $name',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedSubjectId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a subject';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: selectedSemester,
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
                              value: 'Summer',
                              child: Text('Summer'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            setDialogState(() {
                              selectedSemester = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: academicYearController,
                          decoration: const InputDecoration(
                            labelText: 'Academic Year',
                            hintText: 'e.g. 2026/2027',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the academic year';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Enroll'),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    try {
                      final token = widget.user['access_token'] as String;

                      await ApiService.createEnrollment(token, {
                        'student_id': selectedStudentId,
                        'subject_id': selectedSubjectId,
                        'semester': selectedSemester,
                        'academic_year': academicYearController.text.trim(),
                      });

                      if (!dialogContext.mounted) return;

                      Navigator.pop(dialogContext, true);
                    } catch (e) {
                      if (!dialogContext.mounted) return;

                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            e.toString().replaceFirst('Exception: ', ''),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );

    academicYearController.dispose();

    if (result == true && mounted) {
      await _loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student enrolled successfully.')),
      );
    }
  }

  Future<void> _removeEnrollment(Map<String, dynamic> enrollment) async {
    final enrollmentId = enrollment['enrollment_id'] as int;

    final studentName = (enrollment['student_name'] ?? 'Student').toString();

    final subjectCode = (enrollment['subject_code'] ?? 'Subject').toString();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove Enrollment'),
          content: Text(
            'Remove $studentName from $subjectCode?\n\n'
            'This will mark the enrollment as dropped.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      final token = widget.user['access_token'] as String;

      await ApiService.deleteEnrollment(token, enrollmentId);

      if (!mounted) return;

      await _loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enrollment removed successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget _buildEnrollmentCard(Map<String, dynamic> enrollment) {
    final status = (enrollment['status'] ?? '').toString();

    final isDropped = status.toLowerCase() == 'dropped';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              child: Icon(
                isDropped ? Icons.person_off_outlined : Icons.person_outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (enrollment['student_name'] ?? 'Unknown Student')
                        .toString(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${enrollment['student_number'] ?? ''} • '
                    '${enrollment['student_email'] ?? ''}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${enrollment['subject_code'] ?? ''} - '
                    '${enrollment['subject_name'] ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.school_outlined, size: 18),
                        label: Text((enrollment['semester'] ?? '').toString()),
                      ),
                      Chip(
                        avatar: const Icon(
                          Icons.calendar_today_outlined,
                          size: 17,
                        ),
                        label: Text(
                          (enrollment['academic_year'] ?? '').toString(),
                        ),
                      ),
                      Chip(
                        label: Text(status.isEmpty ? 'Unknown' : status),
                        backgroundColor: isDropped
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isDropped)
              IconButton(
                tooltip: 'Remove enrollment',
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeEnrollment(enrollment),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56),
              const SizedBox(height: 16),
              const Text(
                'Unable to load enrollments',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _filteredEnrollments;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_enrollments.length} enrollment'
                  '${_enrollments.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 15,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search student or subject...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  const Icon(Icons.assignment_outlined, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No enrollments found.'
                        : 'No matching enrollments found.',
                    style: const TextStyle(fontSize: 17),
                  ),
                ],
              ),
            )
          else
            ...filtered.map(
              (enrollment) =>
                  _buildEnrollmentCard(enrollment as Map<String, dynamic>),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrollment Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEnrollmentDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Enrollment'),
      ),
    );
  }
}
