import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminResultsPage extends StatefulWidget {
  final String token;

  const AdminResultsPage({
    super.key,
    required this.token,
  });

  @override
  State<AdminResultsPage> createState() => _AdminResultsPageState();
}

class _AdminResultsPageState extends State<AdminResultsPage> {
  List<dynamic> results = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await ApiService.getAdminResults(widget.token);

      if (!mounted) return;

      setState(() {
        results = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load results: $e',
          ),
        ),
      );
    }
  }

  Future<void> _addResult() async {
    final students = await ApiService.getStudents(widget.token);
    final subjects = await ApiService.getSubjects(widget.token);

    if (!mounted) return;

    int? selectedStudentId;
    int? selectedSubjectId;
    String selectedSemester = 'Semester 1';
    String academicYear = '2026/2027';
    String marks = '';

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Result'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Student',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: selectedStudentId,
                      items: students.map((student) {
                        return DropdownMenuItem<int>(
                          value: student['id'] as int,
                          child: Text(
                            '${student['student_number']} - ${student['full_name']}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedStudentId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: selectedSubjectId,
                      items: subjects.map((subject) {
                        return DropdownMenuItem<int>(
                          value: subject['id'] as int,
                          child: Text(
                            '${subject['subject_code']} - ${subject['subject_name']}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedSubjectId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Semester',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: selectedSemester,
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
                      initialValue: academicYear,
                      decoration: const InputDecoration(
                        labelText: 'Academic Year',
                        hintText: '2026/2027',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        academicYear = value.trim();
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Marks',
                        hintText: '0 - 100',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) {
                        marks = value.trim();
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (selectedStudentId == null ||
                        selectedSubjectId == null ||
                        academicYear.isEmpty ||
                        marks.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please complete all fields.',
                          ),
                        ),
                      );
                      return;
                    }

                    final parsedMarks = double.tryParse(marks);

                    if (parsedMarks == null ||
                        parsedMarks < 0 ||
                        parsedMarks > 100) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Marks must be between 0 and 100.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext, true);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Result'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) return;

    final parsedMarks = double.tryParse(marks);

    if (selectedStudentId == null ||
        selectedSubjectId == null ||
        parsedMarks == null) {
      return;
    }

    try {
      await ApiService.createAdminResult(
        widget.token,
        {
          'student_id': selectedStudentId,
          'subject_id': selectedSubjectId,
          'semester': selectedSemester,
          'academic_year': academicYear,
          'marks': parsedMarks,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Result created successfully.',
          ),
        ),
      );

      await _loadResults();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create result: $e',
          ),
        ),
      );
    }
  }

  Future<void> _publishResult(
    int resultId,
    String currentStatus,
  ) async {
    final newStatus =
        currentStatus == 'published' ? 'draft' : 'published';

    try {
      await ApiService.publishResult(
        widget.token,
        resultId,
        newStatus,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'published'
                ? 'Result published successfully.'
                : 'Result moved back to draft.',
          ),
        ),
      );

      await _loadResults();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update result: $e',
          ),
        ),
      );
    }
  }

  Future<void> _deleteResult(
    int resultId,
    String studentName,
    String subjectCode,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Result'),
          content: Text(
            'Are you sure you want to delete the result for '
            '$studentName in $subjectCode?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await ApiService.deleteAdminResult(
        widget.token,
        resultId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Result deleted successfully.',
          ),
        ),
      );

      await _loadResults();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete result: $e',
          ),
        ),
      );
    }
  }

  Future<void> _editResult(
    int resultId,
    String currentMarks,
    String currentStatus,
  ) async {
    String marks = currentMarks;
    String selectedStatus = currentStatus;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Result'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: currentMarks,
                      decoration: const InputDecoration(
                        labelText: 'Marks',
                        hintText: '0 - 100',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) {
                        marks = value.trim();
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: selectedStatus,
                      items: const [
                        DropdownMenuItem(
                          value: 'draft',
                          child: Text('Draft'),
                        ),
                        DropdownMenuItem(
                          value: 'published',
                          child: Text('Published'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedStatus = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final parsedMarks =
                        double.tryParse(marks);

                    if (parsedMarks == null ||
                        parsedMarks < 0 ||
                        parsedMarks > 100) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Marks must be between 0 and 100.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext, true);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) return;

    final parsedMarks = double.tryParse(marks);

    if (parsedMarks == null ||
        parsedMarks < 0 ||
        parsedMarks > 100) {
      return;
    }

    try {
      await ApiService.updateAdminResult(
        widget.token,
        resultId,
        {
          'marks': parsedMarks,
          'status': selectedStatus,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Result updated successfully.',
          ),
        ),
      );

      await _loadResults();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update result: $e',
          ),
        ),
      );
    }
  }

  Color _statusColor(String status) {
    if (status == 'published') {
      return Colors.green;
    }

    return Colors.orange;
  }

  Widget _buildResultsList() {
    final filteredResults = results.where((result) {
      if (searchQuery.isEmpty) {
        return true;
      }

      final studentName =
          result['student_name']?.toString().toLowerCase() ?? '';

      final studentNumber =
          result['student_number']?.toString().toLowerCase() ?? '';

      final subjectCode =
          result['subject_code']?.toString().toLowerCase() ?? '';

      final subjectName =
          result['subject_name']?.toString().toLowerCase() ?? '';

      return studentName.contains(searchQuery) ||
          studentNumber.contains(searchQuery) ||
          subjectCode.contains(searchQuery) ||
          subjectName.contains(searchQuery);
    }).toList();

    if (filteredResults.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          Center(
            child: Text(
              searchQuery.isEmpty
                  ? 'No results found.'
                  : 'No matching results found.',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _loadResults,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredResults.length,
        itemBuilder: (context, index) {
          final result = filteredResults[index];

          final int resultId =
              result['id'] as int;

          final String studentName =
              result['student_name']?.toString() ??
                  'Unknown Student';

          final String studentNumber =
              result['student_number']?.toString() ??
                  '-';

          final String subjectCode =
              result['subject_code']?.toString() ??
                  '-';

          final String subjectName =
              result['subject_name']?.toString() ??
                  '-';

          final String marks =
              result['marks']?.toString() ?? '-';

          final String grade =
              result['grade']?.toString() ?? '-';

          final String gradePoint =
              result['grade_point']?.toString() ?? '-';

          final String semester =
              result['semester']?.toString() ?? '-';

          final String academicYear =
              result['academic_year']?.toString() ?? '-';

          final String status =
              result['status']?.toString() ?? 'draft';

          final bool isPublished =
              status == 'published';

          return Card(
            margin: const EdgeInsets.only(
              bottom: 12,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '$subjectCode - $subjectName',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(status)
                              .withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color:
                                _statusColor(status),
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Student: $studentName',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Student Number: $studentNumber',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Marks: $marks',
                  ),
                  Text(
                    'Grade: $grade',
                  ),
                  Text(
                    'Grade Point: $gradePoint',
                  ),
                  Text(
                    'Semester: $semester',
                  ),
                  Text(
                    'Academic Year: $academicYear',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _editResult(
                              resultId,
                              marks,
                              status,
                            );
                          },
                          icon: const Icon(
                            Icons.edit,
                          ),
                          label: const Text(
                            'Edit',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _publishResult(
                              resultId,
                              status,
                            );
                          },
                          icon: Icon(
                            isPublished
                                ? Icons.unpublished
                                : Icons.publish,
                          ),
                          label: Text(
                            isPublished
                                ? 'Draft'
                                : 'Publish',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          _deleteResult(
                            resultId,
                            studentName,
                            subjectCode,
                          );
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                        ),
                        tooltip: 'Delete Result',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results Management'),
        actions: [
          IconButton(
            onPressed: _addResult,
            icon: const Icon(Icons.add),
            tooltip: 'Add Result',
          ),
          IconButton(
            onPressed: _loadResults,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Results',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    8,
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Results',
                      hintText:
                          'Student, student number, or subject',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  searchQuery = '';
                                });
                              },
                              icon: const Icon(Icons.clear),
                              tooltip: 'Clear Search',
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.trim().toLowerCase();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _buildResultsList(),
                ),
              ],
            )
    );
  }
}