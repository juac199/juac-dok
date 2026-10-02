
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StudentGraduationProgressPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const StudentGraduationProgressPage({
    super.key,
    required this.user,
  });

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
      backgroundColor: Theme.of(context)
          .colorScheme
          .primaryContainer
          .withValues(alpha: 0.16),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        title: const Text(
          'Graduation Progress',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
              children: [
                _hero(context, progress, requiredCredits),
                const SizedBox(height: 16),
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: _card(
                        context,
                        'Registered',
                        '$_registeredCredits',
                        Icons.pending_actions_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
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
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _check(
                  context,
                  'Minimum credit requirement',
                  false,
                ),
                _check(
                  context,
                  'Core subjects completed',
                  false,
                ),
                _check(
                  context,
                  'Elective requirements',
                  false,
                ),
                _check(
                  context,
                  'Final year project',
                  false,
                ),
                _check(
                  context,
                  'Graduation application',
                  false,
                ),
              ],
            ),
    );
  }

  Widget _hero(
    BuildContext context,
    double progress,
    int requiredCredits,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 33,
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'Degree Completion',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% completed',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            '$_completedCredits of $requiredCredits credits completed',
            style: const TextStyle(color: Colors.white70),
          ),
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
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 15,
        ),
        child: Column(
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(height: 7),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _check(
    BuildContext context,
    String title,
    bool completed,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          completed
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: completed ? Colors.green : colors.onSurfaceVariant,
        ),
        title: Text(title),
        trailing: Text(
          completed ? 'Complete' : 'Pending',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
