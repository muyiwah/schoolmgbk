import 'package:flutter/material.dart';
import 'package:schmgtsystem/screens/admin/admin_change_password_screen.dart';

class AdminChangePasswordDemo extends StatelessWidget {
  const AdminChangePasswordDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Admin Change Password Demo',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Admin Change Password Demo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This demo shows how admins can change user passwords directly.',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Demo User Cards
              _buildDemoUserCard(
                context,
                'John Doe',
                'john.doe@example.com',
                'student',
                '64f8a1b2c3d4e5f6a7b8c9d0',
              ),
              const SizedBox(height: 16),
              _buildDemoUserCard(
                context,
                'Jane Smith',
                'jane.smith@example.com',
                'teacher',
                '64f8a1b2c3d4e5f6a7b8c9d1',
              ),
              const SizedBox(height: 16),
              _buildDemoUserCard(
                context,
                'Mike Johnson',
                'mike.johnson@example.com',
                'parent',
                '64f8a1b2c3d4e5f6a7b8c9d2',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoUserCard(
    BuildContext context,
    String name,
    String email,
    String role,
    String userId,
  ) {
    return Container(
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
                backgroundColor: const Color(0xFF6366F1),
                child: Text(
                  name.split(' ').map((e) => e[0]).join(''),
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
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRoleColor(role).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _getRoleColor(role), width: 1),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    color: _getRoleColor(role),
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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => AdminChangePasswordFormScreen(
                          userId: userId,
                          userEmail: email,
                          userRole: role,
                          userName: name,
                        ),
                  ),
                );
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
      case 'teacher':
        return const Color(0xFF6366F1);
      case 'parent':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
