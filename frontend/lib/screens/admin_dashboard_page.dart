
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'admin_results_page.dart';
import 'subject_management_page.dart';
import 'lecturer_management_page.dart';
import 'admin_enrollment_management_page.dart';

class AdminDashboardPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminDashboardPage({
    super.key,
    required this.user,
  });

  @override
  State<AdminDashboardPage> createState() =>
      _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<dynamic> students = [];
  List<dynamic> filteredStudents = [];

  bool isLoading = true;
  String searchQuery = '';

  String get token => widget.user['access_token'] as String;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await ApiService.getStudents(token);

      if (!mounted) return;

      setState(() {
        students = data;
        filteredStudents = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(
        'Failed to load students: ${e.toString()}',
        isError: true,
      );
    }
  }

  void _filterStudents(String query) {
    setState(() {
      searchQuery = query.toLowerCase().trim();

      if (searchQuery.isEmpty) {
        filteredStudents = students;
        return;
      }

      filteredStudents = students.where((student) {
        final fullName =
            (student['full_name'] ?? '').toString().toLowerCase();

        final email =
            (student['email'] ?? '').toString().toLowerCase();

        final studentNumber =
            (student['student_number'] ?? '')
                .toString()
                .toLowerCase();

        final program =
            (student['program'] ?? '').toString().toLowerCase();

        return fullName.contains(searchQuery) ||
            email.contains(searchQuery) ||
            studentNumber.contains(searchQuery) ||
            program.contains(searchQuery);
      }).toList();
    });
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  Future<void> _deleteStudent(
    Map<String, dynamic> student,
  ) async {
    final studentId = student['id'] as int;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Student'),
          content: Text(
            'Are you sure you want to delete ${student['full_name']}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await ApiService.deleteStudent(
        token,
        studentId,
      );

      if (!mounted) return;

      _showMessage('Student deleted successfully.');

      await _loadStudents();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to delete student: ${e.toString()}',
        isError: true,
      );
    }
  }

  Future<void> _viewStudent(
    Map<String, dynamic> student,
  ) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Student Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow(
                  'Full Name',
                  student['full_name'],
                ),
                _detailRow(
                  'Email',
                  student['email'],
                ),
                _detailRow(
                  'Student Number',
                  student['student_number'],
                ),
                _detailRow(
                  'Date of Birth',
                  student['date_of_birth'],
                ),
                _detailRow(
                  'Phone',
                  student['phone'],
                ),
                _detailRow(
                  'Address',
                  student['address'],
                ),
                _detailRow(
                  'Program',
                  student['program'],
                ),
                _detailRow(
                  'Enrollment Date',
                  student['enrollment_date'],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(
    String label,
    dynamic value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value?.toString() ?? '-',
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editStudent(
    Map<String, dynamic> student,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStudentPage(
          token: token,
          student: student,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await _loadStudents();

      if (!mounted) return;

      _showMessage('Student updated successfully.');
    }
  }

  Future<void> _addStudent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStudentPage(
          token: token,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await _loadStudents();

      if (!mounted) return;

      _showMessage('Student added successfully.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: isLoading ? null : _loadStudents,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addStudent,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Student'),
      ),
      body: Column(
        children: [
          Padding(
  padding: const EdgeInsets.fromLTRB(
    16,
    16,
    16,
    8,
  ),
  child: Card(
    child: ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.menu_book_outlined),
      ),
      title: const Text(
        'Subject Management',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: const Text(
        'Add, edit, search and delete subjects',
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 18,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectManagementPage(
              user: widget.user,
            ),
          ),
        );
      },
    ),
  ),
),

Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              8,
            ),
            child: Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person_outline),
                ),
                title: const Text(
                  'Lecturer Management',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Add, edit, search and delete lecturers',
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LecturerManagementPage(
                        user: widget.user,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              8,
            ),
            child: Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.how_to_reg_outlined),
                ),
                title: const Text(
                  'Enrollment Management',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Enroll students in subjects and manage registrations',
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AdminEnrollmentManagementPage(
                        user: widget.user,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              8,
            ),
            child: Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.assessment),
                ),
                title: const Text(
                  'Results Management',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'View and publish student results',
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminResultsPage(
                        token: token,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    8,
                  ),
                  child: TextField(
                    onChanged: _filterStudents,
                    decoration: InputDecoration(
                      hintText: 'Search students...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _filterStudents('');
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildStudentList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 70,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'No students found'
                  : 'No students match your search',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            if (searchQuery.isEmpty)
              FilledButton.icon(
                onPressed: _addStudent,
                icon: const Icon(Icons.person_add),
                label: const Text('Add Student'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStudents,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          100,
        ),
        itemCount: filteredStudents.length,
        itemBuilder: (context, index) {
          final student =
              filteredStudents[index] as Map<String, dynamic>;

          return _buildStudentCard(student);
        },
      ),
    );
  }

  Widget _buildStudentCard(
    Map<String, dynamic> student,
  ) {
    final fullName =
        student['full_name']?.toString() ?? 'Unknown Student';

    final email =
        student['email']?.toString() ?? '';

    final studentNumber =
        student['student_number']?.toString() ?? '';

    final program =
        student['program']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              child: Text(
                fullName.isNotEmpty
                    ? fullName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    studentNumber,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (program.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      program,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    _viewStudent(student);
                    break;

                  case 'edit':
                    _editStudent(student);
                    break;

                  case 'delete':
                    _deleteStudent(student);
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility_outlined),
                      SizedBox(width: 10),
                      Text('View'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
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

class AddStudentPage extends StatefulWidget {
  final String token;

  const AddStudentPage({
    super.key,
    required this.token,
  });

  @override
  State<AddStudentPage> createState() =>
      _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final studentNumberController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final programController = TextEditingController();
  final enrollmentDateController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    studentNumberController.dispose();
    dateOfBirthController.dispose();
    phoneController.dispose();
    addressController.dispose();
    programController.dispose();
    enrollmentDateController.dispose();

    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (selectedDate == null) return;

    final month =
        selectedDate.month.toString().padLeft(2, '0');

    final day =
        selectedDate.day.toString().padLeft(2, '0');

    controller.text =
        '${selectedDate.year}-$month-$day';
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService.createStudent(
        widget.token,
        {
          'full_name': fullNameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text,
          'student_number':
              studentNumberController.text.trim(),
          'date_of_birth':
              dateOfBirthController.text.trim(),
          'phone': phoneController.text.trim(),
          'address': addressController.text.trim(),
          'program': programController.text.trim(),
          'enrollment_date':
              enrollmentDateController.text.trim(),
        },
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create student: ${e.toString()}',
          ),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  InputDecoration _decoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  String? _requiredValidator(
    String? value,
  ) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Student',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: fullNameController,
              validator: _requiredValidator,
              decoration: _decoration(
                'Full Name',
                Icons.person_outline,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: emailController,
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Email is required';
                }

                if (!value.contains('@')) {
                  return 'Enter a valid email';
                }

                return null;
              },
              keyboardType:
                  TextInputType.emailAddress,
              decoration: _decoration(
                'Email',
                Icons.email_outlined,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }

                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }

                return null;
              },
              obscureText: true,
              decoration: _decoration(
                'Password',
                Icons.lock_outline,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: studentNumberController,
              validator: _requiredValidator,
              decoration: _decoration(
                'Student Number',
                Icons.badge_outlined,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: dateOfBirthController,
              readOnly: true,
              validator: _requiredValidator,
              onTap: () {
                _selectDate(
                  context,
                  dateOfBirthController,
                );
              },
              decoration: _decoration(
                'Date of Birth',
                Icons.calendar_today_outlined,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: phoneController,
              validator: _requiredValidator,
              keyboardType: TextInputType.phone,
              decoration: _decoration(
                'Phone',
                Icons.phone_outlined,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: addressController,
              validator: _requiredValidator,
              maxLines: 2,
              decoration: _decoration(
                'Address',
                Icons.home_outlined,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: programController,
              validator: _requiredValidator,
              decoration: _decoration(
                'Program',
                Icons.school_outlined,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: enrollmentDateController,
              readOnly: true,
              validator: _requiredValidator,
              onTap: () {
                _selectDate(
                  context,
                  enrollmentDateController,
                );
              },
              decoration: _decoration(
                'Enrollment Date',
                Icons.event_outlined,
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed:
                    isLoading ? null : _saveStudent,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  isLoading
                      ? 'Creating...'
                      : 'Create Student',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditStudentPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic> student;

  const EditStudentPage({
    super.key,
    required this.token,
    required this.student,
  });

  @override
  State<EditStudentPage> createState() =>
      _EditStudentPageState();
}

class _EditStudentPageState
    extends State<EditStudentPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController fullNameController;
  late final TextEditingController emailController;
  late final TextEditingController studentNumberController;
  late final TextEditingController dateOfBirthController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;
  late final TextEditingController programController;
  late final TextEditingController enrollmentDateController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    fullNameController = TextEditingController(
      text: widget.student['full_name']?.toString() ?? '',
    );

    emailController = TextEditingController(
      text: widget.student['email']?.toString() ?? '',
    );

    studentNumberController = TextEditingController(
      text:
          widget.student['student_number']?.toString() ?? '',
    );

    dateOfBirthController = TextEditingController(
      text:
          widget.student['date_of_birth']?.toString() ?? '',
    );

    phoneController = TextEditingController(
      text: widget.student['phone']?.toString() ?? '',
    );

    addressController = TextEditingController(
      text: widget.student['address']?.toString() ?? '',
    );

    programController = TextEditingController(
      text: widget.student['program']?.toString() ?? '',
    );

    enrollmentDateController =
        TextEditingController(
      text:
          widget.student['enrollment_date']?.toString() ??
              '',
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    studentNumberController.dispose();
    dateOfBirthController.dispose();
    phoneController.dispose();
    addressController.dispose();
    programController.dispose();
    enrollmentDateController.dispose();

    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      initialDate: DateTime.tryParse(
            controller.text,
          ) ??
          DateTime.now(),
    );

    if (selectedDate == null) return;

    final month =
        selectedDate.month.toString().padLeft(2, '0');

    final day =
        selectedDate.day.toString().padLeft(2, '0');

    controller.text =
        '${selectedDate.year}-$month-$day';
  }

  Future<void> _updateStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final studentId = widget.student['id'] as int;

      await ApiService.updateStudent(
        widget.token,
        studentId,
        {
          'full_name':
              fullNameController.text.trim(),
          'email':
              emailController.text.trim(),
          'student_number':
              studentNumberController.text.trim(),
          'date_of_birth':
              dateOfBirthController.text.trim(),
          'phone':
              phoneController.text.trim(),
          'address':
              addressController.text.trim(),
          'program':
              programController.text.trim(),
          'enrollment_date':
              enrollmentDateController.text.trim(),
        },
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update student: ${e.toString()}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration _decoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  String? _requiredValidator(
    String? value,
  ) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Student',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: fullNameController,
              validator: _requiredValidator,
              decoration: _decoration(
                'Full Name',
                Icons.person_outline,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: emailController,
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Email is required';
                }

                if (!value.contains('@')) {
                  return 'Enter a valid email';
                }

                return null;
              },
              keyboardType:
                  TextInputType.emailAddress,
              decoration: _decoration(
                'Email',
                Icons.email_outlined,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: studentNumberController,
              validator: _requiredValidator,
              decoration: _decoration(
                'Student Number',
                Icons.badge_outlined,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: dateOfBirthController,
              readOnly: true,
              validator: _requiredValidator,
              onTap: () {
                _selectDate(
                  context,
                  dateOfBirthController,
                );
              },
              decoration: _decoration(
                'Date of Birth',
                Icons.calendar_today_outlined,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: phoneController,
              validator: _requiredValidator,
              keyboardType: TextInputType.phone,
              decoration: _decoration(
                'Phone',
                Icons.phone_outlined,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: addressController,
              validator: _requiredValidator,
              maxLines: 2,
              decoration: _decoration(
                'Address',
                Icons.home_outlined,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: programController,
              validator: _requiredValidator,
              decoration: _decoration(
                'Program',
                Icons.school_outlined,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: enrollmentDateController,
              readOnly: true,
              validator: _requiredValidator,
              onTap: () {
                _selectDate(
                  context,
                  enrollmentDateController,
                );
              },
              decoration: _decoration(
                'Enrollment Date',
                Icons.event_outlined,
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed:
                    isLoading ? null : _updateStudent,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  isLoading
                      ? 'Updating...'
                      : 'Update Student',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
