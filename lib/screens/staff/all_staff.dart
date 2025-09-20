import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/models/staff_model.dart';
import 'package:schmgtsystem/providers/staff_provider.dart';
import 'package:schmgtsystem/widgets/select_staffrole_popup.dart';
import 'package:schmgtsystem/widgets/staff_dialog.dart';

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

class StaffManagementScreen extends ConsumerStatefulWidget {
  const StaffManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StaffManagementScreen> createState() =>
      _StaffManagementScreenState();
}

class _StaffManagementScreenState extends ConsumerState<StaffManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'All Roles';
  String _selectedDepartment = 'All Departments';
  String _selectedStatus = 'All Status';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    // Fetch staff data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(staffNotifierProvider.notifier).getAllStaff();
    });
  }

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
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierColor: Colors.black.withOpacity(0.5),
                  builder: (context) => StaffRoleAssignmentPopup(),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Assign Staff Role'),
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
    final staffState = ref.watch(staffNotifierProvider);
    final staff = staffState.staff;

    // Calculate statistics
    final totalStaff = staff.length;
    final teachers =
        staff
            .where(
              (s) =>
                  s.employmentInfo?.position?.toLowerCase().contains(
                    'teacher',
                  ) ==
                  true,
            )
            .length;
    final nonTeaching = totalStaff - teachers;
    final onLeave =
        staff.where((s) => s.status?.toLowerCase() == 'inactive').length;
    final activeRate =
        totalStaff > 0
            ? ((totalStaff - onLeave) / totalStaff * 100).toStringAsFixed(1)
            : '0.0';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Staff',
            totalStaff.toString(),
            Icons.groups,
            const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Teachers',
            teachers.toString(),
            Icons.school,
            const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Non-Teaching',
            nonTeaching.toString(),
            Icons.work,
            const Color(0xFF06B6D4),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'On Leave',
            onLeave.toString(),
            Icons.event_busy,
            const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Active Rate',
            '$activeRate%',
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
        _buildFilterDropdown(
          ['All Roles', 'Accountant', 'Teacher', 'Cleaner', 'Security'],
          _selectedRole,
          (value) {
            setState(() => _selectedRole = value!);
          },
        ),
        const SizedBox(width: 12),
        _buildFilterDropdown(
          ['All Departments', 'Academics', 'Account'],
          _selectedDepartment,
          (value) {
            setState(() => _selectedDepartment = value!);
          },
        ),
        const SizedBox(width: 12),
        _buildFilterDropdown(
          ['All Status', 'On leave', 'New'],
          _selectedStatus,
          (value) {
            setState(() => _selectedStatus = value!);
          },
        ),
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
    final staffState = ref.watch(staffNotifierProvider);

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
          Expanded(child: _buildStaffContent(staffState)),
        ],
      ),
    );
  }

  Widget _buildStaffContent(StaffState staffState) {
    if (staffState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (staffState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error loading staff',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.red[700]),
              ),
              const SizedBox(height: 8),
              Text(
                staffState.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(staffNotifierProvider.notifier).getAllStaff();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (staffState.staff.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No staff members found',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Add new staff members to get started',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: staffState.staff.length,
      itemBuilder: (context, index) {
        return _buildStaffRow(staffState.staff[index], index);
      },
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

  Widget _buildStaffRow(Staff staff, int index) {
    final fullName =
        '${staff.personalInfo?.firstName ?? ''} ${staff.personalInfo?.lastName ?? ''}'
            .trim();
    final role = staff.user?.role ?? 'N/A';
    final department = staff.employmentInfo?.department ?? 'N/A';
    final contact =
        staff.contactInfo?.email ?? staff.contactInfo?.primaryPhone ?? 'N/A';
    final dateHired =
        staff.employmentInfo?.joinDate != null
            ? (staff.employmentInfo!.joinDate! is String
                ? DateTime.parse(
                  staff.employmentInfo!.joinDate! as String,
                ).toLocal().toString().split(' ')[0]
                : staff.employmentInfo!.joinDate!.toLocal().toString().split(
                  ' ',
                )[0])
            : 'N/A';
    final status = staff.status ?? 'active';

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
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName.isNotEmpty ? fullName : 'Unknown Staff',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    if (staff.staffStaffId != null)
                      Text(
                        staff.staffStaffId!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: _buildRoleChip(role)),
          Expanded(
            flex: 2,
            child: Text(department, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: Text(contact, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: Text(dateHired, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(flex: 1, child: _buildStatusChip(status)),
          Expanded(flex: 1, child: _buildActionButtons(staff)),
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

  Widget _buildActionButtons(Staff staff) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          padding: EdgeInsets.all(0),

          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              barrierColor: Colors.black.withOpacity(0.5),
              builder: (context) => StaffDialog(),
            );
          },
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
