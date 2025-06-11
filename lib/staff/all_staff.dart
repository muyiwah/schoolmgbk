import 'package:flutter/material.dart';
import 'package:schmgtsystem/constants/appcolor.dart';

class AllStaff extends StatelessWidget {
  const AllStaff({Key? key, required Null Function() navigateTo})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Staff Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const StaffManagementScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StaffMember {
  final String name;
  final String role;
  final String department;
  final String contact;
  final String dateHired;
  final String status;
  final String? imageUrl;

  StaffMember({
    required this.name,
    required this.role,
    required this.department,
    required this.contact,
    required this.dateHired,
    required this.status,
    this.imageUrl,
  });
}

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({Key? key}) : super(key: key);

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'All Roles';
  String _selectedDepartment = 'All Departments';
  String _selectedStatus = 'All Status';
  int _currentPage = 1;

  final List<StaffMember> _staffMembers = [
    StaffMember(
      name: 'Sarah Johnson',
      role: 'Teacher',
      department: 'Academic',
      contact: 'sarah.j@school.edu',
      dateHired: 'Jan 15, 2020',
      status: 'Active',
    ),
    StaffMember(
      name: 'Michael Chen',
      role: 'Accountant',
      department: 'Admin',
      contact: '+1 555-0123',
      dateHired: 'Mar 08, 2019',
      status: 'Active',
    ),
    StaffMember(
      name: 'Emily Rodriguez',
      role: 'Librarian',
      department: 'Academic',
      contact: 'emily.r@school.edu',
      dateHired: 'Sep 12, 2021',
      status: 'On Leave',
    ),
    StaffMember(
      name: 'David Wilson',
      role: 'Cleaner',
      department: 'Maintenance',
      contact: '+1 555-0456',
      dateHired: 'Nov 03, 2022',
      status: 'Active',
    ),
    StaffMember(
      name: 'Lisa Thompson',
      role: 'Teacher',
      department: 'Academic',
      contact: 'lisa.t@school.edu',
      dateHired: 'Aug 20, 2018',
      status: 'Active',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildStatsCards(),
            const SizedBox(height: 32),
            _buildFiltersAndSearch(),
            const SizedBox(height: 24),
            Expanded(child: _buildStaffTable()),
            const SizedBox(height: 16),
            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Staff Management',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage all school staff members',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.dark_mode_outlined),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Staff Member'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Staff',
            '156',
            Icons.groups,
            const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Teachers',
            '89',
            Icons.school,
            const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Non-Teaching',
            '67',
            Icons.work,
            const Color(0xFF06B6D4),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'On Leave',
            '8',
            Icons.event_busy,
            const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Active Rate',
            '94.8%',
            Icons.trending_up,
            const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search staff by name or role...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildFilterDropdown(['All Roles','Accountant','Teacher','Cleaner','Security'], _selectedRole, (value) {
          setState(() => _selectedRole = value!);
        }),
        const SizedBox(width: 12),
        _buildFilterDropdown(['All Departments','Academics','Account'], _selectedDepartment, (value) {
          setState(() => _selectedDepartment = value!);
        }),
        const SizedBox(width: 12),
        _buildFilterDropdown(['All Status','On leave','New'], _selectedStatus, (value) {
          setState(() => _selectedStatus = value!);
        }),
      ],
    );
  }

  Widget _buildFilterDropdown(
    List<String> hint,
    String value,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint[0]),
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down),
        items:
            hint
                .map(
                  (String item) =>
                      DropdownMenuItem<String>(value: item, child: Text(item)),
                )
                .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildStaffTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: _staffMembers.length,
              itemBuilder: (context, index) {
                return _buildStaffRow(_staffMembers[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildHeaderCell('STAFF MEMBER')),
          Expanded(flex: 2, child: _buildHeaderCell('ROLE')),
          Expanded(flex: 2, child: _buildHeaderCell('DEPARTMENT')),
          Expanded(flex: 2, child: _buildHeaderCell('CONTACT')),
          Expanded(flex: 2, child: _buildHeaderCell('DATE HIRED')),
          Expanded(flex: 1, child: _buildHeaderCell('STATUS')),
          Expanded(flex: 1, child: _buildHeaderCell('ACTIONS')),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey[600],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildStaffRow(StaffMember member, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    member.name[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  member.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: _buildRoleChip(member.role)),
          Expanded(
            flex: 2,
            child: Text(
              member.department,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(member.contact, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: Text(member.dateHired, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(flex: 1, child: _buildStatusChip(member.status)),
          Expanded(flex: 1, child: _buildActionButtons()),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    Color chipColor;
    switch (role.toLowerCase()) {
      case 'teacher':
        chipColor = const Color(0xFF8B5CF6);
        break;
      case 'accountant':
        chipColor = const Color(0xFF06B6D4);
        break;
      case 'librarian':
        chipColor = const Color(0xFF8B5CF6);
        break;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'active':
        chipColor = const Color(0xFF10B981);
        break;
      case 'on leave':
        chipColor = const Color(0xFFF59E0B);
        break;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          padding: EdgeInsets.all(0),

          onPressed: () {},
          icon: const Icon(Icons.visibility, color: Color(0xFF4F46E5)),
          iconSize: 18,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        // IconButton(
        //   padding: EdgeInsets.all(0),
        //   onPressed: () {},
        //   icon: const Icon(Icons.edit, color: Color(0xFF4F46E5)),
        //   iconSize: 18,
        //   constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        // ),
        IconButton(
          padding: EdgeInsets.all(0),

          onPressed: () {},
          icon: const Icon(Icons.delete, color: Colors.red),
          iconSize: 18,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing 1 to 5 of 156 results',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        Row(
          children: [
            TextButton(
              onPressed: _currentPage > 1 ? () {} : null,
              child: const Text('Previous'),
            ),
            const SizedBox(width: 8),
            for (int i = 1; i <= 3; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: TextButton(
                  onPressed: () {
                    setState(() => _currentPage = i);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        _currentPage == i
                            ? const Color(0xFF4F46E5)
                            : Colors.transparent,
                    foregroundColor:
                        _currentPage == i ? Colors.white : Colors.black87,
                    minimumSize: const Size(40, 40),
                  ),
                  child: Text(i.toString()),
                ),
              ),
            const SizedBox(width: 8),
            TextButton(onPressed: () {}, child: const Text('Next')),
          ],
        ),
      ],
    );
  }
}
