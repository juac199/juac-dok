import 'package:flutter/material.dart';

class StudentCareerPage extends StatelessWidget {
  const StudentCareerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Internships', Icons.business_center_rounded),
      ('Job Opportunities', Icons.work_rounded),
      ('Career Events', Icons.event_rounded),
      ('CV & Resume Resources', Icons.description_rounded),
      ('Career Guidance', Icons.support_agent_rounded),
      ('Graduate Opportunities', Icons.school_rounded),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Career Center',
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
                Icon(Icons.work_outline_rounded, size: 38),
                SizedBox(height: 14),
                Text(
                  'Build Your Future',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Explore internships, employment opportunities and career resources.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...items.map(
            (item) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(child: Icon(item.$2)),
                title: Text(
                  item.$1,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${item.$1} will be connected to the Career Center.',
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
