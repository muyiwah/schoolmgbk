import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/screens/admin/admin_update_status_form_screen.dart';
import 'package:schmgtsystem/models/admin_update_status_models.dart';
import 'package:schmgtsystem/models/admin_users_model.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';

class AdminUpdateStatusScreen extends ConsumerStatefulWidget {
  const AdminUpdateStatusScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminUpdateStatusScreen> createState() =>
      _AdminUpdateStatusScreenState();
}

class _AdminUpdateStatusScreenState
    extends ConsumerState<AdminUpdateStatusScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<AdminUser> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  String? _selectedRole;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
    // Debounce search - reload after user stops typing
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text.toLowerCase() == _searchQuery) {
        _loadUsers();
      }
    });
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = ref.read(RiverpodProvider.authProvider);
      final response = await authProvider.getAllUsersWithStatus(
        page: _currentPage,
        limit: 100,
        status: _selectedStatus,
        role: _selectedRole,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (response != null && response.success && response.data != null) {
        setState(() {
          _users = response.data!.users;
          _isLoading = false;
        });
        print('✅ Loaded ${_users.length} users with status data');
      } else {
        setState(() {
          _errorMessage = 'Failed to load users';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading users: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Update User Status',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search users by name or email...',
                    hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF6B7280),
                    ),
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
                const SizedBox(height: 12),
                // Filter Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Filter by Role',
                          labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                          filled: true,
                          fillColor: const Color(0xFF1E293B),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Colors.white),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Roles'),
                          ),
                          const DropdownMenuItem(
                            value: 'student',
                            child: Text('Student'),
                          ),
                          const DropdownMenuItem(
                            value: 'parent',
                            child: Text('Parent'),
                          ),
                          const DropdownMenuItem(
                            value: 'teacher',
                            child: Text('Teacher'),
                          ),
                          const DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value;
                          });
                          _loadUsers();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Filter by Status',
                          labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                          filled: true,
                          fillColor: const Color(0xFF1E293B),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Colors.white),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Statuses'),
                          ),
                          const DropdownMenuItem(
                            value: 'active',
                            child: Text('Active'),
                          ),
                          const DropdownMenuItem(
                            value: 'inactive',
                            child: Text('Inactive'),
                          ),
                          const DropdownMenuItem(
                            value: 'suspended',
                            child: Text('Suspended'),
                          ),
                          const DropdownMenuItem(
                            value: 'terminated',
                            child: Text('Terminated'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                          _loadUsers();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Color(0xFF6B7280)),
            SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      color: const Color(0xFF6366F1),
      backgroundColor: const Color(0xFF1E293B),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return _buildUserCard(context, user);
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, AdminUser user) {
    print(
      '🏷️ Building user card for ${user.fullName} with status: "${user.status}"',
    );

    final statusColor = UserStatus.fromString(user.status).color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF374151)),
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => AdminUpdateStatusFormScreen(
                    userId: user.id,
                    userEmail: user.email,
                    userRole: user.role,
                    userName: user.fullName,
                    currentStatus: user.status,
                  ),
            ),
          );
          // Refresh data if status was updated
          if (result == true) {
            print('🔄 Status update detected, refreshing data...');
            await _loadUsers();
            CustomToastNotification.show(
              'User status updated successfully! Refreshing data...',
              type: ToastType.success,
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getRoleColor(user.role),
                  child: Text(
                    user.fullName.split(' ').map((e) => e[0]).join(''),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _getRoleColor(user.role),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: TextStyle(
                      color: _getRoleColor(user.role),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Color(statusColor).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Color(statusColor), width: 1),
              ),
              child: Text(
                UserStatus.fromString(user.status).displayName.toUpperCase(),
                style: TextStyle(
                  color: Color(statusColor),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return const Color(0xFF10B981);
      case 'teacher':
        return const Color(0xFF6366F1);
      case 'parent':
        return const Color(0xFFF59E0B);
      case 'admin':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
