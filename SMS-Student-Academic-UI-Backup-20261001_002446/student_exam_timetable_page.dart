import 'package:flutter/material.dart';

class StudentExamTimetablePage extends StatelessWidget {
  const StudentExamTimetablePage({super.key});

  final List<Map<String, String>> exams = const [
    {
      'code': 'CSC301',
      'name': 'Database Systems',
      'date': '10 Dec 2026',
      'time': '09:00 AM – 11:00 AM',
      'venue': 'Main Examination Hall',
    },
    {
      'code': 'CSC302',
      'name': 'Computer Networks',
      'date': '12 Dec 2026',
      'time': '02:00 PM – 04:00 PM',
      'venue': 'Engineering Block',
    },
    {
      'code': 'CSC303',
      'name': 'Software Engineering',
      'date': '15 Dec 2026',
      'time': '09:00 AM – 11:00 AM',
      'venue': 'Main Examination Hall',
    },
    {
      'code': 'CSC304',
      'name': 'Web Application Development',
      'date': '17 Dec 2026',
      'time': '02:00 PM – 04:00 PM',
      'venue': 'Computing Laboratory',
    },
    {
      'code': 'CSC305',
      'name': 'Cyber Security',
      'date': '19 Dec 2026',
      'time': '09:00 AM – 11:00 AM',
      'venue': 'Technology Hall',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Examination Timetable'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.event_note_rounded, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Final Examination Schedule',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Check your examination date, time and venue.',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...exams.map(
            (exam) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          child: Icon(Icons.assignment_rounded),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exam['code']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(exam['name']!),
                            ],
                          ),
                        ),
                        const Chip(
                          label: Text('Scheduled'),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _row(Icons.calendar_today_rounded, 'Date', exam['date']!),
                    _row(Icons.access_time_rounded, 'Time', exam['time']!),
                    _row(Icons.location_on_rounded, 'Venue', exam['venue']!),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
