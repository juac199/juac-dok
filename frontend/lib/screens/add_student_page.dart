import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AddStudentPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const AddStudentPage({
    super.key,
    required this.user,
  });

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _programController = TextEditingController();
  final _enrollmentDateController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  DateTime? _dateOfBirth;
  DateTime? _enrollmentDate;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _studentNumberController.dispose();
    _dateOfBirthController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _programController.dispose();
    _enrollmentDateController.dispose();

    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _dateOfBirth = selectedDate;
      _dateOfBirthController.text = _formatDate(selectedDate);
    });
  }

  Future<void> _selectEnrollmentDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _enrollmentDate = selectedDate;
      _enrollmentDateController.text =
          _formatDate(selectedDate);
    });
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<void> _createStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateOfBirth == null) {
      _showMessage('Please select the date of birth.');
      return;
    }

    if (_enrollmentDate == null) {
      _showMessage('Please select the enrollment date.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = widget.user['access_token'];

      final student = {
        'full_name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'student_number':
            _studentNumberController.text.trim(),
        'date_of_birth': _formatDate(_dateOfBirth!),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'program': _programController.text.trim(),
        'enrollment_date':
            _formatDate(_enrollmentDate!),
      };

      await ApiService.createStudent(
        token,
        student,
      );

      if (!mounted) return;

      _showMessage(
        'Student created successfully.',
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }

    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }

    if (!value.contains('@')) {
      return 'Enter a valid email address.';
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 800,
            ),
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Student Information',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Enter the student details below.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // FULL NAME
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        hint: 'Enter full name',
                        validator: _requiredValidator,
                      ),

                      const SizedBox(height: 18),

                      // EMAIL
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        hint: 'student@example.com',
                        keyboardType:
                            TextInputType.emailAddress,
                        validator: _emailValidator,
                      ),

                      const SizedBox(height: 18),

                      // PASSWORD
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        hint: 'Create student password',
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Password is required.';
                          }

                          if (value.length < 8) {
                            return 'Password must be at least 8 characters.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // STUDENT NUMBER
                      _buildTextField(
                        controller:
                            _studentNumberController,
                        label: 'Student Number',
                        icon: Icons.badge_outlined,
                        hint: 'e.g. STU001',
                        validator: _requiredValidator,
                      ),

                      const SizedBox(height: 18),

                      // DATE OF BIRTH
                      TextFormField(
                        controller:
                            _dateOfBirthController,
                        readOnly: true,
                        validator: (value) {
                          if (_dateOfBirth == null) {
                            return 'Date of birth is required.';
                          }

                          return null;
                        },
                        onTap: _selectDateOfBirth,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          prefixIcon:
                              Icon(Icons.calendar_today),
                          suffixIcon:
                              Icon(Icons.arrow_drop_down),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // PHONE
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        icon: Icons.phone_outlined,
                        hint: '+60 12 345 6789',
                        keyboardType: TextInputType.phone,
                        validator: _requiredValidator,
                      ),

                      const SizedBox(height: 18),

                      // ADDRESS
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        icon: Icons.home_outlined,
                        hint: 'Enter student address',
                        maxLines: 3,
                        validator: _requiredValidator,
                      ),

                      const SizedBox(height: 18),

                      // PROGRAM
                      _buildTextField(
                        controller: _programController,
                        label: 'Program',
                        icon: Icons.school_outlined,
                        hint:
                            'e.g. Bachelor of Computer Science',
                        validator: _requiredValidator,
                      ),

                      const SizedBox(height: 18),

                      // ENROLLMENT DATE
                      TextFormField(
                        controller:
                            _enrollmentDateController,
                        readOnly: true,
                        validator: (value) {
                          if (_enrollmentDate == null) {
                            return 'Enrollment date is required.';
                          }

                          return null;
                        },
                        onTap: _selectEnrollmentDate,
                        decoration: const InputDecoration(
                          labelText: 'Enrollment Date',
                          prefixIcon:
                              Icon(Icons.event_outlined),
                          suffixIcon:
                              Icon(Icons.arrow_drop_down),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // BUTTONS
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      Navigator.pop(
                                        context,
                                      );
                                    },
                              style: OutlinedButton.styleFrom(
                                minimumSize:
                                    const Size.fromHeight(
                                  52,
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : _createStudent,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person_add,
                                    ),
                              label: Text(
                                _isLoading
                                    ? 'Creating...'
                                    : 'Create Student',
                              ),
                              style: FilledButton.styleFrom(
                                minimumSize:
                                    const Size.fromHeight(
                                  52,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}