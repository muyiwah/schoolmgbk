import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schmgtsystem/models/admission_model.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:country_picker/country_picker.dart';

class AdmissionManagementScreen extends ConsumerStatefulWidget {
  const AdmissionManagementScreen({super.key});

  @override
  ConsumerState<AdmissionManagementScreen> createState() =>
      _AdmissionManagementScreenState();
}

class _AdmissionManagementScreenState
    extends ConsumerState<AdmissionManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final admissionProvider = ref.read(RiverpodProvider.admissionProvider);
    await Future.wait([
      admissionProvider.getAllAdmissionIntents(context),
      admissionProvider.getAdmissionStatistics(context),
    ]);
  }

  void _refreshData() {
    _loadData();
  }

  void _filterByStatus(String? status) {
    setState(() {
      _selectedStatus = status;
    });

    final admissionProvider = ref.read(RiverpodProvider.admissionProvider);
    admissionProvider.setStatusFilter(status);
    admissionProvider.getAllAdmissionIntents(context);
  }

  void _updateAdmissionStatus(
    String admissionId,
    String newStatus, {
    String? reviewNotes,
    String? rejectionReason,
  }) async {
    final admissionProvider = ref.read(RiverpodProvider.admissionProvider);
    final success = await admissionProvider.updateAdmissionStatus(
      ref.read(RiverpodProvider.profileProvider).user?.id ?? '',
      context,
      admissionId,
      newStatus,
      reviewNotes: reviewNotes,
      rejectionReason: rejectionReason,
    );

    if (success) {
      showSnackbar(context, 'Admission status updated successfully!');
    } else {
      showSnackbar(context, 'Failed to update admission status');
    }
  }

  void _admitStudent(String admissionId) async {
    final admissionProvider = ref.read(RiverpodProvider.admissionProvider);
    final success = await admissionProvider.admitStudent(
      ref.read(RiverpodProvider.profileProvider).user?.id ?? '',
      context,
      admissionId,
    );

    if (success) {
      showSnackbar(context, 'Student admitted successfully!');
    } else {
      showSnackbar(context, 'Failed to admit student');
    }
  }

  @override
  Widget build(BuildContext context) {
    final admissionProvider = ref.watch(RiverpodProvider.admissionProvider);
    final statistics = admissionProvider.statistics;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Admission Management'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/admissions/form'),
            tooltip: 'New Admission',
          ),
        ],
        bottom: TabBar(
          unselectedLabelColor: const Color.fromARGB(255, 191, 191, 191),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: TextStyle(color: Colors.white),
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.list)),
            Tab(text: 'Pending', icon: Icon(Icons.pending)),
            Tab(text: 'Under Review', icon: Icon(Icons.visibility)),
            Tab(text: 'Approved', icon: Icon(Icons.check_circle)),
            Tab(text: 'Rejected', icon: Icon(Icons.cancel)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildStatisticsCards(statistics),
          _buildFiltersSection(admissionProvider),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAdmissionsList(admissionProvider.admissions),
                _buildAdmissionsList(
                  admissionProvider.getAdmissionsByStatus('pending'),
                ),
                _buildUnderReviewDetails(
                  admissionProvider.getAdmissionsByStatus('under_review'),
                ),
                _buildAdmissionsList(
                  admissionProvider.getAdmissionsByStatus('approved'),
                ),
                _buildAdmissionsList(
                  admissionProvider.getAdmissionsByStatus('rejected'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(AdmissionStatistics? statistics) {
    if (statistics == null) {
      return Container(
        height: 120,
        color: Colors.white,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Applications',
              statistics.overview.totalApplications.toString(),
              Icons.people,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Pending',
              statistics.statusBreakdown
                      .where((s) => s.status == 'pending')
                      .firstOrNull
                      ?.count
                      .toString() ??
                  '0',
              Icons.pending,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Approved',
              statistics.statusBreakdown
                      .where((s) => s.status == 'approved')
                      .firstOrNull
                      ?.count
                      .toString() ??
                  '0',
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Admitted',
              statistics.statusBreakdown
                      .where((s) => s.status == 'admitted')
                      .firstOrNull
                      ?.count
                      .toString() ??
                  '0',
              Icons.school,
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(admissionProvider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All Status')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(
                  value: 'under_review',
                  child: Text('Under Review'),
                ),
                DropdownMenuItem(value: 'approved', child: Text('Approved')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                DropdownMenuItem(value: 'admitted', child: Text('Admitted')),
              ],
              onChanged: _filterByStatus,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Academic Year',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              initialValue: '2025/2026',
              readOnly: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdmissionsList(List<AdmissionModel> admissions) {
    if (admissions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No admissions found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: admissions.length,
      itemBuilder: (context, index) {
        final admission = admissions[index];
        return _buildAdmissionCard(admission);
      },
    );
  }

  Widget _buildUnderReviewDetails(List<AdmissionModel> admissions) {
    if (admissions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No admissions under review',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: admissions.length,
      itemBuilder: (context, index) {
        final admission = admissions[index];
        return _buildDetailedReviewCard(admission);
      },
    );
  }

  Widget _buildDetailedReviewCard(AdmissionModel admission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status and actions
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admission.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Admission ID: ${admission.id}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(admission.status),
              ],
            ),
            const SizedBox(height: 20),

            // Student Information Section
            _buildDetailSection(
              'Student Information',
              Icons.person,
              Colors.blue,
              [
                _buildDetailRow('Full Name', admission.fullName),
                _buildDetailRow(
                  'Date of Birth',
                  _formatDate(admission.studentInfo.dateOfBirth),
                ),
                _buildDetailRow(
                  'Gender',
                  admission.studentInfo.gender.toUpperCase(),
                ),
                if (admission.studentInfo.previousSchool != null)
                  _buildDetailRow(
                    'Previous School',
                    admission.studentInfo.previousSchool!,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Parent Information Section
            _buildDetailSection(
              'Parent Information',
              Icons.family_restroom,
              Colors.green,
              [
                _buildDetailRow('Parent Name', admission.parentInfo.name),
                _buildDetailRow('Phone', admission.parentInfo.phone),
                _buildDetailRow('Email', admission.parentInfo.email),
                _buildDetailRow('Occupation', admission.parentInfo.occupation),
                _buildDetailRow('Address', admission.parentInfo.address),
              ],
            ),
            const SizedBox(height: 16),

            // Academic Information Section
            _buildDetailSection(
              'Academic Information',
              Icons.school,
              Colors.purple,
              [
                _buildDetailRow(
                  'Desired Class',
                  admission.academicInfo.desiredClass,
                ),
                _buildDetailRow(
                  'Academic Year',
                  admission.academicInfo.academicYear,
                ),
                _buildDetailRow(
                  'Submitted At',
                  _formatDate(admission.submittedAt),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Review Information Section (if available)
            if (admission.reviewInfo != null) ...[
              _buildDetailSection(
                'Review Information',
                Icons.rate_review,
                Colors.orange,
                [
                  if (admission.reviewInfo!.reviewedAt != null)
                    _buildDetailRow(
                      'Reviewed At',
                      _formatDate(admission.reviewInfo!.reviewedAt!),
                    ),
                  if (admission.reviewInfo!.reviewNotes != null)
                    _buildDetailRow(
                      'Review Notes',
                      admission.reviewInfo!.reviewNotes!,
                    ),
                  if (admission.reviewInfo!.rejectionReason != null)
                    _buildDetailRow(
                      'Rejection Reason',
                      admission.reviewInfo!.rejectionReason!,
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Additional Information (if available)
            if (admission.additionalInfo != null &&
                admission.additionalInfo!.isNotEmpty) ...[
              _buildDetailSection(
                'Additional Information',
                Icons.info,
                Colors.teal,
                [_buildDetailRow('Notes', admission.additionalInfo!)],
              ),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            _buildReviewActionButtons(admission),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Color(0xFF34495E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewActionButtons(AdmissionModel admission) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showAdmissionModal(admission),
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showRejectDialog(admission.id),
            icon: const Icon(Icons.cancel, size: 18),
            label: const Text('Reject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showAdmissionDetails(admission),
            icon: const Icon(Icons.visibility, size: 18),
            label: const Text('View Full'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildAdmissionCard(AdmissionModel admission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.blue[100],
                  child:
                      admission.studentInfo.picture != null
                          ? ClipOval(
                            child: Image.network(
                              admission.studentInfo.picture!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 25,
                                  color: Colors.blue[800],
                                );
                              },
                            ),
                          )
                          : Icon(
                            Icons.person,
                            size: 25,
                            color: Colors.blue[800],
                          ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admission.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      Text(
                        'Age: ${admission.age} years • ${admission.studentInfo.gender}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        'Parent: ${admission.parentInfo.name}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(admission.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.school, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Desired Class: ${admission.academicInfo.desiredClass}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Submitted: ${_formatDate(admission.submittedAt)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildActionButtons(admission),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'under_review':
        color = Colors.blue;
        break;
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'admitted':
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _getStatusDisplay(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButtons(AdmissionModel admission) {
    return Row(
      children: [
        if (admission.status == 'pending') ...[
          ElevatedButton.icon(
            onPressed:
                () => _updateAdmissionStatus(admission.id, 'under_review'),
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('Review'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _showAdmissionModal(admission),
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _showRejectDialog(admission.id),
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Reject'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ] else if (admission.status == 'under_review') ...[
          ElevatedButton.icon(
            onPressed: () => _showAdmissionModal(admission),
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _showRejectDialog(admission.id),
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Reject'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ] else if (admission.status == 'approved') ...[
          ElevatedButton.icon(
            onPressed: () => _admitStudent(admission.id),
            icon: const Icon(Icons.school, size: 16),
            label: const Text('Admit Student'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
        const Spacer(),
        TextButton.icon(
          onPressed: () => _showAdmissionDetails(admission),
          icon: const Icon(Icons.visibility, size: 16),
          label: const Text('View Details'),
        ),
      ],
    );
  }

  void _showAdmissionModal(AdmissionModel admission) {
    showDialog(
      context: context,
      builder:
          (context) => AdmissionDetailsModal(
            admission: admission,
            onApprove: (additionalData) async {
              Navigator.pop(context);
              await _admitStudentWithDetails(admission.id, additionalData);
            },
          ),
    );
  }

  Future<void> _admitStudentWithDetails(
    String admissionId,
    Map<String, dynamic> additionalData,
  ) async {
    final admissionProvider = ref.read(RiverpodProvider.admissionProvider);
    final success = await admissionProvider.admitStudent(
      ref.read(RiverpodProvider.profileProvider).user?.id ?? '',
      context,
      admissionId,
      additionalStudentData: additionalData,
    );

    if (success) {
      showSnackbar(context, 'Student admitted successfully!');
    } else {
      showSnackbar(context, 'Failed to admit student');
    }
  }

  void _showRejectDialog(String admissionId) {
    final rejectionReasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reject Admission'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please provide a reason for rejection:'),
                const SizedBox(height: 16),
                TextField(
                  controller: rejectionReasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Enter rejection reason...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateAdmissionStatus(
                    admissionId,
                    'rejected',
                    rejectionReason: rejectionReasonController.text,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Reject'),
              ),
            ],
          ),
    );
  }

  void _showAdmissionDetails(AdmissionModel admission) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Admission Details - ${admission.fullName}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Student Name', admission.fullName),
                  _buildDetailRow('Age', '${admission.age} years'),
                  _buildDetailRow('Gender', admission.studentInfo.gender),
                  _buildDetailRow(
                    'Date of Birth',
                    _formatDate(admission.studentInfo.dateOfBirth),
                  ),
                  _buildDetailRow(
                    'Previous School',
                    admission.studentInfo.previousSchool ?? 'N/A',
                  ),
                  const Divider(),
                  _buildDetailRow('Parent Name', admission.parentInfo.name),
                  _buildDetailRow('Parent Phone', admission.parentInfo.phone),
                  _buildDetailRow('Parent Email', admission.parentInfo.email),
                  _buildDetailRow(
                    'Parent Occupation',
                    admission.parentInfo.occupation,
                  ),
                  _buildDetailRow(
                    'Parent Address',
                    admission.parentInfo.address,
                  ),
                  const Divider(),
                  _buildDetailRow(
                    'Desired Class',
                    admission.academicInfo.desiredClass,
                  ),
                  _buildDetailRow(
                    'Academic Year',
                    admission.academicInfo.academicYear,
                  ),
                  _buildDetailRow('Status', admission.statusDisplay),
                  _buildDetailRow(
                    'Submitted At',
                    _formatDate(admission.submittedAt),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'pending':
        return 'Pending Review';
      case 'under_review':
        return 'Under Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'admitted':
        return 'Admitted';
      default:
        return status;
    }
  }
}

class AdmissionDetailsModal extends ConsumerStatefulWidget {
  final AdmissionModel admission;
  final Function(Map<String, dynamic>) onApprove;

  const AdmissionDetailsModal({
    super.key,
    required this.admission,
    required this.onApprove,
  });

  @override
  ConsumerState<AdmissionDetailsModal> createState() =>
      _AdmissionDetailsModalState();
}

class _AdmissionDetailsModalState extends ConsumerState<AdmissionDetailsModal>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isUploadingImage = false;

  // Image upload variables
  XFile? _selectedImageFile;
  String? _imageUrl;
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers - Student Personal Info
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _emergencyContactRelationshipController = TextEditingController();

  // Parent controllers - Father
  final _fatherTitleController = TextEditingController();
  final _fatherFirstNameController = TextEditingController();
  final _fatherLastNameController = TextEditingController();
  final _fatherMiddleNameController = TextEditingController();
  final _fatherDobController = TextEditingController();
  final _fatherPhoneController = TextEditingController();
  final _fatherEmailController = TextEditingController();
  final _fatherOccupationController = TextEditingController();
  final _fatherEmployerController = TextEditingController();
  final _fatherAddressController = TextEditingController();

  // Parent controllers - Mother
  final _motherTitleController = TextEditingController();
  final _motherFirstNameController = TextEditingController();
  final _motherLastNameController = TextEditingController();
  final _motherMiddleNameController = TextEditingController();
  final _motherDobController = TextEditingController();
  final _motherPhoneController = TextEditingController();
  final _motherEmailController = TextEditingController();
  final _motherOccupationController = TextEditingController();
  final _motherEmployerController = TextEditingController();
  final _motherAddressController = TextEditingController();

  // Academic controllers
  final _admissionNumberController = TextEditingController();
  final _admissionDateController = TextEditingController();

  // Selected values
  String _selectedStudentType = 'new';
  DateTime? _selectedAdmissionDate;

  // Class data
  List<dynamic> _classes = [];
  bool _isLoadingClasses = false;

  // Country and state selection
  String? _selectedCountry;
  String? _selectedState;

  // Comprehensive country and state data
  final Map<String, List<String>> _countriesWithStates = {
    'Nigeria': [
      'Abia',
      'Adamawa',
      'Akwa Ibom',
      'Anambra',
      'Bauchi',
      'Bayelsa',
      'Benue',
      'Borno',
      'Cross River',
      'Delta',
      'Ebonyi',
      'Edo',
      'Ekiti',
      'Enugu',
      'FCT',
      'Gombe',
      'Imo',
      'Jigawa',
      'Kaduna',
      'Kano',
      'Katsina',
      'Kebbi',
      'Kogi',
      'Kwara',
      'Lagos',
      'Nasarawa',
      'Niger',
      'Ogun',
      'Ondo',
      'Osun',
      'Oyo',
      'Plateau',
      'Rivers',
      'Sokoto',
      'Taraba',
      'Yobe',
      'Zamfara',
    ],
    'United States': [
      'Alabama',
      'Alaska',
      'Arizona',
      'Arkansas',
      'California',
      'Colorado',
      'Connecticut',
      'Delaware',
      'Florida',
      'Georgia',
      'Hawaii',
      'Idaho',
      'Illinois',
      'Indiana',
      'Iowa',
      'Kansas',
      'Kentucky',
      'Louisiana',
      'Maine',
      'Maryland',
      'Massachusetts',
      'Michigan',
      'Minnesota',
      'Mississippi',
      'Missouri',
      'Montana',
      'Nebraska',
      'Nevada',
      'New Hampshire',
      'New Jersey',
      'New Mexico',
      'New York',
      'North Carolina',
      'North Dakota',
      'Ohio',
      'Oklahoma',
      'Oregon',
      'Pennsylvania',
      'Rhode Island',
      'South Carolina',
      'South Dakota',
      'Tennessee',
      'Texas',
      'Utah',
      'Vermont',
      'Virginia',
      'Washington',
      'West Virginia',
      'Wisconsin',
      'Wyoming',
    ],
    'United Kingdom': ['England', 'Scotland', 'Wales', 'Northern Ireland'],
    'Canada': [
      'Alberta',
      'British Columbia',
      'Manitoba',
      'New Brunswick',
      'Newfoundland and Labrador',
      'Northwest Territories',
      'Nova Scotia',
      'Nunavut',
      'Ontario',
      'Prince Edward Island',
      'Quebec',
      'Saskatchewan',
      'Yukon',
    ],
    'Australia': [
      'Australian Capital Territory',
      'New South Wales',
      'Northern Territory',
      'Queensland',
      'South Australia',
      'Tasmania',
      'Victoria',
      'Western Australia',
    ],
    'India': [
      'Andhra Pradesh',
      'Arunachal Pradesh',
      'Assam',
      'Bihar',
      'Chhattisgarh',
      'Goa',
      'Gujarat',
      'Haryana',
      'Himachal Pradesh',
      'Jharkhand',
      'Karnataka',
      'Kerala',
      'Madhya Pradesh',
      'Maharashtra',
      'Manipur',
      'Meghalaya',
      'Mizoram',
      'Nagaland',
      'Odisha',
      'Punjab',
      'Rajasthan',
      'Sikkim',
      'Tamil Nadu',
      'Telangana',
      'Tripura',
      'Uttar Pradesh',
      'Uttarakhand',
      'West Bengal',
    ],
    'South Africa': [
      'Eastern Cape',
      'Free State',
      'Gauteng',
      'KwaZulu-Natal',
      'Limpopo',
      'Mpumalanga',
      'Northern Cape',
      'North West',
      'Western Cape',
    ],
    'Ghana': [
      'Greater Accra',
      'Ashanti',
      'Western',
      'Eastern',
      'Volta',
      'Central',
      'Northern',
      'Upper East',
      'Upper West',
      'Brong-Ahafo',
    ],
    'Kenya': [
      'Nairobi',
      'Mombasa',
      'Kisumu',
      'Nakuru',
      'Eldoret',
      'Thika',
      'Malindi',
      'Kitale',
      'Garissa',
      'Kakamega',
    ],
    // Add more countries that might be selected
    'Antigua and Barbuda': [
      'Saint John',
      'Saint George',
      'Saint Mary',
      'Saint Paul',
      'Saint Peter',
      'Saint Philip',
    ],
    'Barbados': [
      'Christ Church',
      'Saint Michael',
      'Saint George',
      'Saint Philip',
      'Saint John',
      'Saint James',
      'Saint Thomas',
      'Saint Andrew',
      'Saint Joseph',
      'Saint Peter',
      'Saint Lucy',
    ],
    'Jamaica': [
      'Kingston',
      'Saint Andrew',
      'Saint Thomas',
      'Portland',
      'Saint Mary',
      'Saint Ann',
      'Trelawny',
      'Saint James',
      'Hanover',
      'Westmoreland',
      'Saint Elizabeth',
      'Manchester',
      'Clarendon',
      'Saint Catherine',
    ],
    'Trinidad and Tobago': [
      'Arima',
      'Chaguanas',
      'Couva-Tabaquite-Talparo',
      'Diego Martin',
      'Eastern Tobago',
      'Mayaro-Rio Claro',
      'Penal-Debe',
      'Princes Town',
      'Sangre Grande',
      'San Juan-Laventille',
      'Siparia',
      'Tunapuna-Piarco',
      'Western Tobago',
    ],
    'Guyana': [
      'Barima-Waini',
      'Cuyuni-Mazaruni',
      'Demerara-Mahaica',
      'East Berbice-Corentyne',
      'Essequibo Islands-West Demerara',
      'Mahaica-Berbice',
      'Pomeroon-Supenaam',
      'Potaro-Siparuni',
      'Upper Demerara-Berbice',
      'Upper Takutu-Upper Essequibo',
    ],
    'Belize': [
      'Belize',
      'Cayo',
      'Corozal',
      'Orange Walk',
      'Stann Creek',
      'Toledo',
    ],
    'Bahamas': [
      'Acklins',
      'Bimini',
      'Black Point',
      'Cat Island',
      'Central Abaco',
      'Central Andros',
      'Central Eleuthera',
      'Crooked Island',
      'East Grand Bahama',
      'Exuma',
      'Grand Cay',
      'Harbour Island',
      'Hope Town',
      'Inagua',
      'Long Island',
      'Mangrove Cay',
      'Mayaguana',
      'Moore\'s Island',
      'North Abaco',
      'North Andros',
      'North Eleuthera',
      'Ragged Island',
      'Rum Cay',
      'San Salvador',
      'South Abaco',
      'South Andros',
      'South Eleuthera',
      'Spanish Wells',
      'West Grand Bahama',
    ],
  };
  String? _selectedClassId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _admissionNumberController.text =
        'ADM-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    _selectedAdmissionDate = DateTime.now();
    _admissionDateController.text = _formatDate(_selectedAdmissionDate!);
    _loadClasses();
    _populateExistingData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _medicalConditionsController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _emergencyContactRelationshipController.dispose();
    _fatherTitleController.dispose();
    _fatherFirstNameController.dispose();
    _fatherLastNameController.dispose();
    _fatherMiddleNameController.dispose();
    _fatherDobController.dispose();
    _fatherPhoneController.dispose();
    _fatherEmailController.dispose();
    _fatherOccupationController.dispose();
    _fatherEmployerController.dispose();
    _fatherAddressController.dispose();
    _motherTitleController.dispose();
    _motherFirstNameController.dispose();
    _motherLastNameController.dispose();
    _motherMiddleNameController.dispose();
    _motherDobController.dispose();
    _motherPhoneController.dispose();
    _motherEmailController.dispose();
    _motherOccupationController.dispose();
    _motherEmployerController.dispose();
    _motherAddressController.dispose();
    _admissionNumberController.dispose();
    _admissionDateController.dispose();
    super.dispose();
  }

  void _populateExistingData() {
    // Populate parent data from admission
    final parentName = widget.admission.parentInfo.name.split(' ');
    _fatherFirstNameController.text =
        parentName.isNotEmpty ? parentName[0] : '';
    _fatherLastNameController.text =
        parentName.length > 1 ? parentName.sublist(1).join(' ') : '';
    _fatherPhoneController.text = widget.admission.parentInfo.phone;
    _fatherEmailController.text = widget.admission.parentInfo.email;
    _fatherOccupationController.text = widget.admission.parentInfo.occupation;
    _fatherAddressController.text = widget.admission.parentInfo.address;

    // Set the desired class
    _selectedClassId = widget.admission.academicInfo.desiredClassId;
  }

  Future<void> _loadClasses() async {
    setState(() {
      _isLoadingClasses = true;
    });

    try {
      final classProvider = ref.read(RiverpodProvider.classProvider);
      await classProvider.getAllClassesWithMetric(context);

      if (classProvider.classData.classes != null) {
        setState(() {
          _classes = classProvider.classData.classes!;
        });
      }
    } catch (e) {
      showSnackbar(context, 'Failed to load classes: $e');
    } finally {
      setState(() {
        _isLoadingClasses = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String? _getSelectedClassName() {
    if (_selectedClassId == null) return null;

    try {
      final selectedClass = _classes.firstWhere(
        (c) => c?.id == _selectedClassId,
      );
      return'${ selectedClass?.level} (${selectedClass?.name})' ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  // Helper method to get states for selected country
  List<String> _getStatesForCountry(String? country) {
    if (country == null || country.isEmpty) {
      print('_getStatesForCountry: country is null or empty');
      return [];
    }

    final states = _countriesWithStates[country] ?? [];

    // If no states found, provide a generic fallback
    if (states.isEmpty) {
      print(
        '_getStatesForCountry: No states found for $country, using fallback',
      );
      return ['Not Available']; // Fallback for countries without states
    }

    print('_getStatesForCountry: country=$country, states=$states');
    return states;
  }

  // Method to build country picker
  Widget _buildCountryPicker({
    required String label,
    required String? value,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label${isRequired ? ' *' : ''}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            showCountryPicker(
              context: context,
              onSelect: (Country country) {
                print('Country selected: ${country.name}');
                setState(() {
                  _selectedCountry = country.name;
                  _selectedState = null; // Reset state when country changes
                  _countryController.text = country.name;
                  _stateController.text = ''; // Clear state field
                });
                onChanged(country.name);
                print(
                  'After selection - _selectedCountry: $_selectedCountry, _selectedState: $_selectedState',
                );
              },
              showPhoneCode: false,
              showWorldWide: true,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? 'Select Country',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          value == null ? Colors.grey.shade500 : Colors.black87,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Method to build state dropdown with dynamic states based on country
  Widget _buildStateDropdown({
    required String label,
    required String? value,
    required String? country,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    final states = _getStatesForCountry(country);

    // Debug print to help troubleshoot
    print(
      'State dropdown - Country: $country, States: $states, Selected: $value',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label${isRequired ? ' *' : ''}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        // Debug info
        if (country != null)
          Text(
            'Debug: Country="$country", States=${states.length}, Selected="$value"',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: ValueKey(country), // Force rebuild when country changes
              value:
                  states.contains(value)
                      ? value
                      : null, // Only show value if it's in the current states list
              hint: Text(
                states.isEmpty
                    ? 'Select Country First'
                    : states.contains('Not Available')
                    ? 'State Not Available'
                    : 'Select State',
                style: TextStyle(color: Colors.grey.shade500),
              ),
              isExpanded: true,
              items:
                  states.map((String state) {
                    print('Creating dropdown item for state: $state');
                    return DropdownMenuItem<String>(
                      value: state,
                      child: Text(state),
                    );
                  }).toList(),
              onChanged:
                  states.isEmpty
                      ? (String? newValue) {
                        print(
                          'State dropdown is disabled - states.isEmpty: ${states.isEmpty}',
                        );
                        return null;
                      }
                      : (String? newValue) {
                        print('State selected: $newValue');
                        // Handle "Not Available" case
                        if (newValue == 'Not Available') {
                          setState(() {
                            _selectedState = null;
                            _stateController.text = '';
                          });
                          print('State set to null for "Not Available"');
                          return;
                        }
                        onChanged(newValue);
                        setState(() {
                          _selectedState = newValue;
                          _stateController.text = newValue ?? '';
                        });
                        print(
                          'After state selection - _selectedState: $_selectedState',
                        );
                      },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isAdmissionDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isAdmissionDate
              ? _selectedAdmissionDate ?? DateTime.now()
              : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isAdmissionDate) {
          _selectedAdmissionDate = picked;
          _admissionDateController.text = _formatDate(picked);
        }
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImageFile = image;
        });
        await _uploadImageToCloudinary();
      }
    } catch (e) {
      showSnackbar(context, 'Error picking image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImageFile = image;
        });
        await _uploadImageToCloudinary();
      }
    } catch (e) {
      showSnackbar(context, 'Error taking photo: $e');
    }
  }

  Future<void> _uploadImageToCloudinary() async {
    if (_selectedImageFile == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final bytes = await _selectedImageFile!.readAsBytes();
      final compressedBytes = await _compressImage(bytes);

      final base64Image = base64Encode(compressedBytes);
      final uploadUrl = 'https://api.cloudinary.com/v1_1/demo/image/upload';

      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['upload_preset'] = 'ml_default';
      request.fields['file'] = 'data:image/jpeg;base64,$base64Image';

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);
        setState(() {
          _imageUrl = jsonData['secure_url'];
        });
        showSnackbar(context, 'Image uploaded successfully!');
      } else {
        showSnackbar(context, 'Failed to upload image');
      }
    } catch (e) {
      showSnackbar(context, 'Error uploading image: $e');
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<Uint8List> _compressImage(Uint8List bytes) async {
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    final resizedImage = img.copyResize(image, width: 400, height: 400);
    return Uint8List.fromList(img.encodeJpg(resizedImage, quality: 85));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? ' *' : ''),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isRequired ? Colors.red : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator:
              isRequired
                  ? (value) {
                    if (value == null || value.isEmpty) {
                      return '$label is required';
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? ' *' : ''),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isRequired ? Colors.red : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: onChanged,
          validator:
              isRequired
                  ? (value) {
                    if (value == null || value.isEmpty) {
                      return '$label is required';
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Picture',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  _imageUrl != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person, size: 50);
                          },
                        ),
                      )
                      : _selectedImageFile != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedImageFile!.path),
                          fit: BoxFit.cover,
                        ),
                      )
                      : const Icon(Icons.person, size: 50),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isUploadingImage ? null : _pickImage,
                    icon:
                        _isUploadingImage
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.photo_library, size: 18),
                    label: Text(
                      _isUploadingImage ? 'Uploading...' : 'Choose Photo',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _isUploadingImage ? null : _takePhoto,
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Take Photo'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleApprove() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAdmissionDate == null) {
      showSnackbar(context, 'Please select an admission date');
      return;
    }

    if (_selectedClassId == null) {
      showSnackbar(context, 'Please select a class');
      return;
    }

    // Validate required fields for parent creation
    if (_fatherFirstNameController.text.trim().isEmpty ||
        _fatherLastNameController.text.trim().isEmpty ||
        _fatherPhoneController.text.trim().isEmpty ||
        _fatherEmailController.text.trim().isEmpty ||
        _fatherOccupationController.text.trim().isEmpty) {
      showSnackbar(context, 'Please fill in all required parent information');
      return;
    }

    // Validate address fields
    if (_streetController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _selectedState == null ||
        _selectedCountry == null) {
      showSnackbar(context, 'Please fill in all address fields');
      return;
    }

    final additionalData = {
      'personalInfo': {
        'profileImage': _imageUrl,
        'gender': widget.admission.studentInfo.gender,
      },
      'contactInfo': {
        'address': {
          'street': _streetController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _selectedState ?? '',
          'country': _selectedCountry ?? '',
        },
        'phone':
            _phoneController.text.trim().isNotEmpty
                ? _phoneController.text.trim()
                : null,
        'email':
            _emailController.text.trim().isNotEmpty
                ? _emailController.text.trim()
                : null,
      },
      'medicalInfo': {
        'allergies':
            _allergiesController.text.trim().isNotEmpty
                ? _allergiesController.text.trim()
                : null,
        'medications':
            _medicationsController.text.trim().isNotEmpty
                ? _medicationsController.text.trim()
                : null,
        'medicalConditions':
            _medicalConditionsController.text.trim().isNotEmpty
                ? _medicalConditionsController.text.trim()
                : null,
        'emergencyContact': {
          'name':
              _emergencyContactNameController.text.trim().isNotEmpty
                  ? _emergencyContactNameController.text.trim()
                  : null,
          'phone':
              _emergencyContactPhoneController.text.trim().isNotEmpty
                  ? _emergencyContactPhoneController.text.trim()
                  : null,
          'relationship':
              _emergencyContactRelationshipController.text.trim().isNotEmpty
                  ? _emergencyContactRelationshipController.text.trim()
                  : null,
        },
      },
      'academicInfo': {
        'admissionDate':
            _selectedAdmissionDate!.toIso8601String().split('T')[0],
        'studentType':
            _selectedStudentType == 'new' ? 'day' : _selectedStudentType,
      },
      // Override parent data completely to fix the address issue
      'parentData': {
        'personalInfo': {
          'firstName': _fatherFirstNameController.text.trim(),
          'lastName': _fatherLastNameController.text.trim(),
          'middleName':
              _fatherMiddleNameController.text.trim().isNotEmpty
                  ? _fatherMiddleNameController.text.trim()
                  : null,
          'phone': _fatherPhoneController.text.trim(),
          'email': _fatherEmailController.text.trim(),
          'occupation': _fatherOccupationController.text.trim(),
          'gender': 'male',
          'title':
              _fatherTitleController.text.trim().isNotEmpty
                  ? _fatherTitleController.text.trim()
                  : 'Mr',
          'address': {
            'street': _streetController.text.trim(),
            'city': _cityController.text.trim(),
            'state': _selectedState ?? '',
            'country': _selectedCountry ?? '',
          },
        },
        'contactInfo': {
          'primaryPhone': _fatherPhoneController.text.trim(),
          'secondaryPhone': '',
          'email': _fatherEmailController.text.trim(),
          'address': {
            'street': _streetController.text.trim(),
            'city': _cityController.text.trim(),
            'state': _selectedState ?? '',
            'country': _selectedCountry ?? '',
          },
        },
        'relationship': 'father',
        'user': ref.read(RiverpodProvider.profileProvider).user?.id ?? '',
      },
      'parentInfo': {
        'father': {
          'personalInfo': {
            'firstName': _fatherFirstNameController.text.trim(),
            'lastName': _fatherLastNameController.text.trim(),
            'middleName':
                _fatherMiddleNameController.text.trim().isNotEmpty
                    ? _fatherMiddleNameController.text.trim()
                    : null,
            'phone': _fatherPhoneController.text.trim(),
            'email': _fatherEmailController.text.trim(),
            'occupation': _fatherOccupationController.text.trim(),
            'address': _fatherAddressController.text.trim(),
            'gender': 'male',
            'title':
                _fatherTitleController.text.trim().isNotEmpty
                    ? _fatherTitleController.text.trim()
                    : 'Mr',
          },
          'contactInfo': {
            'primaryPhone': _fatherPhoneController.text.trim(),
            'secondaryPhone': '',
            'email': _fatherEmailController.text.trim(),
            'address': {
              'street': _streetController.text.trim(),
              'city': _cityController.text.trim(),
              'state': _stateController.text.trim(),
              'country': _countryController.text.trim(),
            },
          },
          'relationship': 'father',
        },
        'mother': {
          'personalInfo': {
            'firstName': _motherFirstNameController.text.trim(),
            'lastName': _motherLastNameController.text.trim(),
            'middleName':
                _motherMiddleNameController.text.trim().isNotEmpty
                    ? _motherMiddleNameController.text.trim()
                    : null,
            'phone': _motherPhoneController.text.trim(),
            'email': _motherEmailController.text.trim(),
            'occupation': _motherOccupationController.text.trim(),
            'address': _motherAddressController.text.trim(),
            'gender': 'female',
            'title':
                _motherTitleController.text.trim().isNotEmpty
                    ? _motherTitleController.text.trim()
                    : 'Mrs',
          },
          'contactInfo': {
            'primaryPhone': _motherPhoneController.text.trim(),
            'secondaryPhone': '',
            'email': _motherEmailController.text.trim(),
            'address': {
              'street': _streetController.text.trim(),
              'city': _cityController.text.trim(),
              'state': _stateController.text.trim(),
              'country': _countryController.text.trim(),
            },
          },
          'relationship': 'mother',
        },
      },
    };

    widget.onApprove(additionalData);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_add, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Complete Student Admission',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Student: ${widget.admission.fullName}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              color: Colors.grey[100],
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.blue[800],
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Colors.blue[800],
                tabs: const [
                  Tab(text: 'Contact Info', icon: Icon(Icons.contact_phone)),
                  Tab(text: 'Medical Info', icon: Icon(Icons.medical_services)),
                  Tab(
                    text: 'Parent Details',
                    icon: Icon(Icons.family_restroom),
                  ),
                  Tab(text: 'Academic Info', icon: Icon(Icons.school)),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildContactInfoTab(),
                    _buildMedicalInfoTab(),
                    _buildParentDetailsTab(),
                    _buildAcademicInfoTab(),
                  ],
                ),
              ),
            ),

            // Footer with buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text('Approve Admission'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoTab() {
    print(
      'Building Contact Info Tab - _selectedCountry: $_selectedCountry, _selectedState: $_selectedState',
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _streetController,
            label: 'Street Address',
            isRequired: true,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStateDropdown(
                  label: 'State',
                  value: _selectedState,
                  country: _selectedCountry,
                  onChanged: (value) {
                    print('State dropdown onChanged called with: $value');
                    setState(() {
                      _selectedState = value;
                      _stateController.text = value ?? '';
                    });
                    print('After setState - _selectedState: $_selectedState');
                  },
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildCountryPicker(
                  label: 'Country',
                  value: _selectedCountry,
                  onChanged: (value) {
                    // This will be handled by the country picker's onSelect callback
                  },
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medical Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _allergiesController,
            label: 'Allergies',
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _medicationsController,
            label: 'Current Medications',
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _medicalConditionsController,
            label: 'Medical Conditions',
            maxLines: 2,
          ),
          const SizedBox(height: 20),

          const Text(
            'Emergency Contact',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _emergencyContactNameController,
                  label: 'Emergency Contact Name',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _emergencyContactPhoneController,
                  label: 'Emergency Contact Phone',
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _emergencyContactRelationshipController,
            label: 'Relationship to Student',
          ),
        ],
      ),
    );
  }

  Widget _buildParentDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Parent Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Father Information
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Father Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _fatherTitleController,
                        label: 'Title',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _fatherFirstNameController,
                        label: 'First Name',
                        isRequired: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _fatherMiddleNameController,
                        label: 'Middle Name',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _fatherLastNameController,
                        label: 'Last Name',
                        isRequired: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _fatherDobController,
                        label: 'Date of Birth',
                        readOnly: true,
                        onTap: () => _selectDate(context, false),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _fatherPhoneController,
                        label: 'Phone Number',
                        keyboardType: TextInputType.phone,
                        isRequired: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _fatherEmailController,
                  label: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  isRequired: true,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _fatherOccupationController,
                        label: 'Occupation',
                        isRequired: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _fatherEmployerController,
                        label: 'Employer',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _fatherAddressController,
                  label: 'Address',
                  isRequired: true,
                  maxLines: 2,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Mother Information
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.pink[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mother Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _motherTitleController,
                        label: 'Title',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _motherFirstNameController,
                        label: 'First Name',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _motherMiddleNameController,
                        label: 'Middle Name',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _motherLastNameController,
                        label: 'Last Name',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _motherDobController,
                        label: 'Date of Birth',
                        readOnly: true,
                        onTap: () => _selectDate(context, false),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _motherPhoneController,
                        label: 'Phone Number',
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _motherEmailController,
                  label: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _motherOccupationController,
                        label: 'Occupation',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _motherEmployerController,
                        label: 'Employer',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _motherAddressController,
                  label: 'Address',
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Academic Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          _buildImageUploadSection(),
          const SizedBox(height: 20),

          // _buildTextField(
          //   controller: _admissionNumberController,
          //   label: 'Admission Number',
          //   isRequired: true,
          //   readOnly: true,
          // ),
          // const SizedBox(height: 16),
          _buildTextField(
            controller: _admissionDateController,
            label: 'Admission Date',
            isRequired: true,
            readOnly: true,
            onTap: () => _selectDate(context, true),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          const SizedBox(height: 16),

          _buildDropdown(
            label: 'Student Type',
            value: _selectedStudentType,
            items: const ['new', 'transfer', 'returning'],
            onChanged: (value) {
              setState(() {
                _selectedStudentType = value!;
              });
            },
            isRequired: true,
          ),
          const SizedBox(height: 16),

          if (_isLoadingClasses)
            const Center(child: CircularProgressIndicator())
          else
            _buildDropdown(
              label: 'Class Assignment',
              value: _getSelectedClassName(),
              items:
                  _classes
                      .map((c) => '${c?.level} (${c?.name})' ?? 'Unknown')
                      .cast<String>()
                      .toSet()
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClassId =
                      _classes.firstWhere((c) => '${c?.level} (${c?.name})' == value)?.id;
                });
              },
              isRequired: true,
            ),
        ],
      ),
    );
  }
}
