import 'package:flutter/material.dart';

import '../services/api_service.dart';

class SubjectManagementPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const SubjectManagementPage({
    super.key,
    required this.user,
  });

  @override
  State<SubjectManagementPage> createState() =>
      _SubjectManagementPageState();
}

class _SubjectManagementPageState
    extends State<SubjectManagementPage> {
  List<dynamic> _subjects = [];
  List<dynamic> _filteredSubjects = [];

  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_filterSubjects);
    _loadSubjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

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
        _errorMessage =
            e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _filterSubjects() {
    final query =
        _searchController.text.trim().toLowerCase();

    if (!mounted) return;

    setState(() {
      if (query.isEmpty) {
        _filteredSubjects = _subjects;
        return;
      }

      _filteredSubjects = _subjects.where((subject) {
        final code =
            subject['subject_code']?.toString().toLowerCase() ?? '';

        final name =
            subject['subject_name']?.toString().toLowerCase() ?? '';

        final description =
            subject['description']?.toString().toLowerCase() ?? '';

        return code.contains(query) ||
            name.contains(query) ||
            description.contains(query);
      }).toList();
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _showSubjectForm({
    Map<String, dynamic>? subject,
  }) async {
    final bool isEditing = subject != null;

    final formKey = GlobalKey<FormState>();

    final codeController = TextEditingController(
      text: isEditing
          ? subject['subject_code']?.toString() ?? ''
          : '',
    );

    final nameController = TextEditingController(
      text: isEditing
          ? subject['subject_name']?.toString() ?? ''
          : '',
    );

    final creditController = TextEditingController(
      text: isEditing
          ? subject['credit_hours']?.toString() ?? ''
          : '',
    );

    final descriptionController = TextEditingController(
      text: isEditing
          ? subject['description']?.toString() ?? ''
          : '',
    );

    bool isSaving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: !isSaving,
      builder: (dialogContext) {
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
                final token =
                    widget.user['access_token'] as String;

                final subjectData = {
                  'subject_code':
                      codeController.text.trim(),
                  'subject_name':
                      nameController.text.trim(),
                  'credit_hours': int.parse(
                    creditController.text.trim(),
                  ),
                  'description':
                      descriptionController.text.trim().isEmpty
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
                  await ApiService.createSubject(
                    token,
                    subjectData,
                  );
                }

                if (!dialogContext.mounted) return;

                Navigator.of(dialogContext).pop();

                if (!mounted) return;

                _showMessage(
                  isEditing
                      ? 'Subject updated successfully.'
                      : 'Subject created successfully.',
                );

                await _loadSubjects();
              } catch (e) {
                if (!mounted) return;

                setDialogState(() {
                  isSaving = false;
                });
                

                _showMessage(
                  e.toString().replaceFirst(
                        'Exception: ',
                        '',
                      ),
                );
              }
            }

            return AlertDialog(
              title: Text(
                isEditing
                    ? 'Edit Subject'
                    : 'Add Subject',
              ),
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
                          textCapitalization:
                              TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Subject Code',
                            hintText: 'e.g. CSC301',
                            prefixIcon:
                                Icon(Icons.code),
                            border:
                                OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter subject code';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Subject Name',
                            hintText:
                                'e.g. Database Systems',
                            prefixIcon:
                                Icon(Icons.book_outlined),
                            border:
                                OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter subject name';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: creditController,
                          keyboardType:
                              TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Credit Hours',
                            hintText: 'e.g. 3',
                            prefixIcon:
                                Icon(Icons.schedule),
                            border:
                                OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter credit hours';
                            }

                            final credits =
                                int.tryParse(
                              value.trim(),
                            );

                            if (credits == null ||
                                credits <= 0) {
                              return 'Enter a valid number';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller:
                              descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText:
                                'Enter subject description',
                            prefixIcon:
                                Icon(Icons.description_outlined),
                            border:
                                OutlineInputBorder(),
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
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : saveSubject,
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEditing
                              ? 'Update'
                              : 'Create',
                        ),
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

  Future<void> _deleteSubject(
    Map<String, dynamic> subject,
  ) async {
    final subjectId = subject['id'] as int;
    final subjectCode =
        subject['subject_code']?.toString() ?? '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Subject'),
          content: Text(
            'Are you sure you want to delete '
            '$subjectCode?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
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
      final token =
          widget.user['access_token'] as String;

      await ApiService.deleteSubject(
        token,
        subjectId,
      );

      if (!mounted) return;

      _showMessage(
        'Subject deleted successfully.',
      );

      await _loadSubjects();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  void _showSubjectDetails(
    Map<String, dynamic> subject,
  ) {
    final code =
        subject['subject_code']?.toString() ?? '-';

    final name =
        subject['subject_name']?.toString() ?? '-';

    final credits =
        subject['credit_hours']?.toString() ?? '-';

    final description =
        subject['description']?.toString() ?? '';

    final status =
        subject['status']?.toString() ?? 'active';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            '$code - $name',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _detailRow(
                'Subject Code',
                code,
              ),
              _detailRow(
                'Subject Name',
                name,
              ),
              _detailRow(
                'Credit Hours',
                credits,
              ),
              _detailRow(
                'Status',
                status.toUpperCase(),
              ),
              if (description.isNotEmpty)
                _detailRow(
                  'Description',
                  description,
                ),
            ],
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
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(
    Map<String, dynamic> subject,
  ) {
    final code =
        subject['subject_code']?.toString() ?? '-';

    final name =
        subject['subject_name']?.toString() ?? '-';

    final credits =
        subject['credit_hours']?.toString() ?? '-';

    final description =
        subject['description']?.toString() ?? '';

    final status =
        subject['status']?.toString() ?? 'active';

    final isActive = status == 'active';

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(
                  alpha: 0.1,
                ),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        code,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green
                                  .withValues(
                                  alpha: 0.1,
                                )
                              : Colors.red
                                  .withValues(
                                  alpha: 0.1,
                                ),
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                FontWeight.bold,
                            color: isActive
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$credits credit hours',
                    style: TextStyle(
                      color:
                          Colors.grey.shade700,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'view') {
                  _showSubjectDetails(subject);
                } else if (value == 'edit') {
                  _showSubjectForm(
                    subject: subject,
                  );
                } else if (value == 'delete') {
                  _deleteSubject(subject);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'view',
                  child: ListTile(
                    leading:
                        Icon(Icons.visibility_outlined),
                    title: Text('View'),
                    contentPadding:
                        EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    leading:
                        Icon(Icons.edit_outlined),
                    title: Text('Edit'),
                    contentPadding:
                        EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading:
                        Icon(Icons.delete_outline),
                    title: Text('Delete'),
                    contentPadding:
                        EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load subjects',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _loadSubjects,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredSubjects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 70,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                _subjects.isEmpty
                    ? 'No subjects found'
                    : 'No matching subjects',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _subjects.isEmpty
                    ? 'Add your first subject to get started.'
                    : 'Try a different search term.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSubjects,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _filteredSubjects.length,
        itemBuilder: (context, index) {
          final subject =
              _filteredSubjects[index]
                  as Map<String, dynamic>;

          return _buildSubjectCard(subject);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Subject Management',
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadSubjects,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              8,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    'Search subjects...',
                prefixIcon:
                    const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                            },
                            icon: const Icon(
                              Icons.clear,
                            ),
                          ),
                border:
                    const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          _showSubjectForm();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
    );
  }
}