
import 'package:flutter/material.dart';

class StudentCourseMaterialsPage extends StatelessWidget {
  const StudentCourseMaterialsPage({super.key});

  static const materials = [
    {
      'code': 'CSC301',
      'name': 'Database Systems',
      'items': [
        'Lecture Notes — Relational Databases',
        'Tutorial — SQL Queries',
        'Assignment — Database Design',
      ],
    },
    {
      'code': 'CSC302',
      'name': 'Computer Networks',
      'items': [
        'Lecture Notes — Network Models',
        'Lab Guide — Routing',
        'Tutorial — IP Addressing',
      ],
    },
    {
      'code': 'CSC303',
      'name': 'Software Engineering',
      'items': [
        'Lecture Notes — SDLC',
        'Tutorial — Requirements Engineering',
        'Assignment — System Design',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Course Materials',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
        children: [
          _hero(context),
          const SizedBox(height: 18),
          ...materials.map(
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
              Icons.folder_copy_rounded,
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
                  'Learning Resources',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Access notes, tutorials and assignments.',
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
    Map<String, dynamic> course,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(),
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          child: Icon(
            Icons.menu_book_rounded,
            color: colors.primary,
          ),
        ),
        title: Text(
          course['code'] as String,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(course['name'] as String),
        children: [
          for (final item in course['items'] as List<String>)
            ListTile(
              leading: Icon(
                Icons.insert_drive_file_outlined,
                color: colors.primary,
              ),
              title: Text(item),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$item will be connected to the document service.',
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
