import 'package:flutter/material.dart';

class StudentDocumentsPage extends StatelessWidget {
  const StudentDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final documents = [
      ('Student ID', Icons.badge_rounded),
      ('Enrollment Letter', Icons.school_rounded),
      ('Academic Transcript', Icons.receipt_long_rounded),
      ('Fee Statement', Icons.account_balance_wallet_rounded),
      ('Payment Receipts', Icons.payments_rounded),
      ('Certificates', Icons.workspace_premium_rounded),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Documents',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Digital Document Center',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Important university documents will be available here.',
          ),
          const SizedBox(height: 20),
          ...documents.map(
            (doc) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(doc.$2),
                ),
                title: Text(
                  doc.$1,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Document center'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${doc.$1} will be connected to document storage.',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
