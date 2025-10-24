import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/models/uniform_model.dart';
import 'package:schmgtsystem/models/class_metrics_model.dart';
import 'package:schmgtsystem/repository/uniform_repository.dart';
import 'package:schmgtsystem/providers/class_provider.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';

class UniformManagementScreen extends StatefulWidget {
  const UniformManagementScreen({super.key});

  @override
  State<UniformManagementScreen> createState() =>
      _UniformManagementScreenState();
}

class _UniformManagementScreenState extends State<UniformManagementScreen> {
  final UniformRepository _uniformRepository = UniformRepository();
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  Class? _selectedClass;
  List<UniformModel> _uniforms = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // New state for overview
  List<ClassWithUniforms> _allClassesWithUniforms = [];
  bool _isLoadingOverview = false;
  bool _showOverview = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClasses();
      _loadAllClassesUniforms();
    });
  }

  Future<void> _loadClasses() async {
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    await classProvider.getAllClassesWithMetric(context);
  }

  Future<void> _loadAllClassesUniforms() async {
    setState(() {
      _isLoadingOverview = true;
    });

    try {
      final response = await _uniformRepository.getAllClassesUniforms();
      if (response.success && response.data != null) {
        setState(() {
          _allClassesWithUniforms = response.data!;
        });
      } else {
        if (mounted) {
          CustomToastNotification.show(response.message, type: ToastType.error);
        }
      }
    } catch (e) {
      if (mounted) {
        CustomToastNotification.show(
          'Error loading classes uniforms: $e',
          type: ToastType.error,
        );
      }
    } finally {
      setState(() {
        _isLoadingOverview = false;
      });
    }
  }

  Future<void> _loadUniforms(String classId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _uniformRepository.getUniforms(classId);
      if (response.success && response.data != null) {
        setState(() {
          _uniforms = response.data!;
        });
      } else {
        if (mounted) {
          CustomToastNotification.show(response.message, type: ToastType.error);
        }
      }
    } catch (e) {
      if (mounted) {
        CustomToastNotification.show(
          'Error loading uniforms: $e',
          type: ToastType.error,
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addOrUpdateUniform(String day, String uniform) async {
    if (_selectedClass == null) return;

    try {
      final response = await _uniformRepository.addUniform(
        _selectedClass!.id ?? '',
        day,
        uniform,
      );

      if (response.success) {
        if (mounted) {
          CustomToastNotification.show(
            response.message,
            type: ToastType.success,
          );
        }
        _loadUniforms(_selectedClass!.id ?? '');
      } else {
        if (mounted) {
          CustomToastNotification.show(response.message, type: ToastType.error);
        }
      }
    } catch (e) {
      if (mounted) {
        CustomToastNotification.show(
          'Error saving uniform: $e',
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _deleteUniform(String day) async {
    if (_selectedClass == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Uniform'),
            content: Text(
              'Are you sure you want to delete the uniform for $day?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      final response = await _uniformRepository.deleteUniform(
        _selectedClass!.id ?? '',
        day,
      );

      if (response.success) {
        if (mounted) {
          CustomToastNotification.show(
            response.message,
            type: ToastType.success,
          );
        }
        _loadUniforms(_selectedClass!.id ?? '');
      } else {
        if (mounted) {
          CustomToastNotification.show(response.message, type: ToastType.error);
        }
      }
    } catch (e) {
      if (mounted) {
        CustomToastNotification.show(
          'Error deleting uniform: $e',
          type: ToastType.error,
        );
      }
    }
  }

  void _showUniformDialog(String day, {String? existingUniform}) {
    final controller = TextEditingController(text: existingUniform ?? '');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              existingUniform != null ? 'Edit Uniform' : 'Add Uniform',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day: $day',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Uniform Description',
                    hintText: 'e.g., White shirt with blue pants',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    Navigator.of(context).pop();
                    _addOrUpdateUniform(day, controller.text.trim());
                  }
                },
                child: Text(existingUniform != null ? 'Update' : 'Add'),
              ),
            ],
          ),
    );
  }

  List<UniformModel> get _filteredUniforms {
    if (_searchQuery.isEmpty) return _uniforms;
    return _uniforms
        .where(
          (uniform) =>
              uniform.uniform.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              uniform.day.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            setState(() {
              _showOverview = !_showOverview;
              if (_showOverview) {
                _selectedClass = null;
                _uniforms.clear();
              }
            });
          },
          icon: _showOverview ? SizedBox.shrink() : Icon(Icons.cancel),
        ),
        automaticallyImplyLeading: true,
        title: const Text('Uniform Management'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showOverview = !_showOverview;
                if (_showOverview) {
                  _selectedClass = null;
                  _uniforms.clear();
                }
              });
            },
            icon: Icon(_showOverview ? Icons.list : Icons.grid_view),
            tooltip: _showOverview ? 'Show Detail View' : 'Show Overview',
          ),
        ],
      ),
      body:
          _showOverview
              ? _buildOverviewGrid()
              : Consumer<ClassProvider>(
                builder: (context, classProvider, child) {
                  return Column(
                    children: [
                      // Class Selection Card
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_selectedClass?.level} (${_selectedClass?.name})',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // DropdownButtonFormField<Class>(
                            //   value: _selectedClass,
                            //   decoration: const InputDecoration(
                            //     border: OutlineInputBorder(),
                            //     contentPadding: EdgeInsets.symmetric(
                            //       horizontal: 12,
                            //       vertical: 8,
                            //     ),
                            //   ),
                            //   hint: const Text('Choose a class'),
                            //   items:
                            //       (classProvider.classData.classes ?? []).map((
                            //         classModel,
                            //       ) {
                            //         return DropdownMenuItem<Class>(
                            //           value: classModel,
                            //           child: Text(
                            //             '${classModel.level} (${classModel.name ?? ''})',
                            //           ),
                            //         );
                            //       }).toList(),
                            //   onChanged: (Class? newValue) {
                            //     setState(() {
                            //       _selectedClass = newValue;
                            //       _uniforms.clear();
                            //     });
                            //     if (newValue != null) {
                            //       _loadUniforms(newValue.id ?? '');
                            //     }
                            //   },
                            // ),
                          ],
                        ),
                      ),

                      if (_selectedClass != null) ...[
                        // Search and Add Button
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search uniforms...',
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _showAddUniformDialog();
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Uniform'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Uniforms List
                        Expanded(
                          child:
                              _isLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : _filteredUniforms.isEmpty
                                  ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.checkroom_outlined,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          _searchQuery.isNotEmpty
                                              ? 'No uniforms found matching your search'
                                              : 'No uniforms set for this class',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        if (_searchQuery.isEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            'Click "Add Uniform" to get started',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  )
                                  : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    itemCount: _filteredUniforms.length,
                                    itemBuilder: (context, index) {
                                      final uniform = _filteredUniforms[index];
                                      return _buildUniformCard(uniform);
                                    },
                                  ),
                        ),
                      ] else ...[
                        // No class selected state
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.class_,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Select a class to manage uniforms',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
    );
  }

  Widget _buildUniformCard(UniformModel uniform) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color(uniform.dayColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              uniform.dayAbbreviation,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(uniform.dayColor),
                fontSize: 12,
              ),
            ),
          ),
        ),
        title: Text(
          uniform.day,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          uniform.uniform,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showUniformDialog(
                  uniform.day,
                  existingUniform: uniform.uniform,
                );
                break;
              case 'delete':
                _deleteUniform(uniform.day);
                break;
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
        ),
      ),
    );
  }

  void _showAddUniformDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.checkroom,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Add Uniform',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select a day to add uniform for ${_selectedClass?.name ?? ''}:',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Days Grid
                          Expanded(
                            child: GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: _daysOfWeek.length,
                              itemBuilder: (context, index) {
                                final day = _daysOfWeek[index];
                                final hasUniform = _uniforms.any(
                                  (u) => u.day == day,
                                );
                                final uniform = _uniforms.firstWhere(
                                  (u) => u.day == day,
                                  orElse:
                                      () => UniformModel(day: '', uniform: ''),
                                );

                                return GestureDetector(
                                  onTap:
                                      hasUniform
                                          ? () {
                                            Navigator.of(context).pop();
                                            _showUniformDialog(
                                              day,
                                              existingUniform: uniform.uniform,
                                            );
                                          }
                                          : () {
                                            Navigator.of(context).pop();
                                            _showUniformDialog(day);
                                          },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          hasUniform
                                              ? Color(
                                                UniformModel(
                                                  day: day,
                                                  uniform: '',
                                                ).dayColor,
                                              ).withOpacity(0.1)
                                              : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            hasUniform
                                                ? Color(
                                                  UniformModel(
                                                    day: day,
                                                    uniform: '',
                                                  ).dayColor,
                                                ).withOpacity(0.3)
                                                : Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              day,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    hasUniform
                                                        ? Color(
                                                          UniformModel(
                                                            day: day,
                                                            uniform: '',
                                                          ).dayColor,
                                                        )
                                                        : Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              hasUniform
                                                  ? Icons.edit
                                                  : Icons.add,
                                              size: 16,
                                              color:
                                                  hasUniform
                                                      ? Color(
                                                        UniformModel(
                                                          day: day,
                                                          uniform: '',
                                                        ).dayColor,
                                                      )
                                                      : Colors.grey[600],
                                            ),
                                          ],
                                        ),
                                        if (hasUniform) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            uniform.uniform.length > 20
                                                ? '${uniform.uniform.substring(0, 20)}...'
                                                : uniform.uniform,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildOverviewGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.grid_view,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Uniform Overview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Quick overview of uniforms across all classes',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _loadAllClassesUniforms,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Classes Grid
          _isLoadingOverview
              ? const Center(child: CircularProgressIndicator())
              : _allClassesWithUniforms.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.checkroom_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No classes found',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _allClassesWithUniforms.length,
                itemBuilder: (context, index) {
                  final classWithUniforms = _allClassesWithUniforms[index];
                  return _buildClassUniformCard(classWithUniforms);
                },
              ),
        ],
      ),
    );
  }

  Widget _buildClassUniformCard(ClassWithUniforms classWithUniforms) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showOverview = false;
          // Find the corresponding class from ClassProvider
          final classProvider = Provider.of<ClassProvider>(
            context,
            listen: false,
          );
          _selectedClass = classProvider.classData.classes?.firstWhere(
            (c) => c.id == classWithUniforms.id,
            orElse: () => classProvider.classData.classes!.first,
          );
          _uniforms = classWithUniforms.uniforms;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getClassColor(classWithUniforms.level),
                    _getClassColor(classWithUniforms.level).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.class_,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${classWithUniforms.level} (${classWithUniforms.name})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          classWithUniforms.academicYear,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Uniform Status
                    Row(
                      children: [
                        Icon(
                          Icons.checkroom,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Uniforms (${classWithUniforms.uniformsCount}/7)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Days Grid
                    Expanded(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 1,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2,
                            ),
                        itemCount: 7,
                        itemBuilder: (context, dayIndex) {
                          final day = _daysOfWeek[dayIndex];
                          final hasUniform = classWithUniforms.uniforms.any(
                            (u) => u.day == day,
                          );
                          final dayColor = _getDayColor(day);

                          return Container(
                            decoration: BoxDecoration(
                              color:
                                  hasUniform
                                      ? dayColor.withOpacity(0.2)
                                      : dayColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color:
                                    hasUniform
                                        ? dayColor.withOpacity(0.5)
                                        : dayColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child:
                                  hasUniform
                                      ? Icon(
                                        Icons.check,
                                        color: dayColor,
                                        size: 12,
                                      )
                                      : Text(
                                        day.substring(0, 1),
                                        style: TextStyle(
                                          color: dayColor.withOpacity(0.6),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Action Button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _getClassColor(
                          classWithUniforms.level,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getClassColor(
                            classWithUniforms.level,
                          ).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit,
                            size: 14,
                            color: _getClassColor(classWithUniforms.level),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Manage Uniforms',
                            style: TextStyle(
                              color: _getClassColor(classWithUniforms.level),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getClassColor(String level) {
    // Generate consistent colors based on class level
    final colors = [
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFF44336), // Red
      const Color(0xFF607D8B), // Blue Grey
      const Color(0xFF795548), // Brown
      const Color(0xFFE91E63), // Pink
    ];

    final hash = level.hashCode;
    return colors[hash.abs() % colors.length];
  }

  Color _getDayColor(String day) {
    switch (day) {
      case 'Monday':
        return const Color(0xFF2196F3);
      case 'Tuesday':
        return const Color(0xFF4CAF50);
      case 'Wednesday':
        return const Color(0xFFFF9800);
      case 'Thursday':
        return const Color(0xFF9C27B0);
      case 'Friday':
        return const Color(0xFFF44336);
      case 'Saturday':
        return const Color(0xFF607D8B);
      case 'Sunday':
        return const Color(0xFF795548);
      default:
        return Colors.grey;
    }
  }
}
