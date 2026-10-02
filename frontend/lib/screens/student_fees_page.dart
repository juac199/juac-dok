import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';

class StudentFeesPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const StudentFeesPage({super.key, required this.user});

  @override
  State<StudentFeesPage> createState() => _StudentFeesPageState();
}

class _StudentFeesPageState extends State<StudentFeesPage> {
  bool _loading = true;
  String? _error;

  Map<String, dynamic> _summary = {};
  List<dynamic> _invoices = [];
  List<dynamic> _payments = [];

  String get token => widget.user['access_token'] as String;

  @override
  void initState() {
    super.initState();
    _loadFees();
  }

  Future<dynamic> _get(String path) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}$path'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(
      data is Map
          ? data['detail'] ?? 'Failed to load fee information'
          : 'Failed to load fee information',
    );
  }

  Future<void> _loadFees() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final responses = await Future.wait([
        _get('/student/fees/summary'),
        _get('/student/fees/invoices'),
        _get('/student/fees/payments'),
      ]);

      if (!mounted) return;

      setState(() {
        _summary = responses[0] is Map
            ? Map<String, dynamic>.from(responses[0] as Map)
            : {};

        _invoices = responses[1] is List ? responses[1] as List : [];
        _payments = responses[2] is List ? responses[2] as List : [];
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

  double _amount(String key) {
    final value = _summary[key];

    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }

  String _value(dynamic item, String key) {
    if (item is Map && item[key] != null) {
      return item[key].toString();
    }

    return '-';
  }

  String _money(double value) => 'RM ${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Fees & Payments',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF14213D),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadFees,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _errorView()
            : _content(),
      ),
    );
  }

  Widget _content() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        _balanceCard(),
        const SizedBox(height: 24),
        const Text(
          'Fee Overview',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF14213D),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                'Total',
                _money(_amount('total_amount')),
                Icons.receipt_long_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                'Paid',
                _money(_amount('paid_amount')),
                Icons.check_circle_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                'Outstanding',
                _money(_amount('outstanding_amount')),
                Icons.account_balance_wallet_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                'Invoices',
                _invoices.length.toString(),
                Icons.description_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Text(
          'Invoices',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF14213D),
          ),
        ),
        const SizedBox(height: 12),
        if (_invoices.isEmpty)
          _empty('No invoices available', Icons.receipt_long_rounded)
        else
          ..._invoices.map((item) => _invoiceCard(item)),
        const SizedBox(height: 20),
        const Text(
          'Payment History',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF14213D),
          ),
        ),
        const SizedBox(height: 12),
        if (_payments.isEmpty)
          _empty('No payment records available', Icons.payments_rounded)
        else
          ..._payments.map((item) => _paymentCard(item)),
      ],
    );
  }

  Widget _balanceCard() {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF173B72), Color(0xFF2F6DB2)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
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
              Icons.account_balance_wallet_rounded,
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
                  'Outstanding Balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _money(_amount('outstanding_amount')),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2F6DB2), size: 25),
          const SizedBox(height: 11),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF14213D),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _invoiceCard(dynamic item) {
    return _recordCard(
      icon: Icons.description_rounded,
      title: _value(item, 'invoice_number') != '-'
          ? _value(item, 'invoice_number')
          : _value(item, 'description'),
      subtitle: _value(item, 'due_date'),
      amount: _value(item, 'amount'),
      status: _value(item, 'status'),
    );
  }

  Widget _paymentCard(dynamic item) {
    return _recordCard(
      icon: Icons.payments_rounded,
      title: _value(item, 'payment_reference'),
      subtitle: _value(item, 'payment_date'),
      amount: _value(item, 'amount'),
      status: _value(item, 'status'),
    );
  }

  Widget _recordCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required String status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF2F6DB2).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF2F6DB2)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF14213D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount == '-' ? '-' : 'RM $amount',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF14213D),
                ),
              ),
              if (status != '-')
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _empty(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, size: 45, color: Colors.black26),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
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
          'Unable to load fees',
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
            onPressed: _loadFees,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ),
      ],
    );
  }
}
