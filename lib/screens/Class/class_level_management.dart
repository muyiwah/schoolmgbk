import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/models/class_level_model.dart';

class ClassLevelManagementScreen extends ConsumerStatefulWidget {
  const ClassLevelManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ClassLevelManagementScreen> createState() =>
      _ClassLevelManagementScreenState();
}

class _ClassLevelManagementScreenState
    extends ConsumerState<ClassLevelManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All Categories';
  bool _showActiveOnly = false;
  String _sortBy = 'order';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadClassLevels();
  }

  Future<void> _loadClassLevels() async {
    await ref
        .read(RiverpodProvider.classLevelProvider)
        .getAllClassLevels(
          context,
          category:
              _selectedCategory == 'All Categories' ? null : _selectedCategory,
          isActive: _showActiveOnly ? true : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final classLevelProvider = ref.watch(RiverpodProvider.classLevelProvider);
    final classLevels = classLevelProvider.classLevels;
    final isLoading = classLevelProvider.isLoading;
    final error = classLevelProvider.errorMessage;

    return Scaffold(
      backgroundColor: Color(0xFFFAFBFC),
      body: Column(
        children: [
          // Custom App Bar
          Container(
            height: 64,
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(Icons.chevron_left, color: Color(0xFF64748B), size: 20),
                SizedBox(width: 8),
                Text(
                  'Class Management',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Color(0xFF64748B), size: 16),
                SizedBox(width: 8),
                Text(
                  'Class Levels',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showCreateClassLevelDialog(),
                  icon: Icon(Icons.add, size: 16),
                  label: Text(
                    'Add Class Level',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showBulkCreateDialog(),
                  icon: Icon(Icons.add_box, size: 16),
                  label: Text(
                    'Bulk Create',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Class Level Management',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 40),

                  // Stats Cards
                  _buildStatsCards(classLevelProvider.classLevelsResponse),
                  SizedBox(height: 24),

                  // Search and Filter Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFE2E8F0)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Search and Filters Row
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 40,
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (value) => setState(() {}),
                                    decoration: InputDecoration(
                                      hintText: 'Search class levels...',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 14,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Color(0xFF94A3B8),
                                        size: 20,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Color(0xFF6366F1),
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              SizedBox(
                                width: 200,
                                child: Container(
                                  height: 40,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  child: DropdownButton<String>(
                                    value: _selectedCategory,
                                    items:
                                        [
                                              'All Categories',
                                              'Nursery',
                                              'Primary',
                                              'Secondary',
                                              'Higher Secondary',
                                              'Custom',
                                            ]
                                            .map(
                                              (category) => DropdownMenuItem(
                                                value: category,
                                                child: Text(category),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      setState(
                                        () => _selectedCategory = value!,
                                      );
                                      _loadClassLevels();
                                    },
                                    underline: SizedBox(),
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    isExpanded: true,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Container(
                                height: 40,
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _showActiveOnly,
                                      onChanged: (value) {
                                        setState(
                                          () => _showActiveOnly = value!,
                                        );
                                        _loadClassLevels();
                                      },
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    Text(
                                      'Active Only',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: _loadClassLevels,
                                icon: Icon(Icons.refresh, size: 16),
                                label: Text('Refresh'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF64748B),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Class Levels Table
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            border: Border(
                              bottom: BorderSide(color: Color(0xFFE2E8F0)),
                              top: BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildHeaderCell('NAME'),
                              ),
                              Expanded(
                                flex: 2,
                                child: _buildHeaderCell('DISPLAY NAME'),
                              ),
                              Expanded(
                                flex: 2,
                                child: _buildHeaderCell('CATEGORY'),
                              ),
                              Expanded(
                                flex: 1,
                                child: _buildHeaderCell('ORDER'),
                              ),
                              Expanded(
                                flex: 1,
                                child: _buildHeaderCell('STATUS'),
                              ),
                              SizedBox(
                                width: 100,
                                child: _buildHeaderCell('ACTIONS'),
                              ),
                            ],
                          ),
                        ),

                        // Table Content
                        if (isLoading)
                          Container(
                            padding: EdgeInsets.all(40),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          )
                        else if (error != null)
                          Container(
                            padding: EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Color(0xFFEF4444),
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Error loading class levels: $error',
                                    style: TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loadClassLevels,
                                    child: Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (classLevels.isEmpty)
                          Container(
                            padding: EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.school_outlined,
                                    color: Color(0xFF94A3B8),
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No class levels found',
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ..._getFilteredClassLevels(
                            classLevels,
                          ).map((level) => _buildClassLevelRow(level)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ClassLevelsResponseModel? response) {
    if (response == null) {
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Levels',
              '0',
              Color(0xFF3B82F6),
              Icons.school_outlined,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: _buildStatCard(
              'Active Levels',
              '0',
              Color(0xFF10B981),
              Icons.check_circle_outline,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: _buildStatCard(
              'Categories',
              '0',
              Color(0xFFF59E0B),
              Icons.category_outlined,
            ),
          ),
        ],
      );
    }

    // Calculate active count from the actual data if not provided by backend
    int activeCount =
        response.activeCount > 0
            ? response.activeCount
            : response.classLevels.where((level) => level.isActive).length;

    // Calculate unique categories count
    int uniqueCategories =
        response.categoryCounts.isNotEmpty
            ? response.categoryCounts.length
            : response.classLevels
                .map((level) => level.category)
                .toSet()
                .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Levels',
            '${response.totalCount}',
            Color(0xFF3B82F6),
            Icons.school_outlined,
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            'Active Levels',
            '$activeCount',
            Color(0xFF10B981),
            Icons.check_circle_outline,
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            'Categories',
            '$uniqueCategories',
            Color(0xFFF59E0B),
            Icons.category_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color iconColor,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildClassLevelRow(ClassLevelModel level) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (level.description != null) ...[
                  SizedBox(height: 2),
                  Text(
                    level.description!,
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              level.displayName,
              style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getCategoryColor(level.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getCategoryColor(level.category).withOpacity(0.3),
                ),
              ),
              child: Text(
                level.category,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getCategoryColor(level.category),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${level.order}',
              style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    level.isActive
                        ? Color(0xFF10B981).withOpacity(0.1)
                        : Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      level.isActive
                          ? Color(0xFF10B981).withOpacity(0.3)
                          : Color(0xFFEF4444).withOpacity(0.3),
                ),
              ),
              child: Text(
                level.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: level.isActive ? Color(0xFF10B981) : Color(0xFFEF4444),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _showEditClassLevelDialog(level),
                  icon: Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF6366F1),
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showDeleteConfirmationDialog(level),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Color(0xFFEF4444),
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'nursery':
        return Color(0xFF8B5CF6);
      case 'primary':
        return Color(0xFF3B82F6);
      case 'secondary':
        return Color(0xFF10B981);
      case 'higher secondary':
        return Color(0xFFF59E0B);
      case 'custom':
        return Color(0xFFEF4444);
      default:
        return Color(0xFF64748B);
    }
  }

  List<ClassLevelModel> _getFilteredClassLevels(List<ClassLevelModel> levels) {
    List<ClassLevelModel> filtered = levels;

    // Filter by search term
    if (_searchController.text.isNotEmpty) {
      String searchTerm = _searchController.text.toLowerCase();
      filtered =
          filtered
              .where(
                (level) =>
                    level.name.toLowerCase().contains(searchTerm) ||
                    level.displayName.toLowerCase().contains(searchTerm) ||
                    (level.description?.toLowerCase().contains(searchTerm) ??
                        false),
              )
              .toList();
    }

    // Sort
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'displayName':
          comparison = a.displayName.compareTo(b.displayName);
          break;
        case 'category':
          comparison = a.category.compareTo(b.category);
          break;
        case 'order':
          comparison = a.order.compareTo(b.order);
          break;
        default:
          comparison = a.order.compareTo(b.order);
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  void _showCreateClassLevelDialog() {
    showDialog(
      context: context,
      builder:
          (context) => _CreateClassLevelDialog(
            onSave: (data) async {
              bool success = await ref
                  .read(RiverpodProvider.classLevelProvider)
                  .createClassLevel(context, data);
              if (success) {
                Navigator.of(context).pop();
              }
            },
          ),
    );
  }

  void _showEditClassLevelDialog(ClassLevelModel level) {
    showDialog(
      context: context,
      builder:
          (context) => _CreateClassLevelDialog(
            level: level,
            onSave: (data) async {
              bool success = await ref
                  .read(RiverpodProvider.classLevelProvider)
                  .updateClassLevel(context, level.id, data);
              if (success) {
                Navigator.of(context).pop();
              }
            },
          ),
    );
  }

  void _showDeleteConfirmationDialog(ClassLevelModel level) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Class Level'),
            content: Text(
              'Are you sure you want to delete "${level.displayName}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  bool success = await ref
                      .read(RiverpodProvider.classLevelProvider)
                      .deleteClassLevel(context, level.id);
                  if (success) {
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFEF4444),
                ),
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showBulkCreateDialog() {
    showDialog(
      context: context,
      builder:
          (context) => _BulkCreateDialog(
            onSave: (data) async {
              bool success = await ref
                  .read(RiverpodProvider.classLevelProvider)
                  .bulkCreateClassLevels(context, data);
              if (success) {
                Navigator.of(context).pop();
              }
            },
          ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _CreateClassLevelDialog extends StatefulWidget {
  final ClassLevelModel? level;
  final Function(Map<String, dynamic>) onSave;

  const _CreateClassLevelDialog({Key? key, this.level, required this.onSave})
    : super(key: key);

  @override
  State<_CreateClassLevelDialog> createState() =>
      _CreateClassLevelDialogState();
}

class _CreateClassLevelDialogState extends State<_CreateClassLevelDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _orderController = TextEditingController();
  String _selectedCategory = 'Primary';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.level != null) {
      _nameController.text = widget.level!.name;
      _displayNameController.text = widget.level!.displayName;
      _descriptionController.text = widget.level!.description ?? '';
      _orderController.text = widget.level!.order.toString();
      _selectedCategory = widget.level!.category;
      _isActive = widget.level!.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.level == null ? 'Create Class Level' : 'Edit Class Level',
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name (e.g., GRADE1)',
                  hintText: 'Enter unique identifier',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: 'Display Name (e.g., Grade 1)',
                  hintText: 'Enter display name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Display name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          [
                                'Nursery',
                                'Primary',
                                'Secondary',
                                'Higher Secondary',
                                'Custom',
                              ]
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) => setState(() => _selectedCategory = value!),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _orderController,
                      decoration: InputDecoration(
                        labelText: 'Order',
                        hintText: 'Enter order number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Order is required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value!),
                  ),
                  Text('Active'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Map<String, dynamic> data = {
                'name': _nameController.text.toUpperCase(),
                'displayName': _displayNameController.text,
                'description':
                    _descriptionController.text.isEmpty
                        ? null
                        : _descriptionController.text,
                'category': _selectedCategory,
                'order': int.parse(_orderController.text),
                'isActive': _isActive,
              };
              widget.onSave(data);
            }
          },
          child: Text(widget.level == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _displayNameController.dispose();
    _descriptionController.dispose();
    _orderController.dispose();
    super.dispose();
  }
}

class _BulkCreateDialog extends StatefulWidget {
  final Function(BulkCreateClassLevelsModel) onSave;

  const _BulkCreateDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  State<_BulkCreateDialog> createState() => _BulkCreateDialogState();
}

class _BulkCreateDialogState extends State<_BulkCreateDialog> {
  final List<Map<String, dynamic>> _classLevels = [];
  String _selectedCategory = 'Primary';
  int _startOrder = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Bulk Create Class Levels'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                              'Nursery',
                              'Primary',
                              'Secondary',
                              'Higher Secondary',
                              'Custom',
                            ]
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) => setState(() => _selectedCategory = value!),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Start Order',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged:
                        (value) => _startOrder = int.tryParse(value) ?? 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addClassLevel,
              icon: Icon(Icons.add),
              label: Text('Add Class Level'),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _addDefaultLevels,
              icon: Icon(Icons.add_box),
              label: Text('Add Default Levels (Test)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _classLevels.length,
                itemBuilder: (context, index) {
                  final level = _classLevels[index];
                  return Card(
                    child: ListTile(
                      title: Text(level['displayName']),
                      subtitle: Text(
                        '${level['name']} - Order: ${level['order']}',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed:
                            () => setState(() => _classLevels.removeAt(index)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _classLevels.isEmpty
                  ? null
                  : () {
                    // Additional validation before sending
                    if (_classLevels.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please add at least one class level'),
                          backgroundColor: Color(0xFFEF4444),
                        ),
                      );
                      return;
                    }

                    // Validate all levels have required fields
                    bool hasInvalidLevels = _classLevels.any(
                      (level) =>
                          level['name']?.toString().isEmpty == true ||
                          level['displayName']?.toString().isEmpty == true,
                    );

                    if (hasInvalidLevels) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'All levels must have name and display name',
                          ),
                          backgroundColor: Color(0xFFEF4444),
                        ),
                      );
                      return;
                    }

                    widget.onSave(
                      BulkCreateClassLevelsModel(levels: _classLevels),
                    );
                  },
          child: Text('Create ${_classLevels.length} Levels'),
        ),
      ],
    );
  }

  void _addClassLevel() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add Class Level'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name (e.g., GRADE1)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _tempName = value.toUpperCase(),
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Display Name (e.g., Grade 1)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _tempDisplayName = value,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _tempDescription = value,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_tempName.isNotEmpty && _tempDisplayName.isNotEmpty) {
                    setState(() {
                      _classLevels.add({
                        'name': _tempName,
                        'displayName': _tempDisplayName,
                        'description':
                            _tempDescription.isEmpty ? null : _tempDescription,
                        'category': _selectedCategory,
                        'order': _startOrder + _classLevels.length,
                        'isActive': true,
                      });
                    });
                    // Clear the form
                    _tempName = '';
                    _tempDisplayName = '';
                    _tempDescription = '';
                    Navigator.of(context).pop();
                  } else {
                    // Show validation error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Name and Display Name are required'),
                        backgroundColor: Color(0xFFEF4444),
                      ),
                    );
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
    );
  }

  void _addDefaultLevels() {
    setState(() {
      _classLevels.clear();
      _classLevels.addAll([
        {
          'name': 'GRADE1',
          'displayName': 'Grade 1',
          'description': 'First grade level',
          'category': _selectedCategory,
          'order': _startOrder,
          'isActive': true,
        },
        {
          'name': 'GRADE2',
          'displayName': 'Grade 2',
          'description': 'Second grade level',
          'category': _selectedCategory,
          'order': _startOrder + 1,
          'isActive': true,
        },
        {
          'name': 'GRADE3',
          'displayName': 'Grade 3',
          'description': 'Third grade level',
          'category': _selectedCategory,
          'order': _startOrder + 2,
          'isActive': true,
        },
      ]);
    });
  }

  String _tempName = '';
  String _tempDisplayName = '';
  String _tempDescription = '';
}
