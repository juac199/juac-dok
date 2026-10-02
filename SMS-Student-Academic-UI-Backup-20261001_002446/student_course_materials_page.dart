import 'package:flutter/material.dart';

class StudentCourseMaterialsPage extends StatelessWidget {
  const StudentCourseMaterialsPage({super.key});

  final List<Map<String, dynamic>> materials = const [
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
        title: const Text('Course Materials'),
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
                    child: Icon(Icons.folder_copy_rounded, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Learning Resources',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Access course notes, tutorials and assignments.',
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
          ...materials.map(
            (course) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.menu_book_rounded),
                ),
                title: Text(
                  course['code'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(course['name'] as String),
                children: [
                  for (final item in course['items'] as List<String>)
                    ListTile(
                      leading: const Icon(Icons.insert_drive_file_outlined),
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
            ),
          ),
        ],
      ),
    );
  }
}
