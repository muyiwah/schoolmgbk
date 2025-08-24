import 'package:flutter/material.dart';

class StaffRoleAssignmentPopup extends StatefulWidget {
  const StaffRoleAssignmentPopup({Key? key}) : super(key: key);

  @override
  State<StaffRoleAssignmentPopup> createState() =>
      _StaffRoleAssignmentPopupState();
}

class _StaffRoleAssignmentPopupState extends State<StaffRoleAssignmentPopup>
    with TickerProviderStateMixin {
  // Dummy staff data
  final List<Map<String, dynamic>> staffList = [
    {
      'id': '001',
      'name': 'Dr. John Adebayo',
      'department': 'Mathematics',
      'currentRole': 'Senior Teacher',
      'image': 'assets/avatar1.png',
      'email': 'john.adebayo@school.edu.ng',
    },
    {
      'id': '002',
      'name': 'Mrs. Grace Okafor',
      'department': 'English Language',
      'currentRole': 'Head of Department',
      'image': 'assets/avatar2.png',
      'email': 'grace.okafor@school.edu.ng',
    },
    {
      'id': '003',
      'name': 'Mr. Ibrahim Hassan',
      'department': 'Physics',
      'currentRole': 'Teacher',
      'image': 'assets/avatar3.png',
      'email': 'ibrahim.hassan@school.edu.ng',
    },
    {
      'id': '004',
      'name': 'Miss Sarah Thompson',
      'department': 'Chemistry',
      'currentRole': 'Laboratory Assistant',
      'image': 'assets/avatar4.png',
      'email': 'sarah.thompson@school.edu.ng',
    },
    {
      'id': '005',
      'name': 'Mr. David Okoro',
      'department': 'Computer Science',
      'currentRole': 'ICT Coordinator',
      'image': 'assets/avatar5.png',
      'email': 'david.okoro@school.edu.ng',
    },
  ];

  // Available roles
  final List<Map<String, dynamic>> rolesList = [
    {
      'role': 'Principal',
      'description': 'School Administrator',
      'icon': Icons.account_balance,
      'color': Colors.purple,
    },
    {
      'role': 'Vice Principal',
      'description': 'Assistant Administrator',
      'icon': Icons.supervisor_account,
      'color': Colors.indigo,
    },
    {
      'role': 'Head of Department',
      'description': 'Department Leader',
      'icon': Icons.groups,
      'color': Colors.blue,
    },
    {
      'role': 'Senior Teacher',
      'description': 'Experienced Educator',
      'icon': Icons.school,
      'color': Colors.green,
    },
    {
      'role': 'Teacher',
      'description': 'Subject Teacher',
      'icon': Icons.person,
      'color': Colors.orange,
    },
    {
      'role': 'Laboratory Assistant',
      'description': 'Lab Support Staff',
      'icon': Icons.science,
      'color': Colors.teal,
    },
    {
      'role': 'ICT Coordinator',
      'description': 'Technology Support',
      'icon': Icons.computer,
      'color': Colors.cyan,
    },
    {
      'role': 'Librarian',
      'description': 'Library Manager',
      'icon': Icons.local_library,
      'color': Colors.brown,
    },
  ];

  Map<String, dynamic>? selectedStaff;
  Map<String, dynamic>? selectedRole;
  String? searchQuery;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late TextEditingController _searchController;
  bool showSelectNameFull = true;
  bool showSelectRoleFull = true;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _searchController = TextEditingController();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredStaff {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return staffList;
    }
    return staffList.where((staff) {
      return staff['name'].toLowerCase().contains(searchQuery!.toLowerCase()) ||
          staff['department'].toLowerCase().contains(
            searchQuery!.toLowerCase(),
          ) ||
          staff['currentRole'].toLowerCase().contains(
            searchQuery!.toLowerCase(),
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          // elevation: 8,
          // insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.indigo.shade50, Colors.white],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStaffSelection(),
                            const SizedBox(height: 20),
                            _buildRoleSelection(),
                            const SizedBox(height: 20),
                            if (selectedStaff != null && selectedRole != null)
                              _buildAssignmentPreview(),
                            const SizedBox(height: 20),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: [Colors.indigo.shade600, Colors.indigo.shade800],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.assignment_ind, color: Colors.white, size: 28),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 24),
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Assign Staff Role',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Select staff member and assign new role',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: Colors.indigo.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Select Staff Member',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search staff by name, department or role...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.indigo.shade400),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),

          const SizedBox(height: 12),

          // Staff dropdown
          DropdownButtonFormField<Map<String, dynamic>>(
            dropdownColor: Colors.white,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            hint: const Text('Choose staff member'),
            value: selectedStaff,
            items:
                filteredStaff.map((staff) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: staff,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.indigo.shade100,
                          child: Text(
                            staff['name']
                                .split(' ')
                                .map((n) => n[0])
                                .take(2)
                                .join(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                staff['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (showSelectNameFull)
                                Text(
                                  '${staff['department']} • ${staff['currentRole']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            onTap: () {
              print('object');
              setState(() {
                showSelectNameFull = true;
              });
            },
            onChanged: (value) {
              print('aved');
              showSelectNameFull = false;
              setState(() {
                selectedStaff = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.indigo.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Select New Role',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<Map<String, dynamic>>(
            dropdownColor: Colors.white,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            hint: const Text('Choose role to assign'),
            value: selectedRole,
            items:
                rolesList.map((role) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: role,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: role['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            role['icon'],
                            color: role['color'],
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                role['role'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          if(showSelectRoleFull)    Text(
                                role['description'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                showSelectRoleFull = false;
                selectedRole = value;
              });
            },
            onTap: () {
              setState(() {
                showSelectRoleFull = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, color: Colors.green.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Assignment Preview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.indigo.shade100,
                child: Text(
                  selectedStaff!['name']
                      .split(' ')
                      .map((n) => n[0])
                      .take(2)
                      .join(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedStaff!['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      selectedStaff!['email'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.grey),
              const SizedBox(width: 12),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selectedRole!['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selectedRole!['color'].withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selectedRole!['icon'],
                        color: selectedRole!['color'],
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          selectedRole!['role'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: selectedRole!['color'],
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
              children: [
                const TextSpan(text: 'Current Role: '),
                TextSpan(
                  text: selectedStaff!['currentRole'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' → New Role: '),
                TextSpan(
                  text: selectedRole!['role'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                selectedStaff != null && selectedRole != null
                    ? () {
                      _showConfirmationDialog();
                    }
                    : null,
            icon: const Icon(Icons.assignment_turned_in),
            label: const Text('Assign Role'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              disabledBackgroundColor: Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text('Confirm Role Assignment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to assign the following role?',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade100,
                    child: Text(
                      selectedStaff!['name']
                          .split(' ')
                          .map((n) => n[0])
                          .take(2)
                          .join(),
                      style: TextStyle(
                        color: Colors.indigo.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    selectedStaff!['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(selectedStaff!['department']),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Current Role: ',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    Text(
                      selectedStaff!['currentRole'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'New Role: ',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: selectedRole!['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: selectedRole!['color'].withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        selectedRole!['role'],
                        style: TextStyle(
                          color: selectedRole!['color'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
                  Navigator.of(context).pop(); // Close confirmation
                  Navigator.of(context).pop(); // Close main popup
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Successfully assigned ${selectedRole!['role']} to ${selectedStaff!['name']}!',
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade600,
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

// Example usage
class StaffRoleExample extends StatelessWidget {
  const StaffRoleExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Management System'),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const StaffRoleAssignmentPopup(),
            );
          },
          icon: const Icon(Icons.assignment_ind),
          label: const Text('Assign Staff Role'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ),
    );
  }
}
