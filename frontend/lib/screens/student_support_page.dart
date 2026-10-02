import 'package:flutter/material.dart';

class StudentSupportPage extends StatelessWidget {
  const StudentSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.support_agent_rounded, size: 40),
                SizedBox(height: 14),
                Text(
                  'How can we help?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Get assistance with academic, finance, IT and university services.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _option(context, Icons.question_answer_rounded, 'Frequently Asked Questions'),
          _option(context, Icons.school_rounded, 'Academic Support'),
          _option(context, Icons.account_balance_wallet_rounded, 'Finance Support'),
          _option(context, Icons.computer_rounded, 'IT Support'),
          _option(context, Icons.home_rounded, 'Hostel Support'),
          _option(context, Icons.add_comment_rounded, 'Submit Support Request'),
        ],
      ),
    );
  }

  Widget _option(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title will be connected here.')),
          );
        },
      ),
    );
  }
}
