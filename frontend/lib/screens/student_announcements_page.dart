import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';

class StudentAnnouncementsPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const StudentAnnouncementsPage({super.key, required this.user});

  @override
  State<StudentAnnouncementsPage> createState() =>
      _StudentAnnouncementsPageState();
}

class _StudentAnnouncementsPageState extends State<StudentAnnouncementsPage> {
  bool _loading = true;
  String? _error;
  List<dynamic> _announcements = [];

  String get token => widget.user['access_token'] as String;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/student/announcements'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          data is Map
              ? data['detail'] ?? 'Failed to load announcements'
              : 'Failed to load announcements',
        );
      }

      if (!mounted) return;

      setState(() {
        _announcements = data is List ? data : [];
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

  String _value(dynamic item, String key) {
    if (item is Map && item[key] != null) {
      return item[key].toString();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Announcements',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF14213D),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAnnouncements,
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
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF173B72), Color(0xFF2F6DB2)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            children: [
              Icon(Icons.campaign_rounded, color: Colors.white, size: 34),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  'University News & Announcements',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        if (_announcements.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 52,
                  color: Colors.black26,
                ),
                SizedBox(height: 12),
                Text(
                  'No announcements yet',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF14213D),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'New university announcements will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          )
        else
          ..._announcements.map(_announcementCard),
      ],
    );
  }

  Widget _announcementCard(dynamic item) {
    final title = _value(item, 'title').isNotEmpty
        ? _value(item, 'title')
        : 'University Announcement';

    final message = _value(item, 'message').isNotEmpty
        ? _value(item, 'message')
        : _value(item, 'content');

    final date = _value(item, 'published_at').isNotEmpty
        ? _value(item, 'published_at')
        : _value(item, 'created_at');

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F6DB2).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: Color(0xFF2F6DB2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF14213D),
                  ),
                ),
              ),
            ],
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
          if (date.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              date,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ],
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
          'Unable to load announcements',
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
            onPressed: _loadAnnouncements,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ),
      ],
    );
  }
}
