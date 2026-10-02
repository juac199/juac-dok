
import 'package:flutter/material.dart';

class StudentExamTimetablePage extends StatelessWidget {
  const StudentExamTimetablePage({super.key});

  static const exams = [
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
        title: const Text(
          'Examination Timetable',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
        children: [
          _hero(context),
          const SizedBox(height: 18),
          ...exams.map((exam) => _examCard(context, exam)),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 29,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.event_note_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Final Examination Schedule',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Check your examination date, time and venue.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _examCard(
    BuildContext context,
    Map<String, String> exam,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  child: Icon(
                    Icons.assignment_rounded,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam['code']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(exam['name']!),
                    ],
                  ),
                ),
                const Chip(
                  label: Text('Scheduled'),
                ),
              ],
            ),
            const Divider(height: 25),
            _row(
              context,
              Icons.calendar_today_rounded,
              'Date',
              exam['date']!,
            ),
            _row(
              context,
              Icons.access_time_rounded,
              'Time',
              exam['time']!,
            ),
            _row(
              context,
              Icons.location_on_rounded,
              'Venue',
              exam['venue']!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: colors.primary,
          ),
          const SizedBox(width: 10),
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
