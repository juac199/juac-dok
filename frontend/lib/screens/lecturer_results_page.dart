import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';

class LecturerResultsPage extends StatefulWidget {
  final String token;

  const LecturerResultsPage({
    super.key,
    required this.token,
  });

  @override
  State<LecturerResultsPage> createState() => _LecturerResultsPageState();
}

class _LecturerResultsPageState extends State<LecturerResultsPage> {
  List<dynamic> _results = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await ApiService.getLecturerResults(
        widget.token,
      );

      if (!mounted) return;

      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _showAddResultDialog() async {
    final studentIdController = TextEditingController();
    final subjectIdController = TextEditingController();
    final marksController = TextEditingController();
    final semesterController =
        TextEditingController(text: 'Semester 1');
    final academicYearController =
        TextEditingController(text: '2026/2027');

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Result'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: studentIdController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Student ID',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter student ID';
                          }

                          if (int.tryParse(value.trim()) == null) {
                            return 'Enter a valid student ID';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: subjectIdController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Subject ID',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter subject ID';
                          }

                          if (int.tryParse(value.trim()) == null) {
                            return 'Enter a valid subject ID';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: marksController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Marks',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final marks = double.tryParse(
                            value?.trim() ?? '',
                          );

                          if (marks == null) {
                            return 'Enter valid marks';
                          }

                          if (marks < 0 || marks > 100) {
                            return 'Marks must be 0-100';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: semesterController,
                        decoration: const InputDecoration(
                          labelText: 'Semester',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: academicYearController,
                        decoration: const InputDecoration(
                          labelText: 'Academic Year',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                          });

                          try {
                            await ApiService.addLecturerResult(
                              widget.token,
                              {
                                'student_id': int.parse(
                                  studentIdController.text.trim(),
                                ),
                                'subject_id': int.parse(
                                  subjectIdController.text.trim(),
                                ),
                                'marks': double.parse(
                                  marksController.text.trim(),
                                ),
                                'semester':
                                    semesterController.text.trim(),
                                'academic_year':
                                    academicYearController.text.trim(),
                              },
                            );

                            if (!context.mounted) return;

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Result added successfully.',
                                ),
                              ),
                            );

                            await _loadResults();
                          } catch (e) {
                            if (!context.mounted) return;

                            setDialogState(() {
                              saving = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to add result.\n$e',
                                ),
                              ),
                            );
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    studentIdController.dispose();
    subjectIdController.dispose();
    marksController.dispose();
    semesterController.dispose();
    academicYearController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        actions: [
          IconButton(
            onPressed: _loadResults,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddResultDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Result'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadResults,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : _results.isEmpty
                  ? const Center(
                      child: Text(
                        'No results found.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadResults,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final result = _results[index];

                          final studentName =
                              result['student_name'] ??
                              result['full_name'] ??
                              'Unknown Student';

                          final studentNumber =
                              result['student_number'] ??
                              '';

                          final subjectName =
                              result['subject_name'] ??
                              result['course_name'] ??
                              'Unknown Subject';

                          final subjectCode =
                              result['subject_code'] ??
                              '';

                          final marks =
                              result['marks']?.toString() ?? '-';

                          final grade =
                              result['grade']?.toString() ?? '-';

                          final gp =
                              result['grade_point']?.toString() ??
                              result['gp']?.toString() ??
                              '-';

                          return Card(
                            margin: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  grade.isNotEmpty
                                      ? grade[0]
                                      : '?',
                                ),
                              ),
                              title: Text(
                                studentName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '$studentNumber\n'
                                '$subjectCode - $subjectName\n'
                                'Marks: $marks  |  Grade: $grade  |  GP: $gp',
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
