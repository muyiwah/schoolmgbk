import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/providers/staff_provider.dart';
import 'package:schmgtsystem/screens/admin/admin_change_password_screen.dart';
import 'package:schmgtsystem/models/student_model.dart';
import 'package:schmgtsystem/models/single_parent_fulldetails_model.dart';
import 'package:schmgtsystem/models/staff_model.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';

class AdminChangePasswordScreen extends ConsumerStatefulWidget {
  const AdminChangePasswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminChangePasswordScreen> createState() =>
      _AdminChangePasswordScreenState();
}

class _AdminChangePasswordScreenState
    extends ConsumerState<AdminChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    // Force refresh by clearing any cached data first
    ref.read(RiverpodProvider.studentProvider.notifier).clearStudentDataCache();

    // Load students with force refresh
    ref
        .read(RiverpodProvider.studentProvider.notifier)
        .getAllStudents(context, page: 1, limit: 100, forceRefresh: true);

    // Load parents
    ref.read(RiverpodProvider.parentProvider.notifier).getAllParents(context);

    // Load staff
    ref.read(staffNotifierProvider.notifier).getAllStaff();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Change User Password',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6366F1),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF9CA3AF),
          tabs: const [
            Tab(icon: Icon(Icons.school), text: 'Students'),
            Tab(icon: Icon(Icons.family_restroom), text: 'Parents'),
            Tab(icon: Icon(Icons.person), text: 'Staff'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search users...',
                hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF374151)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF374151)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF6366F1),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStudentsTab(),
                _buildParentsTab(),
                _buildStaffTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    final studentState = ref.watch(RiverpodProvider.studentProvider);

    if (studentState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    if (studentState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 64),
            const SizedBox(height: 16),
            Text(
              'Error loading students: ${studentState.errorMessage}',
              style: const TextStyle(color: Color(0xFF9CA3AF)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    final students =
        studentState.students.where((student) {
          if (_searchQuery.isEmpty) return true;

          final name =
              '${student.personalInfo.firstName} ${student.personalInfo.lastName}'
                  .toLowerCase();
          final email = student.contactInfo.email.toLowerCase();
          final admissionNumber = student.admissionNumber.toLowerCase();

          return name.contains(_searchQuery) ||
              email.contains(_searchQuery) ||
              admissionNumber.contains(_searchQuery);
        }).toList();

    if (students.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, color: Color(0xFF6B7280), size: 64),
            SizedBox(height: 16),
            Text(
              'No students found',
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return _buildUserCard(
          context,
          name:
              '${student.personalInfo.firstName} ${student.personalInfo.lastName}',
          email: student.contactInfo.email,
          role: 'Student',
          userId: student.id, // Using student.id as userId for now
          userRole: 'student',
          admissionNumber: student.admissionNumber,
        );
      },
    );
  }

  Widget _buildParentsTab() {
    final parentState = ref.watch(RiverpodProvider.parentProvider);

    if (parentState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    if (parentState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 64),
            const SizedBox(height: 16),
            Text(
              'Error loading parents: ${parentState.errorMessage}',
              style: const TextStyle(color: Color(0xFF9CA3AF)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    final parents =
        parentState.parents.where((parent) {
          if (_searchQuery.isEmpty) return true;

          final name =
              '${parent.personalInfo?.firstName ?? ''} ${parent.personalInfo?.lastName ?? ''}'
                  .toLowerCase();
          final email = parent.user?.email?.toLowerCase() ?? '';

          return name.contains(_searchQuery) || email.contains(_searchQuery);
        }).toList();

    if (parents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.family_restroom_outlined,
              color: Color(0xFF6B7280),
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No parents found',
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: parents.length,
      itemBuilder: (context, index) {
        final parent = parents[index];
        return _buildUserCard(
          context,
          name:
              '${parent.personalInfo?.firstName ?? ''} ${parent.personalInfo?.lastName ?? ''}',
          email: parent.user?.email ?? 'No email',
          role: 'Parent',
          userId:
              parent.user?.id ??
              parent.id ??
              '', // Use user.id if available, fallback to document id
          userRole: 'parent',
        );
      },
    );
  }

  Widget _buildStaffTab() {
    final staffState = ref.watch(staffNotifierProvider);

    if (staffState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    if (staffState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 64),
            const SizedBox(height: 16),
            Text(
              'Error loading staff: ${staffState.errorMessage}',
              style: const TextStyle(color: Color(0xFF9CA3AF)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    final staff =
        staffState.staff.where((staffMember) {
          if (_searchQuery.isEmpty) return true;

          final name =
              '${staffMember.personalInfo?.firstName ?? ''} ${staffMember.personalInfo?.lastName ?? ''}'
                  .toLowerCase();
          final email = staffMember.user?.email?.toLowerCase() ?? '';
          final role = staffMember.user?.role?.toLowerCase() ?? '';

          return name.contains(_searchQuery) ||
              email.contains(_searchQuery) ||
              role.contains(_searchQuery);
        }).toList();

    if (staff.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, color: Color(0xFF6B7280), size: 64),
            SizedBox(height: 16),
            Text('No staff found', style: TextStyle(color: Color(0xFF9CA3AF))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: staff.length,
      itemBuilder: (context, index) {
        final staffMember = staff[index];
        return _buildUserCard(
          context,
          name:
              '${staffMember.personalInfo?.firstName ?? ''} ${staffMember.personalInfo?.lastName ?? ''}',
          email: staffMember.user?.email ?? 'No email',
          role: staffMember.user?.role ?? 'Staff',
          userId:
              staffMember.user?.id ??
              staffMember.id ??
              '', // Use user.id if available, fallback to document id
          userRole: 'staff',
        );
      },
    );
  }

  Widget _buildUserCard(
    BuildContext context, {
    required String name,
    required String email,
    required String role,
    required String userId,
    required String userRole,
    String? admissionNumber,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF374151)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _getRoleColor(userRole),
                child: Text(
                  name
                      .split(' ')
                      .map((e) => e.isNotEmpty ? e[0] : '')
                      .join('')
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                    ),
                    if (admissionNumber != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Admission: $admissionNumber',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRoleColor(userRole).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _getRoleColor(userRole), width: 1),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    color: _getRoleColor(userRole),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => AdminChangePasswordFormScreen(
                          userId: userId,
                          userEmail: email,
                          userRole: userRole,
                          userName: name,
                        ),
                  ),
                );

                // Refresh data if password was changed
                if (result == true) {
                  _loadData();

                  // Show success message
                  CustomToastNotification.show(
                    'User password changed successfully! Refreshing data...',
                    type: ToastType.success,
                  );
                }
              },
              icon: const Icon(Icons.lock_outline, size: 18),
              label: const Text('Change Password'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return const Color(0xFF10B981);
      case 'parent':
        return const Color(0xFFF59E0B);
      case 'staff':
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
