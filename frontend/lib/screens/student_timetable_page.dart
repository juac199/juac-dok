import 'package:flutter/material.dart';

class StudentTimetablePage extends StatelessWidget {
  const StudentTimetablePage({super.key});

  @override
  Widget build(BuildContext context) {
    final schedule = [
      ('Monday', '09:00', 'CSC301', 'Database Systems'),
      ('Monday', '11:00', 'CSC302', 'Computer Networks'),
      ('Tuesday', '10:00', 'CSC303', 'Software Engineering'),
      ('Wednesday', '09:00', 'CSC304', 'Web Application Development'),
      ('Thursday', '14:00', 'CSC305', 'Cyber Security'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Class Timetable',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                Icon(Icons.schedule_rounded, size: 34),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Weekly Schedule',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...schedule.map(
            (item) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(item.$2.substring(0, 2)),
                ),
                title: Text(
                  '${item.$3} — ${item.$4}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('${item.$1} • ${item.$2}'),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
