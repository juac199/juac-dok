
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StudentTranscriptPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const StudentTranscriptPage({
    super.key,
    required this.user,
  });

  @override
  State<StudentTranscriptPage> createState() => _StudentTranscriptPageState();
}

class _StudentTranscriptPageState extends State<StudentTranscriptPage> {
  bool _loading = true;
  String? _error;
  List<dynamic> _results = [];
  Map<String, dynamic>? _performance;

  String get token => widget.user['access_token'] as String;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await ApiService.getMyResults(token);

      Map<String, dynamic>? performance;
      try {
        performance = await ApiService.getMyPerformance(token);
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _results = results;
        _performance = performance;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _text(dynamic value, [String fallback = '—']) {
    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final cgpa = _performance?['cgpa'] ?? '—';
    final credits = _performance?['total_credit_hours'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Academic Transcript',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                children: [
                  _hero(context),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          context,
                          'CGPA',
                          _text(cgpa),
                          Icons.insights_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          context,
                          'Credits',
                          credits.toString(),
                          Icons.school_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Academic History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    _message(context, _error!, true)
                  else if (_results.isEmpty)
                    _message(
                      context,
                      'No academic results are available yet. Your transcript will appear here when results are published.',
                      false,
                    )
                  else
                    ..._results.map((item) {
                      final data = Map<String, dynamic>.from(item);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: colors.primaryContainer,
                            child: Icon(
                              Icons.menu_book_rounded,
                              color: colors.primary,
                            ),
                          ),
                          title: Text(
                            _text(
                              data['subject_code'],
                              'Subject',
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: Text(
                            _text(
                              data['subject_name'],
                              'Academic subject',
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _text(data['grade']),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '${_text(data['credit_hours'], '0')} credits',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }

  Widget _hero(BuildContext context) {
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
      child: Row(
        children: [
          const CircleAvatar(
            radius: 29,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.description_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Official Academic Record',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _text(widget.user['full_name'], 'Student'),
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(height: 11),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(BuildContext context, String text, bool error) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              error
                  ? Icons.error_outline_rounded
                  : Icons.info_outline_rounded,
              color: error ? colors.error : colors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
