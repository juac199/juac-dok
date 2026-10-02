import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StudentGraduationProgressPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const StudentGraduationProgressPage({super.key, required this.user});

  @override
  State<StudentGraduationProgressPage> createState() =>
      _StudentGraduationProgressPageState();
}

class _StudentGraduationProgressPageState
    extends State<StudentGraduationProgressPage> {
  bool _loading = true;
  int _completedCredits = 0;
  int _registeredCredits = 0;

  String get token => widget.user['access_token'] as String;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final subjects = await ApiService.getMySubjects(token);

      int credits = 0;
      for (final item in subjects) {
        final data = Map<String, dynamic>.from(item);
        final value = data['credit_hours'] ?? data['credits'] ?? 0;
        credits += int.tryParse(value.toString()) ?? 0;
      }

      if (!mounted) return;
      setState(() {
        _registeredCredits = credits;
        _completedCredits = 0;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const requiredCredits = 120;
    final progress =
        (_completedCredits / requiredCredits).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Graduation Progress'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 34,
                          child: Icon(Icons.school_rounded, size: 34),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Degree Completion',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${(_completedCredits / requiredCredits * 100).toStringAsFixed(0)}% completed',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _card(
                        context,
                        'Completed',
                        '$_completedCredits',
                        Icons.check_circle_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _card(
                        context,
                        'Registered',
                        '$_registeredCredits',
                        Icons.pending_actions_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _card(
                        context,
                        'Required',
                        '$requiredCredits',
                        Icons.flag_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Graduation Checklist',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _check('Minimum credit requirement', false),
                _check('Core subjects completed', false),
                _check('Elective requirements', false),
                _check('Final year project', false),
                _check('Graduation application', false),
              ],
            ),
    );
  }

  Widget _card(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _check(String title, bool completed) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          completed
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
        ),
        title: Text(title),
        trailing: Text(
          completed ? 'Complete' : 'Pending',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
