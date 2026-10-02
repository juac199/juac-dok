import 'package:flutter/material.dart';

import '../services/api_service.dart';

class SubjectManagementPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const SubjectManagementPage({super.key, required this.user});

  @override
  State<SubjectManagementPage> createState() => _SubjectManagementPageState();
}

class _SubjectManagementPageState extends State<SubjectManagementPage> {
  List<dynamic> _subjects = [];
  List<dynamic> _filteredSubjects = [];

  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSubjects();
    _searchController.addListener(_filterSubjects);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = widget.user['access_token'] as String;

      final subjects = await ApiService.getSubjects(token);

      if (!mounted) return;

      setState(() {
        _subjects = subjects;
        _filteredSubjects = subjects;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _filterSubjects() {
    final query = _searchController.text.trim().toLowerCase();

    if (!mounted) return;

    setState(() {
      if (query.isEmpty) {
        _filteredSubjects = _subjects;
        return;
      }

      _filteredSubjects = _subjects.where((subject) {
        final code = subject['subject_code']?.toString().toLowerCase() ?? '';

        final name = subject['subject_name']?.toString().toLowerCase() ?? '';

        final description =
            subject['description']?.toString().toLowerCase() ?? '';

        return code.contains(query) ||
            name.contains(query) ||
            description.contains(query);
      }).toList();
    });
  }

  Future<void> _showSubjectForm({Map<String, dynamic>? subject}) async {
    final bool isEditing = subject != null;

    final codeController = TextEditingController(
      text: subject?['subject_code']?.toString() ?? '',
    );

    final nameController = TextEditingController(
      text: subject?['subject_name']?.toString() ?? '',
    );

    final creditController = TextEditingController(
      text: subject?['credit_hours']?.toString() ?? '',
    );

    final descriptionController = TextEditingController(
      text: subject?['description']?.toString() ?? '',
    );

    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> saveSubject() async {
              if (!formKey.currentState!.validate()) {
                return;
              }

              setDialogState(() {
                isSaving = true;
              });

              try {
                final token = widget.user['access_token'] as String;

                final subjectData = {
                  'subject_code': codeController.text.trim(),
                  'subject_name': nameController.text.trim(),
                  'credit_hours': int.parse(creditController.text.trim()),
                  'description': descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                };

                if (isEditing) {
                  await ApiService.updateSubject(
                    token,
                    subject['id'] as int,
                    subjectData,
                  );
                } else {
                  await ApiService.createSubject(token, subjectData);
                }

                if (!dialogContext.mounted) return;

                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing
                          ? 'Subject updated successfully.'
                          : 'Subject created successfully.',
                    ),
                  ),
                );

                await _loadSubjects();
              } catch (e) {
                if (!context.mounted) return;

                setDialogState(() {
                  isSaving = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                  ),
                );
              }
            }

            return AlertDialog(
              title: Text(isEditing ? 'Edit Subject' : 'Add Subject'),
              content: SizedBox(
                width: 450,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: codeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Subject Code',
                            hintText: 'Example: CSC301',
                            prefixIcon: Icon(Icons.code),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter subject code';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Subject Name',
                            hintText: 'Example: Database Systems',
                            prefixIcon: Icon(Icons.menu_book_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter subject name';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: creditController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Credit Hours',
                            hintText: 'Example: 3',
                            prefixIcon: Icon(Icons.school_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final credits = int.tryParse(value ?? '');

                            if (credits == null || credits <= 0) {
                              return 'Enter valid credit hours';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Enter subject description',
                            prefixIcon: Icon(Icons.description_outlined),
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
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
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: isSaving ? null : saveSubject,
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(isSaving ? 'Saving...' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    codeController.dispose();
    nameController.dispose();
    creditController.dispose();
    descriptionController.dispose();
  }

  Future<void> _deleteSubject(Map<String, dynamic> subject) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Subject'),
          content: Text(
            'Are you sure you want to delete '
            '${subject['subject_code']} - '
            '${subject['subject_name']}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final token = widget.user['access_token'] as String;

      await ApiService.deleteSubject(token, subject['id'] as int);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject deleted successfully.')),
      );

      await _loadSubjects();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    final status = subject['status']?.toString() ?? 'active';

    final bool isActive = status == 'active';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.menu_book_outlined, color: Colors.indigo),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        subject['subject_code']?.toString() ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? Colors.green.shade700
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subject['subject_name']?.toString() ?? '-',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule_outlined, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        '${subject['credit_hours']} Credit Hours',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  if (subject['description'] != null &&
                      subject['description'].toString().trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      subject['description'].toString(),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showSubjectForm(subject: subject);
                }

                if (value == 'delete') {
                  _deleteSubject(subject);
                }
              },
              itemBuilder: (context) => const [
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
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Delete'),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 70,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No subjects found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first subject to get started.',
              style: TextStyle(color: Colors.grey.shade600),
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
        title: const Text(
          'Subject Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadSubjects,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showSubjectForm();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by code, name or description...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(_errorMessage!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _loadSubjects,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _filteredSubjects.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadSubjects,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                      itemCount: _filteredSubjects.length,
                      itemBuilder: (context, index) {
                        return _buildSubjectCard(
                          _filteredSubjects[index] as Map<String, dynamic>,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
