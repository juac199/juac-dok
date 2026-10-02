import 'package:flutter/material.dart';

import '../services/api_service.dart';

class StudentSubjectsPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const StudentSubjectsPage({super.key, required this.user});

  @override
  State<StudentSubjectsPage> createState() => _StudentSubjectsPageState();
}

class _StudentSubjectsPageState extends State<StudentSubjectsPage> {
  bool _loading = true;
  bool _working = false;
  String? _error;

  List<dynamic> _registeredSubjects = [];
  List<dynamic> _availableSubjects = [];

  String get token => widget.user['access_token'] as String;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final results = await Future.wait([
        ApiService.getMySubjects(token),
        ApiService.getAvailableSubjects(token),
      ]);

      if (!mounted) return;

      setState(() {
        _registeredSubjects = results[0];
        _availableSubjects = results[1];
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

  int? _intValue(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  String _text(
    Map<String, dynamic> data,
    List<String> keys, [
    String fallback = '—',
  ]) {
    for (final key in keys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  int _subjectId(Map<String, dynamic> subject) {
    return _intValue(subject['subject_id'] ?? subject['id']) ?? 0;
  }

  int _registrationId(Map<String, dynamic> subject) {
    return _intValue(
          subject['registration_id'] ??
              subject['student_subject_id'] ??
              subject['id'],
        ) ??
        0;
  }

  String _subjectCode(Map<String, dynamic> subject) {
    return _text(subject, ['subject_code', 'code'], 'SUBJECT');
  }

  String _subjectName(Map<String, dynamic> subject) {
    return _text(subject, ['subject_name', 'name', 'title'], 'Unnamed Subject');
  }

  String _credits(Map<String, dynamic> subject) {
    return _text(subject, ['credit_hours', 'credits', 'credit'], '0');
  }

  String _semester(Map<String, dynamic> subject) {
    return _text(subject, ['semester'], '—');
  }

  String _academicYear(Map<String, dynamic> subject) {
    return _text(subject, ['academic_year'], '—');
  }

  Future<void> _registerSubject(Map<String, dynamic> subject) async {
    final subjectId = _subjectId(subject);

    if (subjectId == 0) {
      _showMessage('Invalid subject information.');
      return;
    }

    final semesterController = TextEditingController(text: 'Semester 1');
    final yearController = TextEditingController(
      text: DateTime.now().year.toString(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Register Subject',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF102A43),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_subjectCode(subject)} — ${_subjectName(subject)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2457A6),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: semesterController,
                decoration: InputDecoration(
                  labelText: 'Semester',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: yearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Academic Year',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (semesterController.text.trim().isEmpty ||
                    yearController.text.trim().isEmpty) {
                  return;
                }

                Navigator.pop(context, true);
              },
              child: const Text('Register'),
            ),
          ],
        );
      },
    );

    final semester = semesterController.text.trim();
    final academicYear = yearController.text.trim();

    semesterController.dispose();
    yearController.dispose();

    if (confirmed != true) return;

    if (!mounted) return;

    setState(() {
      _working = true;
    });

    try {
      await ApiService.registerSubject(
        token,
        subjectId,
        semester,
        academicYear,
      );

      if (!mounted) return;

      _showMessage('${_subjectCode(subject)} registered successfully.');

      await _loadSubjects();
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString().replaceFirst('Exception: ', ''), error: true);

      setState(() {
        _working = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
        });
      }
    }
  }

  Future<void> _dropSubject(Map<String, dynamic> subject) async {
    final registrationId = _registrationId(subject);

    if (registrationId == 0) {
      _showMessage('Invalid registration information.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Drop Subject?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF102A43),
            ),
          ),
          content: Text(
            'Are you sure you want to drop '
            '${_subjectCode(subject)} — ${_subjectName(subject)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Drop Subject'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    if (!mounted) return;

    setState(() {
      _working = true;
    });

    try {
      await ApiService.dropSubject(token, registrationId);

      if (!mounted) return;

      _showMessage('${_subjectCode(subject)} dropped successfully.');

      await _loadSubjects();
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString().replaceFirst('Exception: ', ''), error: true);
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _subjectCard(
    Map<String, dynamic> subject, {
    required bool registered,
  }) {
    final code = _subjectCode(subject);
    final name = _subjectName(subject);
    final credits = _credits(subject);

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFEAF2FF),
                  child: Icon(
                    registered
                        ? Icons.menu_book_rounded
                        : Icons.add_task_rounded,
                    color: const Color(0xFF2457A6),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        code,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2457A6),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF102A43),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoChip(
                  Icons.school_rounded,
                  '$credits credit${credits == '1' ? '' : 's'}',
                ),
                if (registered)
                  _infoChip(Icons.calendar_month_rounded, _semester(subject)),
                if (registered)
                  _infoChip(Icons.event_rounded, _academicYear(subject)),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: registered
                  ? OutlinedButton.icon(
                      onPressed: _working ? null : () => _dropSubject(subject),
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      label: const Text('Drop Subject'),
                    )
                  : FilledButton.icon(
                      onPressed: _working
                          ? null
                          : () => _registerSubject(subject),
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      label: const Text('Register Subject'),
                    ),
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

  Widget _section(
    String title,
    String subtitle,
    List<dynamic> subjects, {
    required bool registered,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            color: Color(0xFF102A43),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
        ),
        const SizedBox(height: 12),
        if (subjects.isEmpty)
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFFE3E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      registered
                          ? Icons.menu_book_outlined
                          : Icons.check_circle_outline_rounded,
                      size: 44,
                      color: const Color(0xFF8A94A6),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      registered
                          ? 'No subjects registered yet.'
                          : 'No additional subjects are available.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...subjects.map(
            (item) => _subjectCard(
              Map<String, dynamic>.from(item as Map),
              registered: registered,
            ),
          ),
      ],
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
                'Unable to Load Subjects',
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
                onPressed: _loadSubjects,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSubjects,
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
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: Color(0x33FFFFFF),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 29,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subject Registration',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage your academic subjects',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          _section(
            'My Registered Subjects',
            'Subjects currently registered to your account',
            _registeredSubjects,
            registered: true,
          ),
          const SizedBox(height: 28),
          _section(
            'Available Subjects',
            'Subjects you can register for',
            _availableSubjects,
            registered: false,
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
          'My Subjects',
          style: TextStyle(
            color: Color(0xFF102A43),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _working ? null : _loadSubjects,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF102A43)),
          ),
        ],
      ),
      body: Stack(
        children: [
          _content(),
          if (_working)
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
