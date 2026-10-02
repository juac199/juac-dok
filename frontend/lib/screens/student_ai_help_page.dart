import 'package:flutter/material.dart';

class StudentAiHelpPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const StudentAiHelpPage({super.key, required this.user});

  @override
  State<StudentAiHelpPage> createState() => _StudentAiHelpPageState();
}

class _StudentAiHelpPageState extends State<StudentAiHelpPage> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'text': 'Hello! I am your Student Help Assistant. Ask me about subjects, results, attendance, fees, visa, hostel services, or university procedures.',
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});

      _messages.add({'role': 'assistant', 'text': _localResponse(text)});
    });

    _controller.clear();
  }

  String _localResponse(String question) {
    final q = question.toLowerCase();

    if (q.contains('fee') || q.contains('payment')) {
      return 'You can check your current fees, invoices and payment history from Fees & Payments in the Student Services section.';
    }

    if (q.contains('visa') || q.contains('pass')) {
      return 'Open Visa & Student Pass to review your immigration information. For renewal procedures, contact the university international office.';
    }

    if (q.contains('hostel') || q.contains('accommodation')) {
      return 'Open Hostel Services to view accommodation information, requirements and support options.';
    }

    if (q.contains('result') || q.contains('grade') || q.contains('cgpa')) {
      return 'You can view your examination results and academic performance from Results and Performance.';
    }

    if (q.contains('attendance')) {
      return 'Open Attendance to see your overall attendance, present, absent and late records.';
    }

    if (q.contains('subject') || q.contains('registration')) {
      return 'Open My Subjects to view registered subjects and available subjects. You can register or drop subjects from there.';
    }

    return 'I can help you navigate the Student Management System. Try asking about subjects, results, attendance, fees, visa, hostel services, or university procedures.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'AI Student Help',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF14213D),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 330),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF2F6DB2) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      message['text'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : const Color(0xFF14213D),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ask Student Help...',
                        filled: true,
                        fillColor: const Color(0xFFF5F7FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
