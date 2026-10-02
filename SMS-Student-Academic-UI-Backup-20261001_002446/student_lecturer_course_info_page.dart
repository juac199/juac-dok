import 'package:flutter/material.dart';

class StudentLecturerCourseInfoPage extends StatelessWidget {
  const StudentLecturerCourseInfoPage({super.key});

  final List<Map<String, String>> courses = const [
    {
      'code': 'CSC301',
      'name': 'Database Systems',
      'credits': '3 Credit Hours',
      'lecturer': 'Lecturer information pending',
      'schedule': 'Schedule will be published by the faculty',
    },
    {
      'code': 'CSC302',
      'name': 'Computer Networks',
      'credits': '3 Credit Hours',
      'lecturer': 'Lecturer information pending',
      'schedule': 'Schedule will be published by the faculty',
    },
    {
      'code': 'CSC303',
      'name': 'Software Engineering',
      'credits': '3 Credit Hours',
      'lecturer': 'Lecturer information pending',
      'schedule': 'Schedule will be published by the faculty',
    },
    {
      'code': 'CSC304',
      'name': 'Web Application Development',
      'credits': '3 Credit Hours',
      'lecturer': 'Lecturer information pending',
      'schedule': 'Schedule will be published by the faculty',
    },
    {
      'code': 'CSC305',
      'name': 'Cyber Security',
      'credits': '3 Credit Hours',
      'lecturer': 'Lecturer information pending',
      'schedule': 'Schedule will be published by the faculty',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer & Course Info'),
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
                    child: Icon(Icons.people_alt_rounded, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Course Directory',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Course details and teaching information.',
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
          ...courses.map(
            (course) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.school_rounded),
                ),
                title: Text(
                  course['code']!,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(course['name']!),
                childrenPadding: const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  18,
                ),
                children: [
                  _info(Icons.credit_score_rounded, course['credits']!),
                  _info(Icons.person_rounded, course['lecturer']!),
                  _info(Icons.schedule_rounded, course['schedule']!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
