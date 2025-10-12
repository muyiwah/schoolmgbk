import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schmgtsystem/models/admission_model.dart' as admission_model;
import 'package:schmgtsystem/models/adminssion_intent_model.dart'
    as intent_model;
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
                  _formatDate(admission.personalInfo.dateOfBirth),
                ),
                _buildDetailRow(
                  'Gender',
                  admission.personalInfo.gender.toUpperCase(),
                ),
                if (admission.personalInfo.nationality != null)
                  _buildDetailRow(
                    'Nationality',
                    admission.personalInfo.nationality!,
                  ),
                if (admission.personalInfo.previousSchool != null)
                  _buildDetailRow(
                    'Previous School',
                    admission.personalInfo.previousSchool!,
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
                if (admission.parentInfo.legacy != null) ...[
                  _buildDetailRow(
                    'Parent Name',
                    admission.parentInfo.legacy!.name,
                  ),
                  _buildDetailRow('Phone', admission.parentInfo.legacy!.phone),
                  _buildDetailRow('Email', admission.parentInfo.legacy!.email),
                  _buildDetailRow(
                    'Occupation',
                    admission.parentInfo.legacy!.occupation,
                  ),
                  _buildDetailRow(
                    'Address',
                    admission.parentInfo.legacy!.address,
                  ),
                ] else ...[
                  _buildDetailRow(
                    'Father ID',
                    admission.parentInfo.father ?? 'Not provided',
                  ),
                  _buildDetailRow(
                    'Mother ID',
                    admission.parentInfo.mother ?? 'Not provided',
                  ),
                  _buildDetailRow(
                    'Guardian ID',
                    admission.parentInfo.guardian ?? 'Not provided',
                  ),
                ],
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
                if (admission.academicInfo.studentType != null)
                  _buildDetailRow(
                    'Student Type',
                    admission.academicInfo.studentType!,
                  ),
                if (admission.academicInfo.admissionDate != null)
                  _buildDetailRow(
                    'Admission Date',
                    _formatDate(admission.academicInfo.admissionDate!),
                  ),
                _buildDetailRow(
                  'Submitted At',
                  _formatDate(admission.submittedAt),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Contact Information Section
            _buildDetailSection(
              'Contact Information',
              Icons.contact_phone,
              Colors.teal,
              [
                _buildDetailRow(
                  'Phone',
                  admission.contactInfo.phone ?? 'Not provided',
                ),
                _buildDetailRow(
                  'Email',
                  admission.contactInfo.email ?? 'Not provided',
                ),
                _buildDetailRow(
                  'Street',
                  admission.contactInfo.address.streetName ?? 'Not provided',
                ),
                _buildDetailRow(
                  'City',
                  admission.contactInfo.address.city ?? 'Not provided',
                ),
                _buildDetailRow(
                  'State',
                  admission.contactInfo.address.state ?? 'Not provided',
                ),
                _buildDetailRow(
                  'Country',
                  admission.contactInfo.address.country ?? 'Not provided',
                ),
                _buildDetailRow(
                  'Postal Code',
                  admission.contactInfo.address.postalCode ?? 'Not provided',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Medical Information Section (if available)
            if (admission.medicalInfo != null) ...[
              _buildDetailSection(
                'Medical Information',
                Icons.medical_services,
                Colors.red,
                [
                  if (admission.medicalInfo!.medicalHistory != null)
                    _buildDetailRow(
                      'Medical History',
                      admission.medicalInfo!.medicalHistory!,
                    ),
                  if (admission.medicalInfo!.allergies != null &&
                      admission.medicalInfo!.allergies!.isNotEmpty)
                    _buildDetailRow(
                      'Allergies',
                      admission.medicalInfo!.allergies!.join(', '),
                    ),
                  if (admission.medicalInfo!.currentMedication != null)
                    _buildDetailRow(
                      'Current Medication',
                      admission.medicalInfo!.currentMedication!,
                    ),
                  if (admission.medicalInfo!.dietaryRequirements != null)
                    _buildDetailRow(
                      'Dietary Requirements',
                      admission.medicalInfo!.dietaryRequirements!,
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Session Information Section (if available)
            if (admission.sessionInfo != null) ...[
              _buildDetailSection(
                'Session Information',
                Icons.schedule,
                Colors.orange,
                [
                  if (admission.sessionInfo!.requestedStartDate != null)
                    _buildDetailRow(
                      'Requested Start Date',
                      admission.sessionInfo!.requestedStartDate!,
                    ),
                  if (admission.sessionInfo!.daysOfAttendance != null)
                    _buildDetailRow(
                      'Days of Attendance',
                      admission.sessionInfo!.daysOfAttendance!,
                    ),
                  if (admission.sessionInfo!.fundedHours != null)
                    _buildDetailRow(
                      'Funded Hours',
                      admission.sessionInfo!.fundedHours!,
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Financial Information Section (if available)
            if (admission.financialInfo != null) ...[
              _buildDetailSection(
                'Financial Information',
                Icons.account_balance_wallet,
                Colors.green,
                [
                  _buildDetailRow(
                    'Fee Status',
                    admission.financialInfo!.feeStatus,
                  ),
                  _buildDetailRow(
                    'Total Fees',
                    '£${admission.financialInfo!.totalFees.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow(
                    'Paid Amount',
                    '£${admission.financialInfo!.paidAmount.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow(
                    'Outstanding Balance',
                    '£${admission.financialInfo!.outstandingBalance.toStringAsFixed(2)}',
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
                      admission.personalInfo.profileImage != null
                          ? ClipOval(
                            child: Image.network(
                              admission.personalInfo.profileImage!,
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
                        'Age: ${admission.age} years • ${admission.personalInfo.gender}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        'Parent: ${admission.parentInfo.legacy?.name ?? 'Not provided'}',
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

  Widget _buildActionButtons(admission_model.AdmissionModel admission) {
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

  void _showAdmissionModal(admission_model.AdmissionModel admission) {
    // Convert AdmissionModel to AdmissionIntentModel.Admission
    final admissionData = intent_model.Admission(
      id: admission.id,
      personalInfo: intent_model.PersonalInfo(
        firstName: admission.personalInfo.firstName,
        middleName: admission.personalInfo.middleName,
        lastName: admission.personalInfo.lastName,
        dateOfBirth: admission.personalInfo.dateOfBirth,
        gender: admission.personalInfo.gender,
        nationality: admission.personalInfo.nationality,
        stateOfOrigin: admission.personalInfo.stateOfOrigin,
        localGovernment: admission.personalInfo.localGovernment,
        religion: admission.personalInfo.religion,
        bloodGroup: admission.personalInfo.bloodGroup,
        languagesSpokenAtHome: admission.personalInfo.languagesSpokenAtHome,
        ethnicBackground: admission.personalInfo.ethnicBackground,
        formOfIdentification: admission.personalInfo.formOfIdentification,
        idNumber: admission.personalInfo.idNumber,
        hasSiblings: admission.personalInfo.hasSiblings,
        siblingDetails:
            admission.personalInfo.siblingDetails
                ?.map(
                  (s) => intent_model.SiblingDetail(
                    name: s.name,
                    age: s.age,
                    relationship: s.relationship,
                  ),
                )
                .toList(),
        profileImage: admission.personalInfo.profileImage,
        previousSchool: admission.personalInfo.previousSchool,
      ),
      contactInfo: intent_model.ContactInfo(
        address: intent_model.Address(
          streetNumber: admission.contactInfo.address.streetNumber,
          streetName: admission.contactInfo.address.streetName,
          city: admission.contactInfo.address.city,
          state: admission.contactInfo.address.state,
          country: admission.contactInfo.address.country,
          postalCode: admission.contactInfo.address.postalCode,
        ),
        phone: admission.contactInfo.phone,
        email: admission.contactInfo.email,
      ),
      academicInfo: intent_model.AcademicInfo(
        desiredClass:
            admission.academicInfo.desiredClass != null
                ? intent_model.DesiredClass(
                  id: admission.academicInfo.desiredClass,
                  name: '',
                  level: '',
                  section: '',
                  capacity: 0,
                )
                : null,
        academicYear: admission.academicInfo.academicYear,
        admissionDate: admission.academicInfo.admissionDate,
        studentType: admission.academicInfo.studentType,
      ),
      parentInfo: intent_model.ParentInfo(
        father: admission.parentInfo.father,
        mother: admission.parentInfo.mother,
        guardian: admission.parentInfo.guardian,
        legacy:
            admission.parentInfo.legacy != null
                ? intent_model.Legacy(
                  name: admission.parentInfo.legacy!.name,
                  phone: admission.parentInfo.legacy!.phone,
                  email: admission.parentInfo.legacy!.email,
                  occupation: admission.parentInfo.legacy!.occupation,
                  address: admission.parentInfo.legacy!.address,
                )
                : null,
      ),
      medicalInfo:
          admission.medicalInfo != null
              ? intent_model.MedicalInfo(
                generalPractitioner:
                    admission.medicalInfo!.generalPractitioner != null
                        ? intent_model.GeneralPractitioner(
                          name:
                              admission.medicalInfo!.generalPractitioner!.name,
                          address:
                              admission
                                  .medicalInfo!
                                  .generalPractitioner!
                                  .address,
                          telephoneNumber:
                              admission
                                  .medicalInfo!
                                  .generalPractitioner!
                                  .telephoneNumber,
                        )
                        : null,
                medicalHistory: admission.medicalInfo!.medicalHistory,
                allergies: admission.medicalInfo!.allergies,
                ongoingMedicalConditions:
                    admission.medicalInfo!.ongoingMedicalConditions,
                specialNeeds: admission.medicalInfo!.specialNeeds,
                currentMedication: admission.medicalInfo!.currentMedication,
                immunisationRecord: admission.medicalInfo!.immunisationRecord,
                dietaryRequirements: admission.medicalInfo!.dietaryRequirements,
                emergencyContact:
                    admission.medicalInfo!.emergencyContact != null
                        ? intent_model.EmergencyContact(
                          name: admission.medicalInfo!.emergencyContact!.name,
                          relationship:
                              admission
                                  .medicalInfo!
                                  .emergencyContact!
                                  .relationship,
                          phone: admission.medicalInfo!.emergencyContact!.phone,
                          email: admission.medicalInfo!.emergencyContact!.email,
                          address:
                              admission
                                          .medicalInfo!
                                          .emergencyContact!
                                          .address !=
                                      null
                                  ? intent_model.Address(
                                    streetNumber:
                                        admission
                                            .medicalInfo!
                                            .emergencyContact!
                                            .address!
                                            .streetNumber,
                                    streetName:
                                        admission
                                            .medicalInfo!
                                            .emergencyContact!
                                            .address!
                                            .streetName,
                                    city:
                                        admission
                                            .medicalInfo!
                                            .emergencyContact!
                                            .address!
                                            .city,
                                    state:
                                        admission
                                            .medicalInfo!
                                            .emergencyContact!
                                            .address!
                                            .state,
                                    country:
                                        admission
                                            .medicalInfo!
                                            .emergencyContact!
                                            .address!
                                            .country,
                                    postalCode:
                                        admission
                                            .medicalInfo!
                                            .emergencyContact!
                                            .address!
                                            .postalCode,
                                  )
                                  : null,
                          authorisedToCollectChild:
                              admission
                                  .medicalInfo!
                                  .emergencyContact!
                                  .authorisedToCollectChild,
                        )
                        : null,
              )
              : null,
      senInfo:
          admission.senInfo != null
              ? intent_model.SenInfo(
                hasSpecialNeeds: admission.senInfo!.hasSpecialNeeds,
                receivingAdditionalSupport:
                    admission.senInfo!.receivingAdditionalSupport,
                supportDetails: admission.senInfo!.supportDetails,
                hasEhcp: admission.senInfo!.hasEHCP,
                ehcpDetails: admission.senInfo!.ehcpDetails,
              )
              : null,
      permissions:
          admission.permissions != null
              ? intent_model.Permissions(
                emergencyMedicalTreatment:
                    admission.permissions!.emergencyMedicalTreatment,
                administrationOfMedication:
                    admission.permissions!.administrationOfMedication,
                firstAidConsent: admission.permissions!.firstAidConsent,
                outingsAndTrips: admission.permissions!.outingsAndTrips,
                transportConsent: admission.permissions!.transportConsent,
                useOfPhotosVideos: admission.permissions!.useOfPhotosVideos,
                suncreamApplication: admission.permissions!.suncreamApplication,
                observationAndAssessment:
                    admission.permissions!.observationAndAssessment,
              )
              : null,
      sessionInfo:
          admission.sessionInfo != null
              ? intent_model.SessionInfo(
                requestedStartDate:
                    admission.sessionInfo!.requestedStartDate != null
                        ? DateTime.tryParse(
                          admission.sessionInfo!.requestedStartDate!,
                        )
                        : null,
                daysOfAttendance: admission.sessionInfo!.daysOfAttendance,
                fundedHours: admission.sessionInfo!.fundedHours,
                additionalPaidSessions:
                    admission.sessionInfo!.additionalPaidSessions,
                preferredSettlingInSessions:
                    admission.sessionInfo!.preferredSettlingInSessions,
              )
              : null,
      backgroundInfo:
          admission.backgroundInfo != null
              ? intent_model.BackgroundInfo(
                previousChildcareProvider:
                    admission.backgroundInfo!.previousChildcareProvider,
                siblings:
                    admission.backgroundInfo!.siblings
                        ?.map(
                          (s) => intent_model.Sibling(name: s.name, age: s.age),
                        )
                        .toList(),
                interests: admission.backgroundInfo!.interests,
                toiletTrainingStatus:
                    admission.backgroundInfo!.toiletTrainingStatus,
                comfortItems: admission.backgroundInfo!.comfortItems,
                sleepRoutine: admission.backgroundInfo!.sleepRoutine,
                behaviouralConcerns:
                    admission.backgroundInfo!.behaviouralConcerns,
                languagesSpokenAtHome:
                    admission.backgroundInfo!.languagesSpokenAtHome,
              )
              : null,
      legalInfo:
          admission.legalInfo != null
              ? intent_model.LegalInfo(
                legalResponsibility: admission.legalInfo!.legalResponsibility,
                courtOrders: admission.legalInfo!.courtOrders,
                safeguardingDisclosure:
                    admission.legalInfo!.safeguardingDisclosure,
                parentSignature: admission.legalInfo!.parentSignature,
                signatureDate:
                    admission.legalInfo!.signatureDate != null
                        ? DateTime.tryParse(admission.legalInfo!.signatureDate!)
                        : null,
              )
              : null,
      fundingInfo:
          admission.fundingInfo != null
              ? intent_model.FundingInfo(
                agreementToPayFees: admission.fundingInfo!.agreementToPayFees,
                fundingAgreement: admission.fundingInfo!.fundingAgreement,
              )
              : null,

      additionalInfo: admission.additionalInfo,
      status: admission.status,
      submittedAt: admission.submittedAt,
      submittedBy: admission.submittedBy,
    );

    showDialog(
      context: context,
      builder:
          (context) => AdmissionDetailsModal(
            admissionData: admissionData,
            onApprove: (updatedData) async {
              Navigator.pop(context);
              await _admitStudentWithDetails(admission.id, updatedData);
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
                  _buildDetailRow('Gender', admission.personalInfo.gender),
                  _buildDetailRow(
                    'Date of Birth',
                    _formatDate(admission.personalInfo.dateOfBirth),
                  ),
                  _buildDetailRow(
                    'Previous School',
                    admission.personalInfo.previousSchool ?? 'N/A',
                  ),
                  const Divider(),
                  _buildDetailRow(
                    'Parent Name',
                    admission.parentInfo.legacy?.name ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Parent Phone',
                    admission.parentInfo.legacy?.phone ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Parent Email',
                    admission.parentInfo.legacy?.email ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Parent Occupation',
                    admission.parentInfo.legacy?.occupation ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Parent Address',
                    admission.parentInfo.legacy?.address ?? 'N/A',
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
  final intent_model.Admission
  admissionData; // Use AdmissionIntentModel.Admission
  final Function(Map<String, dynamic>) onApprove;

  const AdmissionDetailsModal({
    super.key,
    required this.admissionData,
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
  // Personal Info
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _stateOfOriginController = TextEditingController();
  final _localGovernmentController = TextEditingController();
  final _religionController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _languagesSpokenController = TextEditingController();
  final _ethnicBackgroundController = TextEditingController();
  final _formOfIdentificationController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _previousSchoolController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDob;
  bool _hasSiblings = false;
  List<Map<String, dynamic>> _siblingDetails = [];

  // Contact Info
  final _streetNumberController = TextEditingController();
  final _streetNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Academic Info
  final _academicYearController = TextEditingController();
  final _studentTypeController = TextEditingController();
  String? _selectedClassId;

  // Medical Info
  final _gpNameController = TextEditingController();
  final _gpAddressController = TextEditingController();
  final _gpPhoneController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _ongoingConditionsController = TextEditingController();
  final _specialNeedsController = TextEditingController();
  final _currentMedicationController = TextEditingController();
  final _immunisationController = TextEditingController();
  final _dietaryRequirementsController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _emergencyContactRelationshipController = TextEditingController();
  final _emergencyContactEmailController = TextEditingController();
  final _emergencyStreetNumberController = TextEditingController();
  final _emergencyStreetNameController = TextEditingController();
  final _emergencyCityController = TextEditingController();
  final _emergencyStateController = TextEditingController();
  final _emergencyCountryController = TextEditingController();
  final _emergencyPostalCodeController = TextEditingController();
  bool _emergencyAuthorisedToCollect = false;

  // SEN Info
  bool _hasSpecialNeeds = false;
  bool _receivingAdditionalSupport = false;
  final _supportDetailsController = TextEditingController();
  bool _hasEHCP = false;
  final _ehcpDetailsController = TextEditingController();

  // Permissions
  bool _emergencyMedicalTreatment = false;
  bool _administrationOfMedication = false;
  bool _firstAidConsent = false;
  bool _outingsAndTrips = false;
  bool _transportConsent = false;
  bool _useOfPhotosVideos = false;
  bool _suncreamApplication = false;
  bool _observationAndAssessment = false;

  // Session Info
  final _requestedStartDateController = TextEditingController();
  final _daysOfAttendanceController = TextEditingController();
  final _fundedHoursController = TextEditingController();
  final _additionalPaidSessionsController = TextEditingController();
  final _preferredSettlingController = TextEditingController();

  // Background Info
  final _previousChildcareController = TextEditingController();
  final _interestsController = TextEditingController();
  final _toiletTrainingController = TextEditingController();
  final _comfortItemsController = TextEditingController();
  final _sleepRoutineController = TextEditingController();
  final _behaviouralConcernsController = TextEditingController();

  // Legal Info
  final _legalResponsibilityController = TextEditingController();
  final _courtOrdersController = TextEditingController();
  final _safeguardingController = TextEditingController();
  final _parentSignatureController = TextEditingController();
  final _signatureDateController = TextEditingController();

  // Funding Info
  bool _agreementToPayFees = false;
  final _fundingAgreementController = TextEditingController();

  // Financial Info
  final _feeStatusController = TextEditingController();
  final _totalFeesController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _outstandingBalanceController = TextEditingController();

  // Additional Info
  final _additionalInfoController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
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

    // Personal Info
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _nationalityController.dispose();
    _stateOfOriginController.dispose();
    _localGovernmentController.dispose();
    _religionController.dispose();
    _bloodGroupController.dispose();
    _languagesSpokenController.dispose();
    _ethnicBackgroundController.dispose();
    _formOfIdentificationController.dispose();
    _idNumberController.dispose();
    _previousSchoolController.dispose();

    // Contact Info
    _streetNumberController.dispose();
    _streetNameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();

    // Academic Info
    _academicYearController.dispose();
    _admissionDateController.dispose();
    _studentTypeController.dispose();

    // Medical Info
    _gpNameController.dispose();
    _gpAddressController.dispose();
    _gpPhoneController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    _ongoingConditionsController.dispose();
    _specialNeedsController.dispose();
    _currentMedicationController.dispose();
    _immunisationController.dispose();
    _dietaryRequirementsController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _emergencyContactRelationshipController.dispose();
    _emergencyContactEmailController.dispose();
    _emergencyStreetNumberController.dispose();
    _emergencyStreetNameController.dispose();
    _emergencyCityController.dispose();
    _emergencyStateController.dispose();
    _emergencyCountryController.dispose();
    _emergencyPostalCodeController.dispose();

    // SEN Info
    _supportDetailsController.dispose();
    _ehcpDetailsController.dispose();

    // Session Info
    _requestedStartDateController.dispose();
    _daysOfAttendanceController.dispose();
    _fundedHoursController.dispose();
    _additionalPaidSessionsController.dispose();
    _preferredSettlingController.dispose();

    // Background Info
    _previousChildcareController.dispose();
    _interestsController.dispose();
    _toiletTrainingController.dispose();
    _comfortItemsController.dispose();
    _sleepRoutineController.dispose();
    _behaviouralConcernsController.dispose();

    // Legal Info
    _legalResponsibilityController.dispose();
    _courtOrdersController.dispose();
    _safeguardingController.dispose();
    _parentSignatureController.dispose();
    _signatureDateController.dispose();

    // Funding Info
    _fundingAgreementController.dispose();

    // Financial Info
    _feeStatusController.dispose();
    _totalFeesController.dispose();
    _paidAmountController.dispose();
    _outstandingBalanceController.dispose();

    // Additional Info
    _additionalInfoController.dispose();

    // Parent controllers
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

    super.dispose();
  }

  void _populateExistingData() {
    final data = widget.admissionData;

    // Personal Info
    _firstNameController.text = data.personalInfo?.firstName ?? '';
    _middleNameController.text = data.personalInfo?.middleName ?? '';
    _lastNameController.text = data.personalInfo?.lastName ?? '';
    _selectedDob = data.personalInfo?.dateOfBirth;
    _dobController.text =
        _selectedDob != null ? _formatDate(_selectedDob!) : '';
    _selectedGender = data.personalInfo?.gender;
    _nationalityController.text = data.personalInfo?.nationality ?? '';
    _stateOfOriginController.text = data.personalInfo?.stateOfOrigin ?? '';
    _localGovernmentController.text = data.personalInfo?.localGovernment ?? '';
    _religionController.text = data.personalInfo?.religion ?? '';
    _bloodGroupController.text = data.personalInfo?.bloodGroup ?? '';
    _languagesSpokenController.text =
        data.personalInfo?.languagesSpokenAtHome ?? '';
    _ethnicBackgroundController.text =
        data.personalInfo?.ethnicBackground ?? '';
    _formOfIdentificationController.text =
        data.personalInfo?.formOfIdentification ?? '';
    _idNumberController.text = data.personalInfo?.idNumber ?? '';
    _previousSchoolController.text = data.personalInfo?.previousSchool ?? '';
    _hasSiblings = data.personalInfo?.hasSiblings ?? false;
    _siblingDetails =
        data.personalInfo?.siblingDetails
            ?.map(
              (s) => {
                'name': s.name,
                'age': s.age,
                'relationship': s.relationship,
              },
            )
            .toList() ??
        [];
    _imageUrl = data.personalInfo?.profileImage;

    // Contact Info
    _streetNumberController.text =
        data.contactInfo?.address?.streetNumber ?? '';
    _streetNameController.text = data.contactInfo?.address?.streetName ?? '';
    _cityController.text = data.contactInfo?.address?.city ?? '';
    _stateController.text = data.contactInfo?.address?.state ?? '';
    _countryController.text = data.contactInfo?.address?.country ?? '';
    _postalCodeController.text = data.contactInfo?.address?.postalCode ?? '';
    _phoneController.text = data.contactInfo?.phone ?? '';
    _emailController.text = data.contactInfo?.email ?? '';

    // Academic Info
    _academicYearController.text = data.academicInfo?.academicYear ?? '';
    _studentTypeController.text = data.academicInfo?.studentType ?? '';
    _selectedAdmissionDate = data.academicInfo?.admissionDate;
    if (_selectedAdmissionDate != null) {
      _admissionDateController.text = _formatDate(_selectedAdmissionDate!);
    }
    _selectedClassId = data.academicInfo?.desiredClass?.id;

    // Medical Info
    if (data.medicalInfo != null) {
      _gpNameController.text =
          data.medicalInfo!.generalPractitioner?.name ?? '';
      _gpAddressController.text =
          data.medicalInfo!.generalPractitioner?.address ?? '';
      _gpPhoneController.text =
          data.medicalInfo!.generalPractitioner?.telephoneNumber ?? '';
      _medicalHistoryController.text = data.medicalInfo!.medicalHistory ?? '';
      _allergiesController.text = data.medicalInfo!.allergies?.join(', ') ?? '';
      _ongoingConditionsController.text =
          data.medicalInfo!.ongoingMedicalConditions ?? '';
      _specialNeedsController.text = data.medicalInfo!.specialNeeds ?? '';
      _currentMedicationController.text =
          data.medicalInfo!.currentMedication ?? '';
      _immunisationController.text = data.medicalInfo!.immunisationRecord ?? '';
      _dietaryRequirementsController.text =
          data.medicalInfo!.dietaryRequirements ?? '';

      if (data.medicalInfo!.emergencyContact != null) {
        _emergencyContactNameController.text =
            data.medicalInfo!.emergencyContact!.name ?? '';
        _emergencyContactPhoneController.text =
            data.medicalInfo!.emergencyContact!.phone ?? '';
        _emergencyContactRelationshipController.text =
            data.medicalInfo!.emergencyContact!.relationship ?? '';
        _emergencyContactEmailController.text =
            data.medicalInfo!.emergencyContact!.email ?? '';
        _emergencyAuthorisedToCollect =
            data.medicalInfo!.emergencyContact!.authorisedToCollectChild ??
            false;

        if (data.medicalInfo!.emergencyContact!.address != null) {
          _emergencyStreetNumberController.text =
              data.medicalInfo!.emergencyContact!.address!.streetNumber ?? '';
          _emergencyStreetNameController.text =
              data.medicalInfo!.emergencyContact!.address!.streetName ?? '';
          _emergencyCityController.text =
              data.medicalInfo!.emergencyContact!.address!.city ?? '';
          _emergencyStateController.text =
              data.medicalInfo!.emergencyContact!.address!.state ?? '';
          _emergencyCountryController.text =
              data.medicalInfo!.emergencyContact!.address!.country ?? '';
          _emergencyPostalCodeController.text =
              data.medicalInfo!.emergencyContact!.address!.postalCode ?? '';
        }
      }
    }

    // SEN Info
    if (data.senInfo != null) {
      _hasSpecialNeeds = data.senInfo!.hasSpecialNeeds ?? false;
      _receivingAdditionalSupport =
          data.senInfo!.receivingAdditionalSupport ?? false;
      _supportDetailsController.text = data.senInfo!.supportDetails ?? '';
      _hasEHCP = data.senInfo!.hasEhcp ?? false;
      _ehcpDetailsController.text = data.senInfo!.ehcpDetails ?? '';
    }

    // Permissions
    if (data.permissions != null) {
      _emergencyMedicalTreatment =
          data.permissions!.emergencyMedicalTreatment ?? false;
      _administrationOfMedication =
          data.permissions!.administrationOfMedication ?? false;
      _firstAidConsent = data.permissions!.firstAidConsent ?? false;
      _outingsAndTrips = data.permissions!.outingsAndTrips ?? false;
      _transportConsent = data.permissions!.transportConsent ?? false;
      _useOfPhotosVideos = data.permissions!.useOfPhotosVideos ?? false;
      _suncreamApplication = data.permissions!.suncreamApplication ?? false;
      _observationAndAssessment =
          data.permissions!.observationAndAssessment ?? false;
    }

    // Session Info
    if (data.sessionInfo != null) {
      _requestedStartDateController.text =
          data.sessionInfo!.requestedStartDate?.toIso8601String().split(
            'T',
          )[0] ??
          '';
      _daysOfAttendanceController.text =
          data.sessionInfo!.daysOfAttendance ?? '';
      _fundedHoursController.text = data.sessionInfo!.fundedHours ?? '';
      _additionalPaidSessionsController.text =
          data.sessionInfo!.additionalPaidSessions ?? '';
      _preferredSettlingController.text =
          data.sessionInfo!.preferredSettlingInSessions ?? '';
    }

    // Background Info
    if (data.backgroundInfo != null) {
      _previousChildcareController.text =
          data.backgroundInfo!.previousChildcareProvider ?? '';
      _interestsController.text = data.backgroundInfo!.interests ?? '';
      _toiletTrainingController.text =
          data.backgroundInfo!.toiletTrainingStatus ?? '';
      _comfortItemsController.text = data.backgroundInfo!.comfortItems ?? '';
      _sleepRoutineController.text = data.backgroundInfo!.sleepRoutine ?? '';
      _behaviouralConcernsController.text =
          data.backgroundInfo!.behaviouralConcerns ?? '';
    }

    // Legal Info
    if (data.legalInfo != null) {
      _legalResponsibilityController.text =
          data.legalInfo!.legalResponsibility ?? '';
      _courtOrdersController.text = data.legalInfo!.courtOrders ?? '';
      _safeguardingController.text =
          data.legalInfo!.safeguardingDisclosure ?? '';
      _parentSignatureController.text = data.legalInfo!.parentSignature ?? '';
      _signatureDateController.text =
          data.legalInfo!.signatureDate?.toIso8601String().split('T')[0] ?? '';
    }

    // Funding Info
    if (data.fundingInfo != null) {
      _agreementToPayFees = data.fundingInfo!.agreementToPayFees ?? false;
      _fundingAgreementController.text =
          data.fundingInfo!.fundingAgreement ?? '';
    }

    // Financial Info
    if (data.financialInfo != null) {
      _feeStatusController.text = data.financialInfo!.feeStatus ?? '';
      _totalFeesController.text =
          data.financialInfo!.totalFees?.toString() ?? '';
      _paidAmountController.text =
          data.financialInfo!.paidAmount?.toString() ?? '';
      _outstandingBalanceController.text =
          data.financialInfo!.outstandingBalance?.toString() ?? '';
    }

    // Additional Info
    _additionalInfoController.text = data.additionalInfo ?? '';

    // Parent Info (Legacy)
    if (data.parentInfo?.legacy != null) {
      final parentName = data.parentInfo!.legacy!.name?.split(' ') ?? [];
      _fatherFirstNameController.text =
          parentName.isNotEmpty ? parentName[0] : '';
      _fatherLastNameController.text =
          parentName.length > 1 ? parentName.sublist(1).join(' ') : '';
      _fatherPhoneController.text = data.parentInfo!.legacy!.phone ?? '';
      _fatherEmailController.text = data.parentInfo!.legacy!.email ?? '';
      _fatherOccupationController.text =
          data.parentInfo!.legacy!.occupation ?? '';
      _fatherAddressController.text = data.parentInfo!.legacy!.address ?? '';
    }
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
      return '${selectedClass?.level} (${selectedClass?.name})';
    } catch (e) {
      return null;
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
        } else {
          _selectedDob = picked;
          _dobController.text = _formatDate(picked);
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

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageUploadSection(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _middleNameController,
                  label: 'Middle Name',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _lastNameController,
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
                  controller: _dobController,
                  label: 'Date of Birth',
                  readOnly: true,
                  onTap: () => _selectDate(context, false),
                  suffixIcon: const Icon(Icons.calendar_today, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Gender',
                  value: _selectedGender,
                  items: const ['male', 'female'],
                  onChanged: (v) => setState(() => _selectedGender = v),
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
                  controller: _nationalityController,
                  label: 'Nationality',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _stateOfOriginController,
                  label: 'State of Origin',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _localGovernmentController,
                  label: 'Local Government',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _religionController,
                  label: 'Religion',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _bloodGroupController,
                  label: 'Blood Group',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _formOfIdentificationController,
                  label: 'Form of Identification',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(controller: _idNumberController, label: 'ID Number'),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _languagesSpokenController,
            label: 'Languages Spoken at Home',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _ethnicBackgroundController,
            label: 'Ethnic Background',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _previousSchoolController,
            label: 'Previous School',
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Has Siblings'),
            value: _hasSiblings,
            onChanged: (value) => setState(() => _hasSiblings = value),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Address Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _streetNumberController,
                  label: 'Street Number',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _streetNameController,
                  label: 'Street Name',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _stateController,
                  label: 'State',
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
                  onChanged:
                      (value) => setState(() => _selectedCountry = value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _postalCodeController,
                  label: 'Postal Code',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Contact Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _phoneController,
                  label: 'Phone',
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ],
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
            'General Practitioner',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _gpNameController,
                  label: 'GP Name',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _gpPhoneController,
                  label: 'GP Phone',
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _gpAddressController,
            label: 'GP Address',
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          const Text(
            'Medical Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _medicalHistoryController,
            label: 'Medical History',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _allergiesController,
            label: 'Allergies',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _ongoingConditionsController,
            label: 'Ongoing Medical Conditions',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _specialNeedsController,
            label: 'Special Needs',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _currentMedicationController,
            label: 'Current Medication',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _immunisationController,
            label: 'Immunisation Record',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _dietaryRequirementsController,
            label: 'Dietary Requirements',
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          const Text(
            'Emergency Contact',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _emergencyContactNameController,
                  label: 'Emergency Contact Name',
                ),
              ),
              const SizedBox(width: 12),
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
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _emergencyContactRelationshipController,
                  label: 'Relationship',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _emergencyContactEmailController,
                  label: 'Emergency Contact Email',
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Authorised to Collect Child'),
            value: _emergencyAuthorisedToCollect,
            onChanged:
                (value) =>
                    setState(() => _emergencyAuthorisedToCollect = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSenPermissionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Special Educational Needs',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Has Special Needs'),
            value: _hasSpecialNeeds,
            onChanged: (value) => setState(() => _hasSpecialNeeds = value),
          ),
          SwitchListTile(
            title: const Text('Receiving Additional Support'),
            value: _receivingAdditionalSupport,
            onChanged:
                (value) => setState(() => _receivingAdditionalSupport = value),
          ),
          _buildTextField(
            controller: _supportDetailsController,
            label: 'Support Details',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Has EHCP'),
            value: _hasEHCP,
            onChanged: (value) => setState(() => _hasEHCP = value),
          ),
          _buildTextField(
            controller: _ehcpDetailsController,
            label: 'EHCP Details',
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          const Text(
            'Permissions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Emergency Medical Treatment'),
            value: _emergencyMedicalTreatment,
            onChanged:
                (value) => setState(() => _emergencyMedicalTreatment = value),
          ),
          SwitchListTile(
            title: const Text('Administration of Medication'),
            value: _administrationOfMedication,
            onChanged:
                (value) => setState(() => _administrationOfMedication = value),
          ),
          SwitchListTile(
            title: const Text('First Aid Consent'),
            value: _firstAidConsent,
            onChanged: (value) => setState(() => _firstAidConsent = value),
          ),
          SwitchListTile(
            title: const Text('Outings and Trips'),
            value: _outingsAndTrips,
            onChanged: (value) => setState(() => _outingsAndTrips = value),
          ),
          SwitchListTile(
            title: const Text('Transport Consent'),
            value: _transportConsent,
            onChanged: (value) => setState(() => _transportConsent = value),
          ),
          SwitchListTile(
            title: const Text('Use of Photos/Videos'),
            value: _useOfPhotosVideos,
            onChanged: (value) => setState(() => _useOfPhotosVideos = value),
          ),
          SwitchListTile(
            title: const Text('Suncream Application'),
            value: _suncreamApplication,
            onChanged: (value) => setState(() => _suncreamApplication = value),
          ),
          SwitchListTile(
            title: const Text('Observation and Assessment'),
            value: _observationAndAssessment,
            onChanged:
                (value) => setState(() => _observationAndAssessment = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionBackgroundTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Session Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _requestedStartDateController,
            label: 'Requested Start Date',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _daysOfAttendanceController,
                  label: 'Days of Attendance',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _fundedHoursController,
                  label: 'Funded Hours',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _additionalPaidSessionsController,
            label: 'Additional Paid Sessions',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _preferredSettlingController,
            label: 'Preferred Settling In Sessions',
          ),
          const SizedBox(height: 20),
          const Text(
            'Background Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _previousChildcareController,
            label: 'Previous Childcare Provider',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _interestsController,
            label: 'Interests',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _toiletTrainingController,
            label: 'Toilet Training Status',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _comfortItemsController,
            label: 'Comfort Items',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _sleepRoutineController,
            label: 'Sleep Routine',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _behaviouralConcernsController,
            label: 'Behavioural Concerns',
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildLegalFundingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legal Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _legalResponsibilityController,
            label: 'Legal Responsibility',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _courtOrdersController,
            label: 'Court Orders',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _safeguardingController,
            label: 'Safeguarding Disclosure',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _parentSignatureController,
                  label: 'Parent Signature',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _signatureDateController,
                  label: 'Signature Date',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Funding Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Agreement to Pay Fees'),
            value: _agreementToPayFees,
            onChanged: (value) => setState(() => _agreementToPayFees = value),
          ),

          const SizedBox(height: 20),
          _buildTextField(
            controller: _additionalInfoController,
            label: 'Additional Information',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildParentInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Parent Information (Legacy)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _fatherFirstNameController,
                  label: 'Parent First Name',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _fatherMiddleNameController,
                  label: 'Parent Middle Name',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _fatherLastNameController,
                  label: 'Parent Last Name',
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
                  controller: _fatherPhoneController,
                  label: 'Parent Phone',
                  isRequired: true,
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _fatherEmailController,
                  label: 'Parent Email',
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _fatherOccupationController,
            label: 'Parent Occupation',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _fatherAddressController,
            label: 'Parent Address',
            maxLines: 2,
          ),
        ],
      ),
    );
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

    // Collect all missing required fields
    List<String> missingFields = [];

    // Personal Info validation
    if (_firstNameController.text.trim().isEmpty) {
      missingFields.add('First Name');
    }
    if (_lastNameController.text.trim().isEmpty) {
      missingFields.add('Last Name');
    }
    if (_selectedDob == null) {
      missingFields.add('Date of Birth');
    }
    if (_selectedGender == null) {
      missingFields.add('Gender');
    }

    // Contact Info validation
    if (_streetNameController.text.trim().isEmpty) {
      missingFields.add('Street Name');
    }
    if (_cityController.text.trim().isEmpty) {
      missingFields.add('City');
    }
    if (_selectedState == null) {
      missingFields.add('State');
    }
    if (_selectedCountry == null) {
      missingFields.add('Country');
    }
    if (_phoneController.text.trim().isEmpty) {
      missingFields.add('Phone Number');
    }
    if (_emailController.text.trim().isEmpty) {
      missingFields.add('Email Address');
    }

    // Academic Info validation
    if (_selectedClassId == null) {
      missingFields.add('Class Assignment');
    }
    if (_selectedAdmissionDate == null) {
      missingFields.add('Admission Date');
    }

    // Parent Info validation
    if (_fatherFirstNameController.text.trim().isEmpty) {
      missingFields.add('Father First Name');
    }
    if (_fatherLastNameController.text.trim().isEmpty) {
      missingFields.add('Father Last Name');
    }
    if (_fatherPhoneController.text.trim().isEmpty) {
      missingFields.add('Father Phone Number');
    }
    if (_fatherEmailController.text.trim().isEmpty) {
      missingFields.add('Father Email Address');
    }
    if (_fatherOccupationController.text.trim().isEmpty) {
      missingFields.add('Father Occupation');
    }

    // Medical Info validation
    if (_gpNameController.text.trim().isEmpty) {
      missingFields.add('General Practitioner Name');
    }
    if (_gpPhoneController.text.trim().isEmpty) {
      missingFields.add('General Practitioner Phone');
    }
    if (_emergencyContactNameController.text.trim().isEmpty) {
      missingFields.add('Emergency Contact Name');
    }
    if (_emergencyContactPhoneController.text.trim().isEmpty) {
      missingFields.add('Emergency Contact Phone');
    }
    if (_emergencyContactRelationshipController.text.trim().isEmpty) {
      missingFields.add('Emergency Contact Relationship');
    }

    // Show missing fields if any
    if (missingFields.isNotEmpty) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Missing Required Fields'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Please fill in the following required fields:'),
                  const SizedBox(height: 16),
                  ...missingFields.map(
                    (field) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(field)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    final updatedData = {
      'personalInfo': {
        'firstName': _firstNameController.text.trim(),
        'middleName':
            _middleNameController.text.trim().isNotEmpty
                ? _middleNameController.text.trim()
                : null,
        'lastName': _lastNameController.text.trim(),
        'dateOfBirth':
            (_selectedDob ?? DateTime.now()).toIso8601String().split('T')[0],
        'gender': _selectedGender ?? 'male',
        'nationality':
            _nationalityController.text.trim().isNotEmpty
                ? _nationalityController.text.trim()
                : null,
        'stateOfOrigin':
            _stateOfOriginController.text.trim().isNotEmpty
                ? _stateOfOriginController.text.trim()
                : null,
        'localGovernment':
            _localGovernmentController.text.trim().isNotEmpty
                ? _localGovernmentController.text.trim()
                : null,
        'religion':
            _religionController.text.trim().isNotEmpty
                ? _religionController.text.trim()
                : null,
        'bloodGroup':
            _bloodGroupController.text.trim().isNotEmpty
                ? _bloodGroupController.text.trim()
                : null,
        'languagesSpokenAtHome':
            _languagesSpokenController.text.trim().isNotEmpty
                ? _languagesSpokenController.text.trim()
                : null,
        'ethnicBackground':
            _ethnicBackgroundController.text.trim().isNotEmpty
                ? _ethnicBackgroundController.text.trim()
                : null,
        'formOfIdentification':
            _formOfIdentificationController.text.trim().isNotEmpty
                ? _formOfIdentificationController.text.trim()
                : null,
        'idNumber':
            _idNumberController.text.trim().isNotEmpty
                ? _idNumberController.text.trim()
                : null,
        'hasSiblings': _hasSiblings,
        'siblingDetails': _siblingDetails,
        'profileImage': _imageUrl,
        'previousSchool':
            _previousSchoolController.text.trim().isNotEmpty
                ? _previousSchoolController.text.trim()
                : null,
      },
      'contactInfo': {
        'address': {
          'streetNumber':
              _streetNumberController.text.trim().isNotEmpty
                  ? _streetNumberController.text.trim()
                  : null,
          'streetName': _streetNameController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'country': _countryController.text.trim(),
          'postalCode':
              _postalCodeController.text.trim().isNotEmpty
                  ? _postalCodeController.text.trim()
                  : null,
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
      'academicInfo': {
        'desiredClass': _selectedClassId,
        'academicYear': _academicYearController.text.trim(),
        'admissionDate':
            _selectedAdmissionDate!.toIso8601String().split('T')[0],
        'studentType':
            _studentTypeController.text.trim().isNotEmpty
                ? _studentTypeController.text.trim()
                : 'day',
      },
      'parentInfo': {
        'legacy': {
          'name': [
            _fatherFirstNameController.text.trim(),
            _fatherMiddleNameController.text.trim(),
            _fatherLastNameController.text.trim(),
          ].where((p) => p.isNotEmpty).join(' '),
          'phone': _fatherPhoneController.text.trim(),
          'email': _fatherEmailController.text.trim(),
          'occupation': _fatherOccupationController.text.trim(),
          'address':
              _fatherAddressController.text.trim().isNotEmpty
                  ? _fatherAddressController.text.trim()
                  : [
                    _streetNameController.text.trim(),
                    _cityController.text.trim(),
                    (_stateController.text.trim()),
                    (_countryController.text.trim()),
                  ].where((p) => p.isNotEmpty).join(', '),
        },
      },
      'medicalInfo': {
        'generalPractitioner': {
          'name':
              _gpNameController.text.trim().isNotEmpty
                  ? _gpNameController.text.trim()
                  : null,
          'address':
              _gpAddressController.text.trim().isNotEmpty
                  ? _gpAddressController.text.trim()
                  : null,
          'telephoneNumber':
              _gpPhoneController.text.trim().isNotEmpty
                  ? _gpPhoneController.text.trim()
                  : null,
        },
        'medicalHistory':
            _medicalHistoryController.text.trim().isNotEmpty
                ? _medicalHistoryController.text.trim()
                : null,
        'allergies':
            _allergiesController.text.trim().isNotEmpty
                ? _allergiesController.text
                    .trim()
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList()
                : [],
        'ongoingMedicalConditions':
            _ongoingConditionsController.text.trim().isNotEmpty
                ? _ongoingConditionsController.text.trim()
                : null,
        'specialNeeds':
            _specialNeedsController.text.trim().isNotEmpty
                ? _specialNeedsController.text.trim()
                : null,
        'currentMedication':
            _currentMedicationController.text.trim().isNotEmpty
                ? _currentMedicationController.text.trim()
                : null,
        'immunisationRecord':
            _immunisationController.text.trim().isNotEmpty
                ? _immunisationController.text.trim()
                : null,
        'dietaryRequirements':
            _dietaryRequirementsController.text.trim().isNotEmpty
                ? _dietaryRequirementsController.text.trim()
                : null,
        'emergencyContact': {
          'name':
              _emergencyContactNameController.text.trim().isNotEmpty
                  ? _emergencyContactNameController.text.trim()
                  : null,
          'relationship':
              _emergencyContactRelationshipController.text.trim().isNotEmpty
                  ? _emergencyContactRelationshipController.text.trim()
                  : null,
          'phone':
              _emergencyContactPhoneController.text.trim().isNotEmpty
                  ? _emergencyContactPhoneController.text.trim()
                  : null,
          'email':
              _emergencyContactEmailController.text.trim().isNotEmpty
                  ? _emergencyContactEmailController.text.trim()
                  : null,
          'address': {
            'streetNumber':
                _emergencyStreetNumberController.text.trim().isNotEmpty
                    ? _emergencyStreetNumberController.text.trim()
                    : null,
            'streetName':
                _emergencyStreetNameController.text.trim().isNotEmpty
                    ? _emergencyStreetNameController.text.trim()
                    : null,
            'city':
                _emergencyCityController.text.trim().isNotEmpty
                    ? _emergencyCityController.text.trim()
                    : null,
            'state':
                _emergencyStateController.text.trim().isNotEmpty
                    ? _emergencyStateController.text.trim()
                    : null,
            'country':
                _emergencyCountryController.text.trim().isNotEmpty
                    ? _emergencyCountryController.text.trim()
                    : null,
            'postalCode':
                _emergencyPostalCodeController.text.trim().isNotEmpty
                    ? _emergencyPostalCodeController.text.trim()
                    : null,
          },
          'authorisedToCollectChild': _emergencyAuthorisedToCollect,
        },
      },
      'senInfo': {
        'hasSpecialNeeds': _hasSpecialNeeds,
        'receivingAdditionalSupport': _receivingAdditionalSupport,
        'supportDetails':
            _supportDetailsController.text.trim().isNotEmpty
                ? _supportDetailsController.text.trim()
                : null,
        'hasEHCP': _hasEHCP,
        'ehcpDetails':
            _ehcpDetailsController.text.trim().isNotEmpty
                ? _ehcpDetailsController.text.trim()
                : null,
      },
      'permissions': {
        'emergencyMedicalTreatment': _emergencyMedicalTreatment,
        'administrationOfMedication': _administrationOfMedication,
        'firstAidConsent': _firstAidConsent,
        'outingsAndTrips': _outingsAndTrips,
        'transportConsent': _transportConsent,
        'useOfPhotosVideos': _useOfPhotosVideos,
        'suncreamApplication': _suncreamApplication,
        'observationAndAssessment': _observationAndAssessment,
      },
      'sessionInfo': {
        'requestedStartDate':
            _requestedStartDateController.text.trim().isNotEmpty
                ? _requestedStartDateController.text.trim()
                : null,
        'daysOfAttendance':
            _daysOfAttendanceController.text.trim().isNotEmpty
                ? _daysOfAttendanceController.text.trim()
                : null,
        'fundedHours':
            _fundedHoursController.text.trim().isNotEmpty
                ? _fundedHoursController.text.trim()
                : null,
        'additionalPaidSessions':
            _additionalPaidSessionsController.text.trim().isNotEmpty
                ? _additionalPaidSessionsController.text.trim()
                : null,
        'preferredSettlingInSessions':
            _preferredSettlingController.text.trim().isNotEmpty
                ? _preferredSettlingController.text.trim()
                : null,
      },
      'backgroundInfo': {
        'previousChildcareProvider':
            _previousChildcareController.text.trim().isNotEmpty
                ? _previousChildcareController.text.trim()
                : null,
        'siblings': _siblingDetails,
        'interests':
            _interestsController.text.trim().isNotEmpty
                ? _interestsController.text.trim()
                : null,
        'toiletTrainingStatus':
            _toiletTrainingController.text.trim().isNotEmpty
                ? _toiletTrainingController.text.trim()
                : null,
        'comfortItems':
            _comfortItemsController.text.trim().isNotEmpty
                ? _comfortItemsController.text.trim()
                : null,
        'sleepRoutine':
            _sleepRoutineController.text.trim().isNotEmpty
                ? _sleepRoutineController.text.trim()
                : null,
        'behaviouralConcerns':
            _behaviouralConcernsController.text.trim().isNotEmpty
                ? _behaviouralConcernsController.text.trim()
                : null,
        'languagesSpokenAtHome':
            _languagesSpokenController.text.trim().isNotEmpty
                ? _languagesSpokenController.text.trim()
                : null,
      },
      'legalInfo': {
        'legalResponsibility':
            _legalResponsibilityController.text.trim().isNotEmpty
                ? _legalResponsibilityController.text.trim()
                : null,
        'courtOrders':
            _courtOrdersController.text.trim().isNotEmpty
                ? _courtOrdersController.text.trim()
                : null,
        'safeguardingDisclosure':
            _safeguardingController.text.trim().isNotEmpty
                ? _safeguardingController.text.trim()
                : null,
        'parentSignature':
            _parentSignatureController.text.trim().isNotEmpty
                ? _parentSignatureController.text.trim()
                : null,
        'signatureDate':
            _signatureDateController.text.trim().isNotEmpty
                ? _signatureDateController.text.trim()
                : null,
      },
      'fundingInfo': {
        'agreementToPayFees': _agreementToPayFees,
        'fundingAgreement':
            _fundingAgreementController.text.trim().isNotEmpty
                ? _fundingAgreementController.text.trim()
                : null,
      },
      'financialInfo': {
        'feeStatus':
            _feeStatusController.text.trim().isNotEmpty
                ? _feeStatusController.text.trim()
                : 'unpaid',
        'totalFees':
            _totalFeesController.text.trim().isNotEmpty
                ? double.tryParse(_totalFeesController.text.trim()) ?? 0
                : 0,
        'paidAmount':
            _paidAmountController.text.trim().isNotEmpty
                ? double.tryParse(_paidAmountController.text.trim()) ?? 0
                : 0,
        'outstandingBalance':
            _outstandingBalanceController.text.trim().isNotEmpty
                ? double.tryParse(_outstandingBalanceController.text.trim()) ??
                    0
                : 0,
      },
      'additionalInfo':
          _additionalInfoController.text.trim().isNotEmpty
              ? _additionalInfoController.text.trim()
              : null,
    };

    widget.onApprove(updatedData);
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
                          'Student: ${widget.admissionData.personalInfo?.firstName} ${widget.admissionData.personalInfo?.lastName ?? ''}',
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
                  Tab(text: 'Personal Info', icon: Icon(Icons.person)),
                  Tab(text: 'Contact Info', icon: Icon(Icons.contact_phone)),
                  Tab(text: 'Medical Info', icon: Icon(Icons.medical_services)),
                  Tab(
                    text: 'SEN & Permissions',
                    icon: Icon(Icons.accessibility),
                  ),
                  Tab(text: 'Session & Background', icon: Icon(Icons.schedule)),
                  Tab(text: 'Legal & Funding', icon: Icon(Icons.gavel)),
                  Tab(text: 'Parent Info', icon: Icon(Icons.family_restroom)),
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
                    _buildPersonalInfoTab(),
                    _buildContactInfoTab(),
                    _buildMedicalInfoTab(),
                    _buildSenPermissionsTab(),
                    _buildSessionBackgroundTab(),
                    _buildLegalFundingTab(),
                    _buildParentInfoTab(),
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
                      .map((c) => '${c?.level} (${c?.name})')
                      .cast<String>()
                      .toSet()
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClassId =
                      _classes
                          .firstWhere(
                            (c) => '${c?.level} (${c?.name})' == value,
                          )
                          ?.id;
                });
              },
              isRequired: true,
            ),
        ],
      ),
    );
  }
}
