import 'package:flutter/material.dart';

import '../services/api_service.dart';

class StudentProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const StudentProfilePage({super.key, required this.user});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  String? _error;

  String get _token => widget.user['access_token']?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (_token.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Your login session is missing. Please sign in again.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await ApiService.getMyStudentProfile(_token);

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _value(List<String> keys) {
    final profile = _profile;
    if (profile == null) return '—';

    for (final key in keys) {
      final value = profile[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return '—';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final firstName = _value(['first_name', 'firstname']);
    final lastName = _value(['last_name', 'lastname']);

    final fullName = [
      if (firstName != '—') firstName,
      if (lastName != '—') lastName,
    ].join(' ');

    final displayName = fullName.isEmpty
        ? _value(['name', 'full_name', 'student_name'])
        : fullName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadProfile,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _buildError(theme)
            else ...[
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: .78),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.white.withValues(alpha: .18),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName == '—' ? 'Student' : displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _value([
                              'student_number',
                              'student_id',
                              'matric_number',
                            ]),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .86),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _section(context, 'Personal Information', [
                _item(
                  context,
                  Icons.badge_outlined,
                  'Student Number',
                  _value(['student_number', 'student_id', 'matric_number']),
                ),
                _item(
                  context,
                  Icons.person_outline_rounded,
                  'Full Name',
                  displayName,
                ),
                _item(
                  context,
                  Icons.email_outlined,
                  'Email',
                  _value(['email']),
                ),
                _item(
                  context,
                  Icons.phone_outlined,
                  'Phone',
                  _value(['phone', 'phone_number', 'mobile']),
                ),
              ]),
              const SizedBox(height: 18),
              _section(context, 'Academic Information', [
                _item(
                  context,
                  Icons.school_outlined,
                  'Programme',
                  _value(['programme', 'program', 'course']),
                ),
                _item(
                  context,
                  Icons.account_balance_outlined,
                  'Faculty',
                  _value(['faculty']),
                ),
                _item(
                  context,
                  Icons.calendar_month_outlined,
                  'Academic Year',
                  _value(['academic_year', 'year']),
                ),
                _item(
                  context,
                  Icons.layers_outlined,
                  'Semester',
                  _value(['semester']),
                ),
                _item(
                  context,
                  Icons.verified_outlined,
                  'Status',
                  _value(['status', 'student_status']),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.textTheme.bodySmall?.color?.withValues(alpha: .72),
        ),
      ),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: Column(
        children: [
          Icon(
            Icons.person_off_rounded,
            size: 58,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load your profile',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(_error ?? 'Unknown error', textAlign: TextAlign.center),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _loadProfile,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
