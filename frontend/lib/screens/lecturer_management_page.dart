import 'package:flutter/material.dart';

import '../services/api_service.dart';

class LecturerManagementPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const LecturerManagementPage({super.key, required this.user});

  @override
  State<LecturerManagementPage> createState() => _LecturerManagementPageState();
}

class _LecturerManagementPageState extends State<LecturerManagementPage> {
  List<dynamic> _lecturers = [];
  List<dynamic> _filteredLecturers = [];

  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLecturers();

    _searchController.addListener(_filterLecturers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLecturers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = widget.user['access_token'] as String;

      final lecturers = await ApiService.getAdminLecturers(token);

      if (!mounted) return;

      setState(() {
        _lecturers = lecturers;
        _filteredLecturers = lecturers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterLecturers() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _filteredLecturers = List<dynamic>.from(_lecturers);
        return;
      }

      _filteredLecturers = _lecturers.where((lecturer) {
        final name = (lecturer['full_name'] ?? '').toString().toLowerCase();

        final email = (lecturer['email'] ?? '').toString().toLowerCase();

        final number = (lecturer['lecturer_number'] ?? '')
            .toString()
            .toLowerCase();

        final department = (lecturer['department'] ?? '')
            .toString()
            .toLowerCase();

        return name.contains(query) ||
            email.contains(query) ||
            number.contains(query) ||
            department.contains(query);
      }).toList();
    });
  }

  Future<void> _showLecturerForm({Map<String, dynamic>? lecturer}) async {
    final isEditing = lecturer != null;

    final fullNameController = TextEditingController(
      text: lecturer?['full_name']?.toString() ?? '',
    );

    final emailController = TextEditingController(
      text: lecturer?['email']?.toString() ?? '',
    );

    final passwordController = TextEditingController();

    final lecturerNumberController = TextEditingController(
      text: lecturer?['lecturer_number']?.toString() ?? '',
    );

    final departmentController = TextEditingController(
      text: lecturer?['department']?.toString() ?? '',
    );

    final phoneController = TextEditingController(
      text: lecturer?['phone']?.toString() ?? '',
    );

    final specializationController = TextEditingController(
      text: lecturer?['specialization']?.toString() ?? '',
    );

    final hireDateController = TextEditingController(
      text: lecturer?['hire_date']?.toString() ?? '',
    );

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Lecturer' : 'Add Lecturer'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: fullNameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter email';
                            }

                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }

                            return null;
                          },
                        ),
                        if (!isEditing) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter password';
                              }

                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }

                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: lecturerNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Lecturer Number',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter lecturer number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: departmentController,
                          decoration: const InputDecoration(
                            labelText: 'Department',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter department';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: specializationController,
                          decoration: const InputDecoration(
                            labelText: 'Specialization',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: hireDateController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Hire Date',
                            hintText: 'YYYY-MM-DD',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            DateTime initialDate = DateTime.now();

                            if (hireDateController.text.isNotEmpty) {
                              try {
                                initialDate = DateTime.parse(
                                  hireDateController.text,
                                );
                              } catch (_) {}
                            }

                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: DateTime(1950),
                              lastDate: DateTime(2100),
                            );

                            if (selectedDate != null) {
                              final month = selectedDate.month
                                  .toString()
                                  .padLeft(2, '0');

                              final day = selectedDate.day.toString().padLeft(
                                2,
                                '0',
                              );

                              hireDateController.text =
                                  '${selectedDate.year}-$month-$day';
                            }
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Select hire date';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            final token = widget.user['access_token'] as String;

                            final data = {
                              'full_name': fullNameController.text.trim(),
                              'email': emailController.text.trim(),
                              'lecturer_number': lecturerNumberController.text
                                  .trim(),
                              'department': departmentController.text.trim(),
                              'phone': phoneController.text.trim(),
                              'specialization':
                                  specializationController.text.trim().isEmpty
                                  ? null
                                  : specializationController.text.trim(),
                              'hire_date': hireDateController.text.trim(),
                            };

                            if (isEditing) {
                              await ApiService.updateLecturer(
                                token,
                                lecturer['id'] as int,
                                data,
                              );
                            } else {
                              data['password'] = passwordController.text;

                              await ApiService.createLecturer(token, data);
                            }

                            if (!mounted || !dialogContext.mounted) return;

                            Navigator.of(dialogContext).pop(true);

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEditing
                                      ? 'Lecturer updated successfully.'
                                      : 'Lecturer created successfully.',
                                ),
                              ),
                            );

                            await _loadLecturers();
                          } catch (e) {
                            if (!mounted) return;

                            setDialogState(() {
                              isSaving = false;
                            });

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditing ? 'Update' : 'Create'),
                ),
              ],
            );
          },
        );
      },
    );

    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    lecturerNumberController.dispose();
    departmentController.dispose();
    phoneController.dispose();
    specializationController.dispose();
    hireDateController.dispose();

    if (result == true) {
      await _loadLecturers();
    }
  }

  Future<void> _deleteLecturer(Map<String, dynamic> lecturer) async {
    final lecturerId = lecturer['id'] as int;
    final lecturerName = lecturer['full_name']?.toString() ?? 'this lecturer';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Lecturer'),
          content: Text(
            'Are you sure you want to delete $lecturerName?\n\n'
            'This will also remove the lecturer account and subject assignments.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final token = widget.user['access_token'] as String;

      await ApiService.deleteLecturer(token, lecturerId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lecturer deleted successfully.')),
      );

      await _loadLecturers();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget _buildLecturerCard(Map<String, dynamic> lecturer) {
    final name = lecturer['full_name']?.toString() ?? 'Unknown';

    final email = lecturer['email']?.toString() ?? '';

    final lecturerNumber = lecturer['lecturer_number']?.toString() ?? '';

    final department = lecturer['department']?.toString() ?? '';

    final phone = lecturer['phone']?.toString() ?? '';

    final specialization = lecturer['specialization']?.toString() ?? '';

    final hireDate = lecturer['hire_date']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'L',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(email),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      Text('ID: $lecturerNumber'),
                      Text('Department: $department'),
                      Text('Phone: $phone'),
                      if (specialization.isNotEmpty)
                        Text('Specialization: $specialization'),
                      Text('Hire Date: $hireDate'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                IconButton(
                  tooltip: 'Edit Lecturer',
                  onPressed: () => _showLecturerForm(lecturer: lecturer),
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  tooltip: 'Delete Lecturer',
                  onPressed: () => _deleteLecturer(lecturer),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadLecturers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search lecturers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 48),
                          const SizedBox(height: 12),
                          Text(_errorMessage!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _loadLecturers,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _filteredLecturers.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_search, size: 56),
                          SizedBox(height: 12),
                          Text(
                            'No lecturers found.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadLecturers,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _filteredLecturers.length,
                        itemBuilder: (context, index) {
                          return _buildLecturerCard(
                            _filteredLecturers[index] as Map<String, dynamic>,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLecturerForm(),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Lecturer'),
      ),
    );
  }
}
