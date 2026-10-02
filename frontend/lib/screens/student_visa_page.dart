import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';

class StudentVisaPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const StudentVisaPage({super.key, required this.user});

  @override
  State<StudentVisaPage> createState() => _StudentVisaPageState();
}

class _StudentVisaPageState extends State<StudentVisaPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _visa = {};

  String get token => widget.user['access_token'] as String;

  @override
  void initState() {
    super.initState();
    _loadVisa();
  }

  Future<void> _loadVisa() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/student/visa'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          data is Map
              ? data['detail'] ?? 'Failed to load visa information'
              : 'Failed to load visa information',
        );
      }

      if (!mounted) return;

      setState(() {
        _visa = data is Map ? Map<String, dynamic>.from(data) : {};
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

  String _field(List<String> keys) {
    for (final key in keys) {
      if (_visa[key] != null && _visa[key].toString().isNotEmpty) {
        return _visa[key].toString();
      }
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Visa & Student Pass',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF14213D),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadVisa,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _errorView()
            : _content(),
      ),
    );
  }

  Widget _content() {
    final status = _field(['status', 'visa_status', 'pass_status']);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(23),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF173B72), Color(0xFF2F6DB2)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.badge_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 17),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Student Immigration Status',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _section([
          _row('Passport Number', _field(['passport_number', 'passport'])),
          _row('Visa Type', _field(['visa_type', 'pass_type'])),
          _row('Visa Number', _field(['visa_number', 'pass_number'])),
          _row('Issue Date', _field(['issue_date', 'issued_date'])),
          _row('Expiry Date', _field(['expiry_date', 'expires_at', 'expiry'])),
          _row('Renewal Status', _field(['renewal_status'])),
        ]),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: Color(0xFF2F6DB2)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Keep your passport and student pass information up to date. '
                  'Contact the university international office for renewal requirements.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _section(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 7, 18, 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF14213D),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 90),
        const Icon(Icons.cloud_off_rounded, size: 55, color: Colors.black26),
        const SizedBox(height: 16),
        const Text(
          'Unable to load visa information',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          _error ?? 'Something went wrong.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 20),
        Center(
          child: FilledButton.icon(
            onPressed: _loadVisa,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ),
      ],
    );
  }
}
