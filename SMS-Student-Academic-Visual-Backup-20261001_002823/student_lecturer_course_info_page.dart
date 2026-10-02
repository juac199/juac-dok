
import 'package:flutter/material.dart';

class StudentLecturerCourseInfoPage extends StatelessWidget {
  const StudentLecturerCourseInfoPage({super.key});

  static const courses = [
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
        title: const Text(
          'Lecturer & Course Info',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
        children: [
          _hero(context),
          const SizedBox(height: 18),
          ...courses.map(
            (course) => _courseCard(context, course),
          ),
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
              Icons.people_alt_rounded,
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
                  'Course Directory',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Course details and teaching information.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _courseCard(
    BuildContext context,
    Map<String, String> course,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          child: Icon(
            Icons.school_rounded,
            color: colors.primary,
          ),
        ),
        title: Text(
          course['code']!,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(course['name']!),
        childrenPadding: const EdgeInsets.fromLTRB(
          20,
          0,
          20,
          18,
        ),
        children: [
          _info(
            context,
            Icons.credit_score_rounded,
            course['credits']!,
          ),
          _info(
            context,
            Icons.person_rounded,
            course['lecturer']!,
          ),
          _info(
            context,
            Icons.schedule_rounded,
            course['schedule']!,
          ),
        ],
      ),
    );
  }

  Widget _info(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: colors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
