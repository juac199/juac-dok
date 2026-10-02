import 'package:flutter/material.dart';

class StudentGpaCalculatorPage extends StatefulWidget {
  const StudentGpaCalculatorPage({super.key});

  @override
  State<StudentGpaCalculatorPage> createState() =>
      _StudentGpaCalculatorPageState();
}

class _StudentGpaCalculatorPageState
    extends State<StudentGpaCalculatorPage> {
  final List<_CourseEntry> _courses = [
    _CourseEntry(),
    _CourseEntry(),
  ];

  double get _gpa {
    double totalPoints = 0;
    double totalCredits = 0;

    for (final course in _courses) {
      if (course.gradePoint == null || course.credits <= 0) continue;
      totalPoints += course.gradePoint! * course.credits;
      totalCredits += course.credits;
    }

    if (totalCredits == 0) return 0;
    return totalPoints / totalCredits;
  }

  @override
  void dispose() {
    for (final course in _courses) {
      course.dispose();
    }
    super.dispose();
  }

  void _addCourse() {
    setState(() {
      _courses.add(_CourseEntry());
    });
  }

  void _removeCourse(int index) {
    if (_courses.length <= 1) return;
    setState(() {
      final removed = _courses.removeAt(index);
      removed.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPA Calculator'),
        actions: [
          IconButton(
            tooltip: 'Add course',
            onPressed: _addCourse,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  const Icon(Icons.calculate_rounded, size: 38),
                  const SizedBox(height: 10),
                  const Text(
                    'Semester GPA',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _gpa.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Courses',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _courses.length; i++)
            _courseCard(i, _courses[i]),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addCourse,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Another Course'),
          ),
          const SizedBox(height: 12),
          Text(
            'GPA is calculated from grade point × credit hours.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _courseCard(int index, _CourseEntry course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Course ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                if (_courses.length > 1)
                  IconButton(
                    onPressed: () => _removeCourse(index),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
              ],
            ),
            TextField(
              controller: course.code,
              decoration: const InputDecoration(
                labelText: 'Course Code',
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<double>(
                    value: course.gradePoint,
                    decoration: const InputDecoration(
                      labelText: 'Grade Point',
                    ),
                    items: const [
                      DropdownMenuItem(value: 4.0, child: Text('A — 4.00')),
                      DropdownMenuItem(value: 3.75, child: Text('A- — 3.75')),
                      DropdownMenuItem(value: 3.5, child: Text('B+ — 3.50')),
                      DropdownMenuItem(value: 3.0, child: Text('B — 3.00')),
                      DropdownMenuItem(value: 2.75, child: Text('B- — 2.75')),
                      DropdownMenuItem(value: 2.5, child: Text('C+ — 2.50')),
                      DropdownMenuItem(value: 2.0, child: Text('C — 2.00')),
                      DropdownMenuItem(value: 1.0, child: Text('D — 1.00')),
                      DropdownMenuItem(value: 0.0, child: Text('F — 0.00')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        course.gradePoint = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: course.creditsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Credits',
                    ),
                    onChanged: (value) {
                      setState(() {
                        course.credits =
                            double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseEntry {
  final TextEditingController code = TextEditingController();
  final TextEditingController creditsController =
      TextEditingController(text: '3');

  double? gradePoint;
  double credits = 3;

  void dispose() {
    code.dispose();
    creditsController.dispose();
  }
}
