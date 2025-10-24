import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/color_pallete.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';
import 'package:schmgtsystem/widgets/screen_header.dart';

class AllParents extends ConsumerStatefulWidget {
  AllParents({super.key, required this.navigateTo});
  final Function(String parentId) navigateTo;

  @override
  ConsumerState<AllParents> createState() => _AllParentsState();
}

class _AllParentsState extends ConsumerState<AllParents> {
  // Filter state variables
  String? _selectedClassId;
  String? _selectedGender;
  String? _selectedFeeStatus;
  String? _selectedStatus;
  String? _selectedAcademicYear;
  String _searchQuery = '';
  String _sortBy = "personalInfo.firstName";
  String _sortOrder = "asc";
  bool _showFilters = false;

  // Filter options
  final List<String> _genderOptions = ['Male', 'Female'];
  final List<String> _feeStatusOptions = ['Paid', 'Partial', 'Unpaid'];
  final List<String> _statusOptions = ['Active', 'Inactive'];
  final List<String> _sortOptions = [
    'personalInfo.firstName',
    'personalInfo.lastName',
    'personalInfo.email',
    'createdAt',
  ];

  @override
  void initState() {
    super.initState();
    // Clear any previous errors and load parents data when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = ref.read(RiverpodProvider.parentProvider.notifier);
      provider.setError(null); // Clear any previous errors
      provider.getAllParents(context);
    });
  }

  // Method to apply filters
  void _applyFilters() {
    final provider = ref.read(RiverpodProvider.parentProvider.notifier);
    provider.getAllParents(
      context,
      classId: _selectedClassId,
      gender: _selectedGender,
      feeStatus: _selectedFeeStatus,
      status: _selectedStatus,
      academicYear: _selectedAcademicYear,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );
  }

  // Method to clear all filters
  void _clearFilters() {
    setState(() {
      _selectedClassId = null;
      _selectedGender = null;
      _selectedFeeStatus = null;
      _selectedStatus = null;
      _selectedAcademicYear = null;
      _searchQuery = '';
      _sortBy = "personalInfo.firstName";
      _sortOrder = "asc";
    });
    _applyFilters();
  }

  // Method to toggle filters visibility
  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  List images = [
    'assets/images/1.jpeg',
    'assets/images/2.jpeg',
    'assets/images/3.jpeg',
    'assets/images/4.jpeg',
    'assets/images/5.jpeg',
    'assets/images/6.jpeg',
    'assets/images/7.jpeg',
    'assets/images/8.jpeg',
    'assets/images/9.jpeg',
    'assets/images/10.jpeg',
    'assets/images/1.jpeg',
    'assets/images/2.jpeg',
    'assets/images/3.jpeg',
    'assets/images/4.jpeg',
    'assets/images/5.jpeg',
    'assets/images/6.jpeg',
    'assets/images/7.jpeg',
    'assets/images/8.jpeg',
    'assets/images/9.jpeg',
    'assets/images/10.jpeg',
    'assets/images/1.jpeg',
    'assets/images/2.jpeg',
    'assets/images/3.jpeg',
    'assets/images/4.jpeg',
    'assets/images/5.jpeg',
    'assets/images/6.jpeg',
    'assets/images/7.jpeg',
    'assets/images/8.jpeg',
    'assets/images/9.jpeg',
    'assets/images/10.jpeg',
    'assets/images/1.jpeg',
    'assets/images/2.jpeg',
    'assets/images/3.jpeg',
    'assets/images/4.jpeg',
    'assets/images/5.jpeg',
    'assets/images/6.jpeg',
    'assets/images/7.jpeg',
    'assets/images/8.jpeg',
    'assets/images/9.jpeg',
    'assets/images/10.jpeg',
  ];

  // Build filter section widget
  Widget _buildFilterSection() {
    return Column(
      children: [
        // Filter toggle button
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _toggleFilters,
              icon: Icon(
                _showFilters ? Icons.filter_list_off : Icons.filter_list,
              ),
              label: Text(_showFilters ? 'Hide Filters' : 'Show Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _showFilters ? Colors.red[100] : Colors.blue[100],
                foregroundColor:
                    _showFilters ? Colors.red[700] : Colors.blue[700],
              ),
            ),
            const SizedBox(width: 10),
            if (_showFilters)
              ElevatedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Clear All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.grey[700],
                ),
              ),
            const Spacer(),
            if (_showFilters)
              ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.search),
                label: const Text('Apply Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[100],
                  foregroundColor: Colors.green[700],
                ),
              ),
          ],
        ),

        // Filter options (shown when _showFilters is true)
        if (_showFilters) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                // Search input
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Parents',
                    hintText: 'Enter name, email, or phone number',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Filter dropdowns in a grid
                Row(
                  children: [
                    // Gender filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedGender,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Genders'),
                          ),
                          ..._genderOptions.map(
                            (gender) => DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Fee Status filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Fee Status',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedFeeStatus,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Fee Status'),
                          ),
                          ..._feeStatusOptions.map(
                            (status) => DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedFeeStatus = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    // Status filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedStatus,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Status'),
                          ),
                          ..._statusOptions.map(
                            (status) => DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Sort options
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Sort By',
                          border: OutlineInputBorder(),
                        ),
                        value: _sortBy,
                        items:
                            _sortOptions
                                .map(
                                  (option) => DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(_getSortDisplayName(option)),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Sort order toggle
                Row(
                  children: [
                    const Text(
                      'Sort Order:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 16),
                    ChoiceChip(
                      label: const Text('Ascending'),
                      selected: _sortOrder == 'asc',
                      onSelected: (selected) {
                        setState(() {
                          _sortOrder = 'asc';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Descending'),
                      selected: _sortOrder == 'desc',
                      onSelected: (selected) {
                        setState(() {
                          _sortOrder = 'desc';
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Helper method to get display names for sort options
  String _getSortDisplayName(String sortOption) {
    switch (sortOption) {
      case 'personalInfo.firstName':
        return 'First Name';
      case 'personalInfo.lastName':
        return 'Last Name';
      case 'personalInfo.email':
        return 'Email';
      case 'createdAt':
        return 'Date Created';
      default:
        return sortOption;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => const AddClientDialog());
        },
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: screenBackground.withOpacity(.01),
        ),
        child: Column(
          children: [
            ScreenHeader(
              group: 'Parents',
              subgroup: 'All Parents',
              showSearchBar: true,
              showDropdown: true,
            ),
            const SizedBox(height: 20),

            // Filter Section
            _buildFilterSection(),

            const SizedBox(height: 20),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final parentState = ref.watch(
                    RiverpodProvider.parentProvider,
                  );

                  if (parentState.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // if (parentState.errorMessage != null) {
                  //   return Center(
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Icon(
                  //           Icons.error_outline,
                  //           size: 64,
                  //           color: Colors.red[300],
                  //         ),
                  //         const SizedBox(height: 16),
                  //         Text(
                  //           'Error loading parents',
                  //           style: TextStyle(
                  //             fontSize: 18,
                  //             color: Colors.red[700],
                  //             fontWeight: FontWeight.w600,
                  //           ),
                  //         ),
                  //         const SizedBox(height: 8),
                  //         Text(
                  //           parentState.errorMessage!,
                  //           style: TextStyle(
                  //             fontSize: 14,
                  //             color: Colors.red[600],
                  //           ),
                  //           textAlign: TextAlign.center,
                  //         ),
                  //         const SizedBox(height: 16),
                  //         ElevatedButton(
                  //           onPressed: () {
                  //             ref
                  //                 .read(
                  //                   RiverpodProvider.parentProvider.notifier,
                  //                 )
                  //                 .getAllParents(context);
                  //           },
                  //           child: const Text('Retry'),
                  //         ),
                  //       ],
                  //     ),
                  //   );
                  // }

                  final parents = parentState.parents;
                  if (parents.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No parents found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No parents have been registered yet',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(.3)),
                    ),
                    child: SingleChildScrollView(
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 20,
                        children: List.generate(parents.length, (index) {
                          final parent = parents[index];
                          // Debug: Print parent gender information
                          print(
                            'DEBUG: Parent ${parent.personalInfo?.firstName} - Gender: ${parent.personalInfo?.gender?.name}',
                          );
                          return GestureDetector(
                            onTap: () {
                              // Debug: Print parent data to understand the structure
                              print('Parent ID: ${parent.id}');
                              print('Parent ID (parentId): ${parent.parentId}');
                              print('Parent ID type: ${parent.id.runtimeType}');
                              print(
                                'Parent parentId type: ${parent.parentId.runtimeType}',
                              );

                              // Use parentId if available, otherwise fall back to id
                              // Ensure we convert to string to avoid type errors
                              final parentIdValue =
                                  parent.parentId ?? parent.id;
                              final parentId = parentIdValue?.toString() ?? '';

                              if (parentId.isEmpty) {
                                showSnackbar(
                                  context,
                                  'Parent ID not available',
                                );
                                return;
                              }

                              widget.navigateTo(parentId);
                            },
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 120,
                                maxWidth: 240,
                                minHeight: 200,
                                maxHeight: 320,
                              ),
                              child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Colors.blue[300],
                                              child: Text(
                                                '${parent.personalInfo?.firstName.toString().split('').first.toUpperCase() ?? ''} ${parent.personalInfo?.lastName.toString().split('').first.toUpperCase() ?? ''}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              radius: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${parent.personalInfo?.firstName ?? ''} ${parent.personalInfo?.lastName ?? ''}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    parent
                                                            .professionalInfo
                                                            ?.occupation ??
                                                        'Parent',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          color: Colors.grey.shade300,
                                          height: .2,
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.email_outlined,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                parent.contactInfo?.email ??
                                                    'No email',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.phone,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                parent
                                                        .contactInfo
                                                        ?.primaryPhone ??
                                                    'No phone',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Parent role indicator
                                        Row(
                                          children: [
                                            Icon(
                                              () {
                                                final gender =
                                                    parent
                                                        .personalInfo
                                                        ?.gender
                                                        ?.name
                                                        ?.toLowerCase();
                                                print(
                                                  'DEBUG: Parent ${parent.personalInfo?.firstName} gender: $gender',
                                                );
                                                return gender == 'male' ||
                                                        gender == 'm'
                                                    ? Icons.man
                                                    : Icons.woman;
                                              }(),
                                              size: 16,
                                              color: () {
                                                final gender =
                                                    parent
                                                        .personalInfo
                                                        ?.gender
                                                        ?.name
                                                        ?.toLowerCase();
                                                return gender == 'male' ||
                                                        gender == 'm'
                                                    ? Colors.blue
                                                    : Colors.pink;
                                              }(),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                () {
                                                  final gender =
                                                      parent
                                                          .personalInfo
                                                          ?.gender
                                                          ?.name
                                                          ?.toLowerCase();
                                                  return gender == 'male' ||
                                                          gender == 'm'
                                                      ? 'Father'
                                                      : 'Mother';
                                                }(),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: () {
                                                    final gender =
                                                        parent
                                                            .personalInfo
                                                            ?.gender
                                                            ?.name
                                                            ?.toLowerCase();
                                                    return gender == 'male' ||
                                                            gender == 'm'
                                                        ? Colors.blue
                                                        : Colors.pink;
                                                  }(),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Children names section
                                        if (parent.children != null &&
                                            parent.children!.isNotEmpty) ...[
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.child_care,
                                                size: 16,
                                                color: Colors.green,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Children:',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    ...parent.children!
                                                        .map(
                                                          (child) => Text(
                                                            '• ${child.personalInfo?.firstName ?? 'Unknown'} ${child.personalInfo?.lastName ?? ''}',
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        )
                                                        .toList(),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ] else ...[
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.child_care,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  'No children',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[500],
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(
                                    delay: Duration(milliseconds: 100 * index),
                                    duration: const Duration(milliseconds: 400),
                                  )
                                  .slideX(
                                    begin: 1,
                                    delay: Duration(milliseconds: 100 * index),
                                    duration: const Duration(milliseconds: 400),
                                  ),
                            ),
                          );
                        }),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddClientDialog extends StatefulWidget {
  const AddClientDialog({Key? key}) : super(key: key);

  @override
  _AddClientDialogState createState() => _AddClientDialogState();
}

class _AddClientDialogState extends State<AddClientDialog> {
  final _formKey = GlobalKey<FormState>();
  bool displayOnAllBookings = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.5, // Set to half the screen width
        ),

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add new parent',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Form Fields
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // First Name & Last Name
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              hintText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              hintText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'email address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Gender & Year
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            items:
                                ['Male', 'Female', 'Other']
                                    .map(
                                      (gender) => DropdownMenuItem(
                                        value: gender,
                                        child: Text(gender),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (_) {},
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Year',
                              hintText: 'Year',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Client info
                    TextFormField(
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Other info',
                        hintText: 'E.g lives very far away from the school',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: displayOnAllBookings,
                          onChanged: (value) {
                            setState(() {
                              displayOnAllBookings = value ?? false;
                            });
                          },
                        ),
                        const Text('Display on all bookings'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Save'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Save client logic
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
