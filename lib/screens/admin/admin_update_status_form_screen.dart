import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';
import 'package:schmgtsystem/models/admin_update_status_models.dart';

class AdminUpdateStatusFormScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userEmail;
  final String userRole;
  final String userName;
  final String? currentStatus;

  const AdminUpdateStatusFormScreen({
    Key? key,
    required this.userId,
    required this.userEmail,
    required this.userRole,
    required this.userName,
    this.currentStatus,
  }) : super(key: key);

  @override
  ConsumerState<AdminUpdateStatusFormScreen> createState() =>
      _AdminUpdateStatusFormScreenState();
}

class _AdminUpdateStatusFormScreenState
    extends ConsumerState<AdminUpdateStatusFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  UserStatus? _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set initial status if provided
    if (widget.currentStatus != null) {
      _selectedStatus = UserStatus.fromString(widget.currentStatus!);
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStatus == null) {
      CustomToastNotification.show(
        'Please select a status',
        type: ToastType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = ref.read(RiverpodProvider.authProvider);
      final response = await authProvider.adminUpdateStatus(
        userId: widget.userId,
        status: _selectedStatus!.value,
        reason:
            _reasonController.text.trim().isNotEmpty
                ? _reasonController.text.trim()
                : null,
      );

      if (response != null && response.success) {
        // Clear form
        _reasonController.clear();

        // Show success dialog with details
        _showSuccessDialog(response.data!);
      }
    } catch (e) {
      CustomToastNotification.show(
        'Error updating user status: $e',
        type: ToastType.error,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(AdminUpdateStatusData data) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'User Status Updated Successfully',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('User Name', widget.userName),
                _buildInfoRow('User Email', data.userEmail),
                _buildInfoRow('User Role', data.userRole),
                _buildInfoRow('Previous Status', _formatStatus(data.oldStatus)),
                _buildInfoRow('New Status', _formatStatus(data.newStatus)),
                _buildInfoRow('Changed By', data.changedBy),
                _buildInfoRow('Changed At', _formatDateTime(data.changedAt)),
                if (data.reason != null) _buildInfoRow('Reason', data.reason!),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  context.pop(
                    true,
                  ); // Go back to user selection screen with refresh signal
                },
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }

  String _formatStatus(String status) {
    final userStatus = UserStatus.fromString(status);
    return userStatus.displayName;
  }

  Widget _buildStatusCard(UserStatus status) {
    final isSelected = _selectedStatus == status;
    final isCurrentStatus = widget.currentStatus == status.value;

    return GestureDetector(
      onTap: () {
        if (!isCurrentStatus) {
          setState(() {
            _selectedStatus = status;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Color(status.color).withOpacity(0.2)
                  : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? Color(status.color)
                    : isCurrentStatus
                    ? Color(status.color).withOpacity(0.5)
                    : const Color(0xFF374151),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Color(status.color),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        status.displayName,
                        style: TextStyle(
                          color:
                              isSelected ? Color(status.color) : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isCurrentStatus) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Color(status.color).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'CURRENT',
                            style: TextStyle(
                              color: Color(status.color),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status.description,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Color(status.color), size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Update User Status',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // Header
                  const Text(
                    'Update User Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // User Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF374151)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User Information',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildUserInfoRow('Name', widget.userName),
                        _buildUserInfoRow('Email', widget.userEmail),
                        _buildUserInfoRow('Role', widget.userRole),
                        _buildUserInfoRow('User ID', widget.userId),
                        if (widget.currentStatus != null)
                          _buildUserInfoRow(
                            'Current Status',
                            _formatStatus(widget.currentStatus!),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Status Selection
                  const Text(
                    'Select New Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Status Selection Cards
                  ...UserStatus.values.map((status) {
                    return _buildStatusCard(status);
                  }).toList(),

                  const SizedBox(height: 20),

                  // Reason Field (Optional)
                  const Text(
                    'Reason (Optional)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _reasonController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter reason for status change (optional)',
                      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
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
                      prefixIcon: const Icon(
                        Icons.note_outlined,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Update Status Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Update Status',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Warning Message
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFF59E0B),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This action will immediately change the user\'s account status. Users with inactive, suspended, or terminated status will not be able to log in.',
                            style: TextStyle(
                              color: Color(0xFF92400E),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
